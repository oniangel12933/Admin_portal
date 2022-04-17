// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/redux/task/task_actions.dart';
import 'package:invoiceninja_flutter/redux/task_status/task_status_selectors.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// Project imports:
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/settings/settings_actions.dart';
import 'package:invoiceninja_flutter/ui/app/app_builder.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/alert_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/error_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/loading_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/forms/decorated_form_field.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/icons.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/oauth.dart';

void showRefreshDataDialog(
    {@required BuildContext context, bool includeStatic = false}) async {
  final store = StoreProvider.of<AppState>(context);
  store.dispatch(RefreshData(
    completer: snackBarCompleter<Null>(
        context, AppLocalization.of(context).refreshComplete,
        shouldPop: true),
    clearData: true,
    includeStatic: includeStatic,
  ));

  await showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SimpleDialog(
            children: <Widget>[LoadingDialog()],
          ));

  AppBuilder.of(context).rebuild();
}

void showErrorDialog({
  @required BuildContext context,
  String message,
  bool clearErrorOnDismiss = false,
}) {
  showDialog<ErrorDialog>(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message, clearErrorOnDismiss: clearErrorOnDismiss);
      });
}

void showMessageDialog({
  @required BuildContext context,
  @required String message,
  List<TextButton> secondaryActions,
  Function onDismiss,
}) {
  showDialog<MessageDialog>(
      context: context,
      builder: (BuildContext context) {
        return MessageDialog(
          message,
          secondaryActions: secondaryActions,
          onDismiss: onDismiss,
        );
      });
}

void confirmCallback({
  @required BuildContext context,
  @required Function(String) callback,
  String message,
  String typeToConfirm,
  bool askForReason = false,
  bool skip = false,
}) {
  if (skip) {
    callback(null);
    return;
  }

  final localization = AppLocalization.of(context);
  final title = message == null ? localization.areYouSure : message;
  final content = message == null ? null : localization.areYouSure;

  showDialog<AlertDialog>(
    context: context,
    builder: (BuildContext context) {
      String _typed = '';
      String _reason = '';

      void _onPressed() {
        if (typeToConfirm == null ||
            typeToConfirm.toLowerCase() == _typed.toLowerCase()) {
          Navigator.pop(context);
          callback(_reason);
        } else {
          showMessageDialog(
              context: context,
              message: localization.pleaseTypeToConfirm
                  .replaceFirst(':value', typeToConfirm));
        }
      }

      return PointerInterceptor(
        child: AlertDialog(
          semanticLabel: localization.areYouSure,
          title: typeToConfirm != null ? null : Text(title),
          content: typeToConfirm != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8),
                    Flexible(
                      child: Text(localization.pleaseTypeToConfirm
                              .replaceFirst(':value', typeToConfirm) +
                          ':'),
                    ),
                    DecoratedFormField(
                      autofocus: true,
                      onChanged: (value) => _typed = value,
                      hint: typeToConfirm,
                      onSavePressed: (context) => _onPressed(),
                      keyboardType: TextInputType.text,
                    ),
                    if (askForReason) ...[
                      SizedBox(height: 30),
                      Flexible(child: Text(localization.whyAreYouLeaving)),
                      DecoratedFormField(
                        onChanged: (value) => _reason = value,
                        minLines: 4,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                    SizedBox(height: 30),
                    Flexible(
                        child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )),
                  ],
                )
              : content == null
                  ? null
                  : Text(content),
          actions: <Widget>[
            TextButton(
                child: Text(localization.cancel.toUpperCase()),
                onPressed: () {
                  Navigator.pop(context);
                }),
            TextButton(
              child: Text(localization.ok.toUpperCase()),
              onPressed: () => _onPressed(),
              autofocus: typeToConfirm == null,
            )
          ],
        ),
      );
    },
  );
}

void passwordCallback({
  @required BuildContext context,
  @required Function(String, String) callback,
  bool alwaysRequire = false,
}) {
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final localization = AppLocalization.of(context);
  final user = state.user;

  if (alwaysRequire && !user.hasPassword) {
    showMessageDialog(
        context: context,
        message: localization.pleaseSetAPassword,
        secondaryActions: [
          TextButton(
              onPressed: () {
                store.dispatch(ViewSettings(section: kSettingsUserDetails));
                Navigator.of(context).pop();
              },
              child: Text(localization.setPassword.toUpperCase()))
        ]);
    return;
  }

  if (state.hasRecentlyEnteredPassword && !alwaysRequire) {
    callback(null, null);
    return;
  }

  if (user.oauthProvider.isEmpty) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordConfirmation(
          callback: callback,
        );
      },
    );
    return;
  }

  try {
    GoogleOAuth.signIn((idToken, accessToken) {
      if ((!alwaysRequire && !state.company.oauthPasswordRequired) ||
          !user.hasPassword) {
        callback(null, idToken);
      } else {
        showDialog<AlertDialog>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PasswordConfirmation(
              callback: callback,
              idToken: idToken,
            );
          },
        );
      }
    }, isSilent: true);
  } catch (error) {
    showErrorDialog(context: context, message: '$error');
  }
}

