// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:built_collection/built_collection.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/app/screen_imports.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_desktop.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_details.dart';

class InvoiceEditDetailsScreen extends StatelessWidget {
  const InvoiceEditDetailsScreen({Key key, @required this.viewModel})
      : super(key: key);

  final AbstractInvoiceEditVM viewModel;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, InvoiceEditDetailsVM>(
      converter: (Store<AppState> store) {
        return InvoiceEditDetailsVM.fromStore(store);
      },
      builder: (context, viewModel) {
        if (viewModel.state.prefState.isEditorFullScreen(EntityType.invoice)) {
          return InvoiceEditDesktop(
            viewModel: viewModel,
            entityViewModel: this.viewModel,
            key: ValueKey('__invoice_${viewModel.invoice.id}__'),
          );
        } else {
          return InvoiceEditDetails(
            viewModel: viewModel,
          );
        }
      },
    );
  }
}

class EntityEditDetailsVM {
  EntityEditDetailsVM({
    @required this.state,
    @required this.company,
    @required this.invoice,
    @required this.onChanged,
    @required this.onClientChanged,
    @required this.clientMap,
    @required this.clientList,
    @required this.onAddClientPressed,
  });

  final AppState state;
  final CompanyEntity company;
  final InvoiceEntity invoice;
  final Function(InvoiceEntity) onChanged;
  final Function(BuildContext context, InvoiceEntity, ClientEntity)
      onClientChanged;
  final BuiltMap<String, ClientEntity> clientMap;
  final BuiltList<String> clientList;
  final Function(BuildContext context, Completer<SelectableEntity> completer)
      onAddClientPressed;
}

class InvoiceEditDetailsVM extends EntityEditDetailsVM {
  InvoiceEditDetailsVM({
    AppState state,
    CompanyEntity company,
    InvoiceEntity invoice,
    Function(InvoiceEntity) onChanged,
    Function(BuildContext, InvoiceEntity, ClientEntity) onClientChanged,
    BuiltMap<String, ClientEntity> clientMap,
    BuiltList<String> clientList,
    Function(BuildContext context, Completer<SelectableEntity> completer)
        onAddClientPressed,
  }) : super(
          state: state,
          company: company,
          invoice: invoice,
          onChanged: onChanged,
          onClientChanged: onClientChanged,
          clientMap: clientMap,
          clientList: clientList,
          onAddClientPressed: onAddClientPressed,
        );

  factory InvoiceEditDetailsVM.fromStore(Store<AppState> store) {
    final AppState state = store.state;
    final invoice = state.invoiceUIState.editing;
    final company = state.company;

    return InvoiceEditDetailsVM(
      state: state,
      company: company,
      invoice: invoice,
      onChanged: (InvoiceEntity invoice) =>
          store.dispatch(UpdateInvoice(invoice)),
      clientMap: state.clientState.map,
      clientList: state.clientState.list,
      onClientChanged: (context, invoice, client) {
        store.dispatch(UpdateInvoice(invoice.applyClient(state, client)));
        store.dispatch(UpdateInvoiceClient(client: client));
      },
      onAddClientPressed: (context, completer) {
        createEntity(
            context: context,
            entity: ClientEntity(),
            force: true,
            completer: completer,
            cancelCompleter: Completer<Null>()
              ..future.then((_) {
                store.dispatch(UpdateCurrentRoute(InvoiceEditScreen.route));
              }));
        completer.future.then((SelectableEntity client) {
          store.dispatch(UpdateCurrentRoute(InvoiceEditScreen.route));
        });
      },
    );
  }
}
