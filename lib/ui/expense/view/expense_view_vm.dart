// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/document/document_actions.dart';
import 'package:invoiceninja_flutter/redux/expense/expense_actions.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/error_dialog.dart';
import 'package:invoiceninja_flutter/ui/expense/view/expense_view.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class ExpenseViewScreen extends StatelessWidget {
  const ExpenseViewScreen({
    Key key,
    this.isFilter = false,
  }) : super(key: key);

  final bool isFilter;
  static const String route = '/expense/view';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ExpenseViewVM>(
      converter: (Store<AppState> store) {
        return ExpenseViewVM.fromStore(store);
      },
      builder: (context, vm) {
        return ExpenseView(
          viewModel: vm,
          isFilter: isFilter,
          tabIndex: vm.state.expenseUIState.tabIndex,
        );
      },
    );
  }
}

class AbstractExpenseViewVM {
  AbstractExpenseViewVM({
    @required this.state,
    @required this.expense,
    @required this.company,
    @required this.onEntityAction,
    @required this.onRefreshed,
    @required this.onUploadDocument,
    @required this.onDeleteDocument,
    @required this.isSaving,
    @required this.isLoading,
    @required this.isDirty,
  });

  final AppState state;
  final ExpenseEntity expense;
  final CompanyEntity company;
  final Function(BuildContext, EntityAction) onEntityAction;
  final Function(BuildContext) onRefreshed;
  final Function(BuildContext, MultipartFile) onUploadDocument;
  final Function(BuildContext, DocumentEntity, String, String) onDeleteDocument;
  final bool isSaving;
  final bool isLoading;
  final bool isDirty;
}

class ExpenseViewVM extends AbstractExpenseViewVM {
  ExpenseViewVM({
    AppState state,
    ExpenseEntity expense,
    CompanyEntity company,
    Function(BuildContext, EntityAction) onEntityAction,
    Function(BuildContext) onRefreshed,
    Function(BuildContext, MultipartFile) onUploadDocument,
    Function(BuildContext, DocumentEntity, String, String) onDeleteDocument,
    bool isSaving,
    bool isLoading,
    bool isDirty,
  }) : super(
          state: state,
          expense: expense,
          company: company,
          onEntityAction: onEntityAction,
          onRefreshed: onRefreshed,
          onUploadDocument: onUploadDocument,
          onDeleteDocument: onDeleteDocument,
          isSaving: isSaving,
          isLoading: isLoading,
          isDirty: isDirty,
        );

  factory ExpenseViewVM.fromStore(Store<AppState> store) {
    final state = store.state;
    final expense = state.expenseState.map[state.expenseUIState.selectedId] ??
        ExpenseEntity(id: state.expenseUIState.selectedId);

    Future<Null> _handleRefresh(BuildContext context) {
      final completer = snackBarCompleter<Null>(
          context, AppLocalization.of(context).refreshComplete);
      store.dispatch(LoadExpense(completer: completer, expenseId: expense.id));
      return completer.future;
    }

    return ExpenseViewVM(
      state: state,
      company: state.company,
      isSaving: state.isSaving,
      isLoading: state.isLoading,
      isDirty: expense.isNew,
      expense: expense,
      onRefreshed: (context) => _handleRefresh(context),
      onEntityAction: (BuildContext context, EntityAction action) =>
          handleEntitiesActions([expense], action, autoPop: true),
      onUploadDocument: (BuildContext context, MultipartFile multipartFile) {
        final Completer<DocumentEntity> completer = Completer<DocumentEntity>();
        store.dispatch(SaveExpenseDocumentRequest(
            multipartFile: multipartFile,
            expense: expense,
            completer: completer));
        completer.future.then((client) {
          showToast(AppLocalization.of(context).uploadedDocument);
        }).catchError((Object error) {
          showDialog<ErrorDialog>(
              context: navigatorKey.currentContext,
              builder: (BuildContext context) {
                return ErrorDialog(error);
              });
        });
      },
      onDeleteDocument: (BuildContext context, DocumentEntity document,
          String password, String idToken) {
        final completer = snackBarCompleter<Null>(
            context, AppLocalization.of(context).deletedDocument);
        completer.future.then<Null>(
            (value) => store.dispatch(LoadExpense(expenseId: expense.id)));
        store.dispatch(DeleteDocumentRequest(
          completer: completer,
          documentIds: [document.id],
          password: password,
          idToken: idToken,
        ));
      },
    );
  }
}
