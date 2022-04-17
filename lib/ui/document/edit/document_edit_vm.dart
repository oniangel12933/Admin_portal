// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/document/document_actions.dart';
import 'package:invoiceninja_flutter/ui/document/edit/document_edit.dart';

class DocumentEditScreen extends StatelessWidget {
  const DocumentEditScreen({Key key}) : super(key: key);
  static const String route = '/document/edit';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DocumentEditVM>(
      converter: (Store<AppState> store) {
        return DocumentEditVM.fromStore(store);
      },
      builder: (context, viewModel) {
        return DocumentEdit(
          viewModel: viewModel,
          key: ValueKey(viewModel.document.updatedAt),
        );
      },
    );
  }
}

class DocumentEditVM {
  DocumentEditVM({
    @required this.state,
    @required this.document,
    @required this.company,
    @required this.onChanged,
    @required this.isSaving,
    @required this.origDocument,
    @required this.onSavePressed,
    @required this.isLoading,
  });

  factory DocumentEditVM.fromStore(Store<AppState> store) {
    final document = store.state.documentUIState.editing;
    final state = store.state;

    return DocumentEditVM(
      state: state,
      isLoading: state.isLoading,
      isSaving: state.isSaving,
      origDocument: state.documentState.map[document.id],
      document: document,
      company: state.company,
      onChanged: (DocumentEntity document) {
        store.dispatch(UpdateDocument(document));
      },
      onSavePressed: (BuildContext context) {
        /*
Debouncer.runOnComplete(() {
          final document = store.state.documentUIState.editing;
          final localization = navigatorKey.localization;
          final navigator = navigatorKey.currentState;
          final Completer<DocumentEntity> completer =
              new Completer<DocumentEntity>();
          store.dispatch(
              SaveDocumentRequest(completer: completer, document: document));
          return completer.future.then((savedDocument) {
              showToast(client.isNew
                  ? localization.createdClient
                  : localization.updatedClient);
            if (state.prefState.isMobile) {
              store.dispatch(UpdateCurrentRoute(DocumentViewScreen.route));
              if (document.isNew) {
                navigator
                    .pushReplacementNamed(DocumentViewScreen.route);
              } else {
                navigator.pop(savedDocument);
              }
            } else {
              viewEntityById(
                  entityId: savedDocument.id,
                  entityType: EntityType.document,
                  force: true);
            }
          }).catchError((Object error) {
            showDialog<ErrorDialog>(
                context: navigatorKey.currentContext,
                builder: (BuildContext context) {
                  return ErrorDialog(error);
                });
          });
        });*/
      },
    );
  }

  final DocumentEntity document;
  final CompanyEntity company;
  final Function(DocumentEntity) onChanged;
  final Function(BuildContext) onSavePressed;
  final bool isLoading;
  final bool isSaving;
  final DocumentEntity origDocument;
  final AppState state;
}