class PasswordConfirmation extends StatefulWidget {
  const PasswordConfirmation({@required this.callback, this.idToken});

  final Function(String, String) callback;
  final String idToken;

  @override
  _PasswordConfirmationState createState() => _PasswordConfirmationState();
}

class _PasswordConfirmationState extends State<PasswordConfirmation> {
  String _password;
  bool _isPasswordObscured = true;

  void _submit() {
    if ((_password ?? '').isEmpty) {
      return;
    }
    Navigator.pop(context);
    widget.callback(_password, widget.idToken);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return AlertDialog(
      title: Text(localization.verifyPassword),
      content: TextField(
        autofocus: true,
        onChanged: (value) => _password = value,
        obscureText: _isPasswordObscured,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          labelText: localization.password,
          suffixIcon: IconButton(
            alignment: Alignment.bottomCenter,
            icon: Icon(
              _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordObscured = !_isPasswordObscured;
              });
            },
          ),
        ),
        onSubmitted: (value) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.cancel.toUpperCase())),
        TextButton(
            onPressed: () => _submit(),
            child: Text(localization.submit.toUpperCase())),
      ],
    );
  }
}

void fieldCallback({
  BuildContext context,
  String title,
  String field,
  Function(String) callback,
  int maxLength,
  List<TextButton> secondaryActions,
}) {
  showDialog<AlertDialog>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return FieldConfirmation(
        callback: callback,
        field: field,
        title: title,
        maxLength: maxLength,
        secondaryActions: secondaryActions,
      );
    },
  );
}

class FieldConfirmation extends StatefulWidget {
  const FieldConfirmation({
    @required this.callback,
    @required this.title,
    @required this.field,
    this.maxLength,
    this.secondaryActions,
  });

  final Function(String) callback;
  final String title;
  final String field;
  final int maxLength;
  final List<TextButton> secondaryActions;

  @override
  _FieldConfirmationState createState() => _FieldConfirmationState();
}

class _FieldConfirmationState extends State<FieldConfirmation> {
  String _field;

  void _submit() {
    if ((_field ?? '').isEmpty) {
      return;
    }
    Navigator.pop(context);
    widget.callback(_field);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        autofocus: true,
        onChanged: (value) => _field = value,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLength != null
            ? MaxLengthEnforcement.enforced
            : MaxLengthEnforcement.none,
        buildCounter: (_, {currentLength, maxLength, isFocused}) => null,
        decoration: InputDecoration(
          labelText: widget.field,
        ),
        onSubmitted: (value) => _submit(),
      ),
      actions: <Widget>[
        ...widget.secondaryActions ?? [],
        SizedBox(width: 6),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.cancel.toUpperCase())),
        TextButton(
            onPressed: () => _submit(),
            child: Text(localization.submit.toUpperCase())),
      ],
    );
  }
}

void cloneToDialog({
  @required BuildContext context,
  @required InvoiceEntity invoice,
}) {
  final localization = AppLocalization.of(context);
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final userCompany = state.userCompany;

  showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.cloneTo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userCompany.canCreate(EntityType.invoice))
                ListTile(
                  leading: Icon(getEntityIcon(EntityType.invoice)),
                  title: Text(localization.invoice),
                  onTap: () {
                    Navigator.of(context).pop();
                    handleEntityAction(invoice, EntityAction.cloneToInvoice);
                  },
                ),
              if (userCompany.canCreate(EntityType.quote))
                ListTile(
                  leading: Icon(getEntityIcon(EntityType.quote)),
                  title: Text(localization.quote),
                  onTap: () {
                    Navigator.of(context).pop();
                    handleEntityAction(invoice, EntityAction.cloneToQuote);
                  },
                ),
              if (userCompany.canCreate(EntityType.credit))
                ListTile(
                  leading: Icon(getEntityIcon(EntityType.credit)),
                  title: Text(localization.credit),
                  onTap: () {
                    Navigator.of(context).pop();
                    handleEntityAction(invoice, EntityAction.cloneToCredit);
                  },
                ),
              if (userCompany.canCreate(EntityType.recurringInvoice))
                ListTile(
                  leading: Icon(getEntityIcon(EntityType.recurringInvoice)),
                  title: Text(localization.recurringInvoice),
                  onTap: () {
                    Navigator.of(context).pop();
                    handleEntityAction(invoice, EntityAction.cloneToRecurring);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(localization.close.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
}

void changeTaskStatusDialog({
  @required BuildContext context,
  @required TaskEntity task,
}) {
  final localization = AppLocalization.of(context);
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final statusIds = memoizedSortedActiveTaskStatusIds(
          state.taskStatusState.list, state.taskStatusState.map)
      .where((statusId) => statusId != task.statusId)
      .toList();

  showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.changeStatus),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusIds.map((statusId) {
              final status = state.taskStatusState.get(statusId);
              return ListTile(
                title: Text(status.name),
                leading: Icon(Icons.check_circle),
                onTap: () {
                  store.dispatch(SaveTaskRequest(
                    task: task.rebuild((b) => b..statusId = statusId),
                    completer: snackBarCompleter<TaskEntity>(
                      context,
                      localization.changedStatus,
                    ),
                  ));
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text(localization.close.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
}
