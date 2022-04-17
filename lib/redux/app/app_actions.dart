// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:built_collection/built_collection.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/company_gateway_model.dart';
import 'package:invoiceninja_flutter/data/models/group_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/models/payment_term_model.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/client/client_actions.dart';
import 'package:invoiceninja_flutter/redux/client/client_selectors.dart';
import 'package:invoiceninja_flutter/redux/company_gateway/company_gateway_actions.dart';
import 'package:invoiceninja_flutter/redux/credit/credit_actions.dart';
import 'package:invoiceninja_flutter/redux/dashboard/dashboard_actions.dart';
import 'package:invoiceninja_flutter/redux/design/design_actions.dart';
import 'package:invoiceninja_flutter/redux/document/document_actions.dart';
import 'package:invoiceninja_flutter/redux/expense/expense_actions.dart';
import 'package:invoiceninja_flutter/redux/expense_category/expense_category_actions.dart';
import 'package:invoiceninja_flutter/redux/group/group_actions.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/payment/payment_actions.dart';
import 'package:invoiceninja_flutter/redux/payment_term/payment_term_actions.dart';
import 'package:invoiceninja_flutter/redux/product/product_actions.dart';
import 'package:invoiceninja_flutter/redux/project/project_actions.dart';
import 'package:invoiceninja_flutter/redux/quote/quote_actions.dart';
import 'package:invoiceninja_flutter/redux/recurring_expense/recurring_expense_actions.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/reports/reports_actions.dart';
import 'package:invoiceninja_flutter/redux/settings/settings_actions.dart';
import 'package:invoiceninja_flutter/redux/subscription/subscription_actions.dart';
import 'package:invoiceninja_flutter/redux/task/task_actions.dart';
import 'package:invoiceninja_flutter/redux/task_status/task_status_actions.dart';
import 'package:invoiceninja_flutter/redux/tax_rate/tax_rate_actions.dart';
import 'package:invoiceninja_flutter/redux/token/token_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/redux/user/user_actions.dart';
import 'package:invoiceninja_flutter/redux/vendor/vendor_actions.dart';
import 'package:invoiceninja_flutter/redux/webhook/webhook_actions.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/alert_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/entities/entity_actions_dialog.dart';
import 'package:invoiceninja_flutter/ui/app/screen_imports.dart';
import 'package:invoiceninja_flutter/ui/company_gateway/company_gateway_screen.dart';
import 'package:invoiceninja_flutter/ui/design/design_screen.dart';
import 'package:invoiceninja_flutter/ui/expense_category/expense_category_screen.dart';
import 'package:invoiceninja_flutter/ui/payment_term/payment_term_screen.dart';
import 'package:invoiceninja_flutter/ui/subscription/subscription_screen.dart';
import 'package:invoiceninja_flutter/ui/task_status/task_status_screen.dart';
import 'package:invoiceninja_flutter/ui/tax_rate/tax_rate_screen.dart';
import 'package:invoiceninja_flutter/ui/token/token_screen.dart';
import 'package:invoiceninja_flutter/ui/user/user_screen.dart';
import 'package:invoiceninja_flutter/ui/webhook/webhook_screen.dart';
import 'package:invoiceninja_flutter/utils/dialogs.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

// STARTER: import - do not remove comment

class PersistUI {}

class PersistPrefs {}

class PersistData {}

class ClearPersistedData {}

class PersistStatic {}

class RefreshClient {
  RefreshClient(this.clientId);

  final String clientId;
}

class SwitchListTableLayout implements PersistUI, PersistPrefs {}

class PopLastHistory implements PersistUI {}

class DismissNativeWarning implements PersistUI {}

class DismissNativeWarningPermanently implements PersistUI, PersistPrefs {}

class ViewMainScreen {
  ViewMainScreen({this.addDelay = false});

  // This is needed to workaround around a "Duplicate GlobalKey detected
  // in widget tree." error when changing layouts in the settings
  bool addDelay;
}

class StartLoading {}

class StopLoading {}

class StartSaving {}

class StopSaving {}

class ServerVersionUpdated {
  ServerVersionUpdated({this.version});

  final String version;
}

class LoadStaticSuccess implements PersistStatic {
  LoadStaticSuccess({this.data});

  final StaticDataEntity data;
}

class ToggleEditorLayout implements PersistPrefs {
  ToggleEditorLayout(this.entityType);

  final EntityType entityType;
}

class TogglePreviewSidebar {}

class UpdateUserPreferences implements PersistPrefs {
  UpdateUserPreferences({
    this.appLayout,
    this.moduleLayout,
    this.sidebar,
    this.enableDarkMode,
    this.requireAuthentication,
    this.longPressSelectionIsDefault,
    this.textScaleFactor,
    this.isPreviewVisible,
    this.accentColor,
    this.menuMode,
    this.historyMode,
    this.showKanban,
    this.isFilterVisible,
    this.rowsPerPage,
    this.colorTheme,
    this.customColors,
    this.persistData,
    this.persistUi,
    this.tapSelectedToEdit,
    this.showPdfPreview,
    this.editAfterSaving,
    this.enableTouchEvents,
  });

  final AppLayout appLayout;
  final ModuleLayout moduleLayout;
  final AppSidebar sidebar;
  final AppSidebarMode menuMode;
  final AppSidebarMode historyMode;
  final bool enableDarkMode;
  final bool longPressSelectionIsDefault;
  final bool requireAuthentication;
  final bool isPreviewVisible;
  final bool isFilterVisible;
  final bool showKanban;
  final String accentColor;
  final int rowsPerPage;
  final String colorTheme;
  final bool persistData;
  final bool persistUi;
  final bool tapSelectedToEdit;
  final double textScaleFactor;
  final bool showPdfPreview;
  final BuiltMap<String, String> customColors;
  final bool editAfterSaving;
  final bool enableTouchEvents;
}

class LoadAccountSuccess implements StopLoading {
  LoadAccountSuccess({
    @required this.completer,
    @required this.loginResponse,
  });

  final Completer completer;
  final LoginResponse loginResponse;
}

class ResendConfirmation implements StartLoading {}

class ResendConfirmationFailure implements StopLoading {
  ResendConfirmationFailure(this.error);

  final dynamic error;
}

class ResendConfirmationSuccess implements StopLoading {}

class RefreshData implements StartLoading {
  const RefreshData({
    this.completer,
    this.clearData = false,
    this.includeStatic = false,
    this.allCompanies = false,
  });

  final Completer completer;
  final bool clearData;
  final bool includeStatic;
  final bool allCompanies;
}

class RefreshDataSuccess implements StopLoading {
  const RefreshDataSuccess({this.completer, this.data});

  final Completer completer;
  final LoginResponse data;
}

class RefreshDataFailure implements StopLoading {
  const RefreshDataFailure(this.error);

  final dynamic error;
}

class PreviewEntity {
  const PreviewEntity({
    this.entityType,
    this.entityId,
  });

  final String entityId;
  final EntityType entityType;
}

class ClearPreviewStack {}

class PopPreviewStack {}

class PopFilterStack {}

class ClearData {}

class ClearLastError {}

class DiscardChanges {}

class ClearEntityFilter {}

class ClearEntitySelection {
  ClearEntitySelection({this.entityType});

  final EntityType entityType;
}

class FilterByEntity implements PersistUI {
  FilterByEntity({
    @required this.entity,
    this.clearSelection = false,
  });

  final BaseEntity entity;
  final bool clearSelection;

  String get entityId => entity.id;

  EntityType get entityType => entity.entityType;
}

class FilterCompany implements PersistUI {
  FilterCompany(this.filter);

  final String filter;
}

void filterByEntity({
  @required BuildContext context,
  @required BaseEntity entity,
}) {
  if (entity.isNew) {
    return;
  }

  final store = StoreProvider.of<AppState>(context);
  store.dispatch(FilterByEntity(entity: entity));
}

void viewEntitiesByType({
  @required EntityType entityType,
  BaseEntity filterEntity,
}) {
  final store = StoreProvider.of<AppState>(navigatorKey.currentContext);
  final uiState = store.state.uiState;
  dynamic action;

  checkForChanges(
      store: store,
      context: navigatorKey.currentContext,
      callback: () {
        if (filterEntity != null) {
          if (uiState.filterEntityType != filterEntity.entityType ||
              uiState.filterEntityId != filterEntity.id) {
            store.dispatch(ClearEntitySelection(entityType: entityType));
            store.dispatch(FilterByEntity(entity: filterEntity));
          }
        } else if (uiState.filterEntityType != null) {
          store.dispatch(ClearEntityFilter());
        }

        if (uiState.previewStack.isNotEmpty) {
          store.dispatch(ClearPreviewStack());
        }

        if (store.state.prefState.isPreviewVisible &&
            store.state.prefState.moduleLayout == ModuleLayout.table) {
          store.dispatch(TogglePreviewSidebar());
        }

        switch (entityType) {
          case EntityType.dashboard:
            action = ViewDashboard();
            break;
          case EntityType.reports:
            action = ViewReports();
            break;
          case EntityType.settings:
            action = ViewSettings(
              company: store.state.company,
              user: store.state.user,
              clearFilter: true,
            );
            break;
          case EntityType.client:
            action = ViewClientList();
            break;
          case EntityType.user:
            action = ViewUserList();
            break;
          case EntityType.project:
            action = ViewProjectList();
            break;
          case EntityType.taxRate:
            action = ViewTaxRateList();
            break;
          case EntityType.companyGateway:
            action = ViewCompanyGatewayList();
            break;
          case EntityType.invoice:
            action = ViewInvoiceList();
            break;
          case EntityType.quote:
            action = ViewQuoteList();
            break;
          case EntityType.vendor:
            action = ViewVendorList();
            break;
          case EntityType.product:
            action = ViewProductList();
            break;
          case EntityType.task:
            action = ViewTaskList();
            break;
          case EntityType.expense:
            action = ViewExpenseList();
            break;
          case EntityType.payment:
            action = ViewPaymentList();
            break;
          case EntityType.group:
            action = ViewGroupList();
            break;
          // STARTER: view list - do not remove comment
          case EntityType.recurringExpense:
            action = ViewRecurringExpenseList();
            break;
          case EntityType.subscription:
            action = ViewSubscriptionList();
            break;
          case EntityType.taskStatus:
            action = ViewTaskStatusList();
            break;
          case EntityType.expenseCategory:
            action = ViewExpenseCategoryList();
            break;
          case EntityType.recurringInvoice:
            action = ViewRecurringInvoiceList();
            break;
          case EntityType.webhook:
            action = ViewWebhookList();
            break;
          case EntityType.token:
            action = ViewTokenList();
            break;
          case EntityType.paymentTerm:
            action = ViewPaymentTermList();
            break;
          case EntityType.design:
            action = ViewDesignList();
            break;
          case EntityType.credit:
            action = ViewCreditList();
            break;
        }

        if (action != null) {
          store.dispatch(action);
        }
      });
}

void viewEntity({
  @required BaseEntity entity,
  bool force = false,
  bool addToStack = false,
  BaseEntity filterEntity,
}) =>
    viewEntityById(
      entityId: entity.id,
      entityType: entity.entityType,
      force: force,
      addToStack: addToStack,
      filterEntity: filterEntity,
    );

void viewEntityById({
  @required String entityId,
  @required EntityType entityType,
  bool force = false,
  bool showError = true,
  bool addToStack = false,
  BaseEntity filterEntity,
}) {
  final store = StoreProvider.of<AppState>(navigatorKey.currentContext);
  final state = store.state;
  final uiState = store.state.uiState;

  checkForChanges(
      store: store,
      context: navigatorKey.currentContext,
      force: force,
      callback: () {
        if (addToStack) {
          store.dispatch(PreviewEntity(
            entityId: entityId,
            entityType: entityType,
          ));
          return;
        } else if (state.uiState.previewStack.isNotEmpty) {
          store.dispatch(ClearPreviewStack());
        }

        if (state.prefState.isDesktop && !state.prefState.isPreviewVisible) {
          store.dispatch(TogglePreviewSidebar());
        }

        if (filterEntity != null &&
            (uiState.filterEntityType != filterEntity.entityType ||
                uiState.filterEntityId != filterEntity.id)) {
          store.dispatch(ClearEntitySelection(entityType: entityType));
          store.dispatch(FilterByEntity(entity: filterEntity));
          // If the user selects a different entity of the same type as the current
          // filter then we clear the selection so new records are auto-selected
        } else if (uiState.filterEntityType != null &&
            uiState.filterEntityId != entityId &&
            uiState.filterEntityType == entityType) {
          store.dispatch(FilterByEntity(
            entity: uiState.filterEntity,
            clearSelection: true,
          ));
        }

        if (entityId != null &&
            showError &&
            !store.state.getEntityMap(entityType).containsKey(entityId)) {
          final localization = AppLocalization.of(navigatorKey.currentContext);
          showErrorDialog(
              context: navigatorKey.currentContext,
              message: localization.failedToFindRecord);
          return;
        }

        switch (entityType) {
          case EntityType.client:
            store.dispatch(ViewClient(
              clientId: entityId,
              force: force,
            ));
            break;
          case EntityType.user:
            store.dispatch(ViewUser(
              userId: entityId,
              force: force,
            ));
            break;
          case EntityType.project:
            store.dispatch(ViewProject(
              projectId: entityId,
              force: force,
            ));
            break;
          case EntityType.taxRate:
            store.dispatch(ViewTaxRate(
              taxRateId: entityId,
              force: force,
            ));
            break;
          case EntityType.companyGateway:
            store.dispatch(ViewCompanyGateway(
              companyGatewayId: entityId,
              force: force,
            ));
            break;
          case EntityType.invoice:
            store.dispatch(ViewInvoice(
              invoiceId: entityId,
              force: force,
            ));
            break;
          //case EntityType.recurringInvoice:
          //store.dispatch(ViewRecurringInvoice(recurringInvoiceId: entityId));
          //break;
          case EntityType.quote:
            store.dispatch(ViewQuote(
              quoteId: entityId,
              force: force,
            ));
            break;
          case EntityType.vendor:
            store.dispatch(ViewVendor(
              vendorId: entityId,
              force: force,
            ));
            break;
          case EntityType.product:
            store.dispatch(ViewProduct(
              productId: entityId,
              force: force,
            ));
            break;
          case EntityType.task:
            store.dispatch(ViewTask(
              taskId: entityId,
              force: force,
            ));
            break;
          case EntityType.expense:
            store.dispatch(ViewExpense(
              expenseId: entityId,
              force: force,
            ));
            break;
          //case EntityType.expenseCategory:
          //store.dispatch(ViewExpenseCategory(taxRateId: entityId));
          //break;
          case EntityType.payment:
            store.dispatch(ViewPayment(
              paymentId: entityId,
              force: force,
            ));
            break;
          case EntityType.group:
            store.dispatch(ViewGroup(
              groupId: entityId,
              force: force,
            ));
            break;
          // STARTER: view - do not remove comment
          case EntityType.recurringExpense:
            store.dispatch(ViewRecurringExpense(
              recurringExpenseId: entityId,
              force: force,
            ));
            break;
          case EntityType.subscription:
            store.dispatch(ViewSubscription(
              subscriptionId: entityId,
              force: force,
            ));
            break;
          case EntityType.taskStatus:
            store.dispatch(ViewTaskStatus(
              taskStatusId: entityId,
              force: force,
            ));
            break;
          case EntityType.expenseCategory:
            store.dispatch(ViewExpenseCategory(
              expenseCategoryId: entityId,
              force: force,
            ));
            break;
          case EntityType.recurringInvoice:
            store.dispatch(ViewRecurringInvoice(
              recurringInvoiceId: entityId,
              force: force,
            ));
            break;
          case EntityType.webhook:
            store.dispatch(ViewWebhook(
              webhookId: entityId,
              force: force,
            ));
            break;
          case EntityType.token:
            store.dispatch(ViewToken(
              tokenId: entityId,
              force: force,
            ));
            break;
          case EntityType.paymentTerm:
            store.dispatch(ViewPaymentTerm(
              paymentTermId: entityId,
              force: force,
            ));
            break;
          case EntityType.design:
            store.dispatch(ViewDesign(
              designId: entityId,
              force: force,
            ));
            break;
          case EntityType.credit:
            store.dispatch(ViewCredit(
              creditId: entityId,
              force: force,
            ));
            break;
        }
      });
}

void createEntityByType({
  BuildContext context,
  EntityType entityType,
  bool force = false,
  bool applyFilter = true,
}) {
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;

  if (!state.userCompany.canCreate(entityType)) {
    return;
  }

  checkForChanges(
      store: store,
      context: context,
      force: force,
      callback: () {
        if (state.uiState.previewStack.isNotEmpty) {
          store.dispatch(ClearPreviewStack());
        }

        if (state.prefState.isDesktop &&
            !state.prefState.isEditorFullScreen(entityType)) {
          store.dispatch(ToggleEditorLayout(entityType));
        }

        final filterEntityId = state.uiState.filterEntityId;
        final filterEntityType = state.uiState.filterEntityType;
        ClientEntity client;
        ProjectEntity project;
        VendorEntity vendor;
        UserEntity user;
        GroupEntity group;

        if (applyFilter && filterEntityType != null) {
          switch (filterEntityType) {
            case EntityType.client:
              client = state.clientState.get(filterEntityId);
              break;
            case EntityType.project:
              project = state.projectState.get(filterEntityId);
              client = state.clientState.get(project.clientId);
              break;
            case EntityType.vendor:
              vendor = state.vendorState.get(filterEntityId);
              break;
            case EntityType.user:
              user = state.userState.get(filterEntityId);
              break;
            case EntityType.group:
              group = state.groupState.get(filterEntityId);
              break;
          }
        }

        switch (entityType) {
          case EntityType.client:
            store.dispatch(EditClient(
                client: ClientEntity(
                  state: state,
                  user: user,
                  group: group,
                ),
                force: force));
            break;
          case EntityType.user:
            store.dispatch(EditUser(
              force: force,
              user: UserEntity(
                state: state,
                userCompany: UserCompanyEntity(false),
              ),
            ));
            break;
          case EntityType.project:
            store.dispatch(EditProject(
                force: force,
                project: ProjectEntity(
                  state: state,
                  client: client,
                  user: user,
                )));
            break;
          case EntityType.taxRate:
            store.dispatch(EditTaxRate(
                force: force, taxRate: TaxRateEntity(state: state)));
            break;
          case EntityType.companyGateway:
            store.dispatch(EditCompanyGateway(
                force: force,
                companyGateway: CompanyGatewayEntity(state: state)));
            break;
          case EntityType.invoice:
            store.dispatch(EditInvoice(
              force: force,
              invoice: InvoiceEntity(
                state: state,
                client: client,
                user: user,
              ),
            ));
            break;
          case EntityType.quote:
            store.dispatch(EditQuote(
                force: force,
                quote: InvoiceEntity(
                  state: state,
                  entityType: EntityType.quote,
                  client: client,
                  user: user,
                )));
            break;
          case EntityType.vendor:
            store.dispatch(EditVendor(
                force: force,
                vendor: VendorEntity(
                  state: state,
                  user: user,
                )));
            break;
          case EntityType.product:
            store.dispatch(EditProduct(
                force: force, product: ProductEntity(state: state)));
            break;
          case EntityType.task:
            store.dispatch(EditTask(
              force: force,
              task: TaskEntity(
                state: state,
                client: client,
                project: project,
                user: user,
              ),
            ));
            break;
          case EntityType.expense:
            store.dispatch(EditExpense(
                force: force,
                expense: ExpenseEntity(
                  state: state,
                  client: client,
                  vendor: vendor,
                  user: user,
                  project: project,
                )));
            break;
          case EntityType.payment:
            store.dispatch(EditPayment(
                force: force,
                payment: PaymentEntity(
                  state: state,
                  client: client,
                )));
            break;
          case EntityType.group:
            store.dispatch(EditGroup(
              force: force,
              group: GroupEntity(state: state),
            ));
            break;
          // STARTER: create type - do not remove comment
          case EntityType.recurringExpense:
            store.dispatch(EditRecurringExpense(
              force: force,
              recurringExpense: ExpenseEntity(
                  state: state,
                  client: client,
                  project: project,
                  user: user,
                  vendor: vendor,
                  entityType: EntityType.recurringExpense),
            ));
            break;
          case EntityType.subscription:
            store.dispatch(EditSubscription(
              force: force,
              subscription: SubscriptionEntity(state: state),
            ));
            break;
          case EntityType.taskStatus:
            store.dispatch(EditTaskStatus(
              force: force,
              taskStatus: TaskStatusEntity(state: state),
            ));
            break;
          case EntityType.expenseCategory:
            store.dispatch(EditExpenseCategory(
              force: force,
              expenseCategory: ExpenseCategoryEntity(state: state),
            ));
            break;
          case EntityType.recurringInvoice:
            store.dispatch(EditRecurringInvoice(
              force: force,
              recurringInvoice: InvoiceEntity(
                state: state,
                entityType: EntityType.recurringInvoice,
                client: client,
                user: user,
              ),
            ));
            break;
          case EntityType.webhook:
            store.dispatch(EditWebhook(
              force: force,
              webhook: WebhookEntity(state: state),
            ));
            break;
          case EntityType.token:
            store.dispatch(EditToken(
              force: force,
              token: TokenEntity(state: state),
            ));
            break;
          case EntityType.paymentTerm:
            store.dispatch(EditPaymentTerm(
              force: force,
              paymentTerm: PaymentTermEntity(state: state),
            ));
            break;
          case EntityType.design:
            store.dispatch(EditDesign(
              force: force,
              design: DesignEntity(state: state),
            ));
            break;
          case EntityType.credit:
            store.dispatch(EditCredit(
              force: force,
              credit: InvoiceEntity(
                state: state,
                entityType: EntityType.credit,
                user: user,
                client: client,
              ),
            ));
            break;
        }
      });
}

void createEntity({
  BuildContext context,
  BaseEntity entity,
  bool force = false,
  BaseEntity filterEntity,
  Completer completer,
  Completer cancelCompleter,
}) {
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final uiState = state.uiState;

  if (!state.userCompany.canCreate(entity.entityType)) {
    return;
  }

  checkForChanges(
      store: store,
      context: context,
      force: force,
      callback: () {
        if (filterEntity != null &&
            uiState.filterEntityType != filterEntity.entityType &&
            uiState.filterEntityId != filterEntity.id) {
          filterByEntity(
            context: context,
            entity: filterEntity,
          );
        }

        if (uiState.previewStack.isNotEmpty) {
          store.dispatch(ClearPreviewStack());
        }

        if (state.prefState.isDesktop &&
            !state.prefState.isEditorFullScreen(entity.entityType)) {
          store.dispatch(ToggleEditorLayout(entity.entityType));
        }

        switch (entity.entityType) {
          case EntityType.client:
            store.dispatch(EditClient(
              client: entity,
              force: force,
              completer: completer,
              cancelCompleter: cancelCompleter,
            ));
            break;
          case EntityType.user:
            store.dispatch(EditUser(
              user: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.project:
            store.dispatch(EditProject(
              project: entity,
              force: force,
              completer: completer,
              cancelCompleter: cancelCompleter,
            ));
            break;
          case EntityType.taxRate:
            store.dispatch(EditTaxRate(
              taxRate: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.companyGateway:
            store.dispatch(EditCompanyGateway(
              companyGateway: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.invoice:
            store.dispatch(EditInvoice(
              invoice: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.quote:
            store.dispatch(EditQuote(
              quote: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.vendor:
            store.dispatch(EditVendor(
              vendor: entity,
              force: force,
              completer: completer,
              cancelCompleter: cancelCompleter,
            ));
            break;
          case EntityType.product:
            store.dispatch(EditProduct(
              product: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.task:
            store.dispatch(EditTask(
              task: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.expense:
            store.dispatch(EditExpense(
              expense: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.payment:
            store.dispatch(EditPayment(
              payment: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.group:
            store.dispatch(EditGroup(
              group: entity,
              force: force,
              completer: completer,
            ));
            break;
          // STARTER: create - do not remove comment
          case EntityType.recurringExpense:
            store.dispatch(EditRecurringExpense(
              recurringExpense: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.subscription:
            store.dispatch(EditSubscription(
              subscription: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.taskStatus:
            store.dispatch(EditTaskStatus(
              taskStatus: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.expenseCategory:
            store.dispatch(EditExpenseCategory(
              expenseCategory: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.recurringInvoice:
            store.dispatch(EditRecurringInvoice(
              recurringInvoice: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.webhook:
            store.dispatch(EditWebhook(
              webhook: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.token:
            store.dispatch(EditToken(
              token: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.paymentTerm:
            store.dispatch(EditPaymentTerm(
              paymentTerm: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.design:
            store.dispatch(EditDesign(
              design: entity,
              force: force,
              completer: completer,
            ));
            break;
          case EntityType.credit:
            store.dispatch(EditCredit(
              credit: entity,
              force: force,
              completer: completer,
            ));
            break;
        }
      });
}

void editEntity({
  @required BuildContext context,
  @required BaseEntity entity,
  int subIndex,
  bool force = false,
  bool fullScreen = true,
  Completer completer,
}) {
  final store = StoreProvider.of<AppState>(context);
  final state = store.state;
  final localization = AppLocalization.of(context);
  final entityType = entity.entityType;

  checkForChanges(
      store: store,
      context: context,
      force: force,
      callback: () {
        if (state.prefState.isDesktop) {
          final isFullScreen = state.prefState.isEditorFullScreen(entityType);
          if (isFullScreen && !fullScreen || !isFullScreen && fullScreen) {
            store.dispatch(ToggleEditorLayout(entityType));
          }
        }

        switch (entityType) {
          case EntityType.client:
            store.dispatch(EditClient(
              client: entity,
              completer: completer,
            ));
            break;
          case EntityType.user:
            store.dispatch(EditUser(
              user: entity,
              completer: completer,
            ));
            break;
          case EntityType.project:
            store.dispatch(EditProject(project: entity, completer: completer));
            break;
          case EntityType.taxRate:
            store.dispatch(EditTaxRate(taxRate: entity, completer: completer));
            break;
          case EntityType.companyGateway:
            store.dispatch(EditCompanyGateway(
                companyGateway: entity, completer: completer));
            break;
          case EntityType.invoice:
            final invoice = entity as InvoiceEntity;
            final client = state.clientState.get(invoice.clientId);
            final settings = getClientSettings(state, client);

            if (settings.lockInvoices == SettingsEntity.LOCK_INVOICES_PAID &&
                invoice.isPaid) {
              showMessageDialog(
                  context: context,
                  message: localization.paidInvoicesArelocked);
            } else if (settings.lockInvoices ==
                    SettingsEntity.LOCK_INVOICES_SENT &&
                invoice.isSent) {
              showMessageDialog(
                  context: context,
                  message: localization.sentInvoicesArelocked);
            } else {
              store.dispatch(EditInvoice(
                invoice: entity,
                completer: completer,
                invoiceItemIndex: subIndex,
              ));
            }
            break;
          case EntityType.quote:
            store.dispatch(EditQuote(
              quote: entity,
              completer: completer,
              quoteItemIndex: subIndex,
            ));
            break;
          case EntityType.vendor:
            store.dispatch(EditVendor(
              vendor: entity,
              completer: completer,
            ));
            break;
          case EntityType.product:
            store.dispatch(EditProduct(product: entity, completer: completer));
            break;
          case EntityType.task:
            store.dispatch(EditTask(
              task: (entity as TaskEntity).rebuild(
                  (b) => b..showAsRunning = (entity as TaskEntity).isRunning),
              taskTimeIndex: subIndex,
              completer: completer,
            ));
            break;
          case EntityType.expense:
            store.dispatch(
              EditExpense(expense: entity, completer: completer),
            );
            break;
          case EntityType.payment:
            store.dispatch(EditPayment(
              payment: entity,
              completer: completer,
            ));
            break;
          case EntityType.group:
            store.dispatch(EditGroup(
              group: entity,
              completer: completer,
            ));
            break;
          // STARTER: edit - do not remove comment
          case EntityType.recurringExpense:
            store.dispatch(EditRecurringExpense(
                recurringExpense: entity, completer: completer));
            break;
          case EntityType.subscription:
            store.dispatch(
                EditSubscription(subscription: entity, completer: completer));
            break;
          case EntityType.taskStatus:
            store.dispatch(EditTaskStatus(
              taskStatus: entity,
              completer: completer,
            ));
            break;
          case EntityType.expenseCategory:
            store.dispatch(EditExpenseCategory(
              expenseCategory: entity,
              completer: completer,
            ));
            break;
          case EntityType.recurringInvoice:
            store.dispatch(EditRecurringInvoice(
              recurringInvoice: entity,
              completer: completer,
            ));
            break;
          case EntityType.webhook:
            store.dispatch(EditWebhook(
              webhook: entity,
              completer: completer,
            ));
            break;
          case EntityType.token:
            store.dispatch(EditToken(
              token: entity,
              completer: completer,
            ));
            break;
          case EntityType.paymentTerm:
            store.dispatch(EditPaymentTerm(
              paymentTerm: entity,
              completer: completer,
            ));
            break;
          case EntityType.design:
            store.dispatch(EditDesign(
              design: entity,
              completer: completer,
            ));
            break;
          case EntityType.credit:
            store.dispatch(EditCredit(
              credit: entity,
              completer: completer,
            ));
            break;
        }
      });
}

void handleEntityAction(BaseEntity entity, EntityAction action,
    {bool autoPop = false}) {
  handleEntitiesActions([entity], action, autoPop: autoPop);
}

void handleEntitiesActions(List<BaseEntity> entities, EntityAction action,
    {bool autoPop = false}) {
  if (entities.isEmpty) {
    return;
  }

  if ([
        EntityAction.archive,
        EntityAction.delete,
        EntityAction.remove,
      ].contains(action) &&
      autoPop) {
    if (isMobile(navigatorKey.currentContext)) {
      navigatorKey.currentState.pop();
    } else if (entities.first.entityType.isSetting) {
      final store = StoreProvider.of<AppState>(navigatorKey.currentContext);
      switch (entities.first.entityType) {
        case EntityType.paymentTerm:
          store.dispatch(UpdateCurrentRoute(PaymentTermScreen.route));
          break;
        case EntityType.taxRate:
          store.dispatch(UpdateCurrentRoute(TaxRateSettingsScreen.route));
          break;
        case EntityType.companyGateway:
          store.dispatch(UpdateCurrentRoute(CompanyGatewayScreen.route));
          break;
        case EntityType.user:
          store.dispatch(UpdateCurrentRoute(UserScreen.route));
          break;
        case EntityType.group:
          store.dispatch(UpdateCurrentRoute(GroupSettingsScreen.route));
          break;
        case EntityType.design:
          store.dispatch(UpdateCurrentRoute(DesignScreen.route));
          break;
        case EntityType.token:
          store.dispatch(UpdateCurrentRoute(TokenScreen.route));
          break;
        case EntityType.webhook:
          store.dispatch(UpdateCurrentRoute(WebhookScreen.route));
          break;
        case EntityType.expenseCategory:
          store.dispatch(UpdateCurrentRoute(ExpenseCategoryScreen.route));
          break;
        case EntityType.taskStatus:
          store.dispatch(UpdateCurrentRoute(TaskStatusScreen.route));
          break;
        case EntityType.subscription:
          store.dispatch(UpdateCurrentRoute(SubscriptionScreen.route));
          break;
        default:
          print(
              'ERROR: ${entities.first.entityType} entity type not supported');
      }
    }
  }

  final context = navigatorKey.currentContext;
  switch (entities.first.entityType) {
    case EntityType.client:
      handleClientAction(context, entities, action);
      break;
    case EntityType.product:
      handleProductAction(context, entities, action);
      break;
    case EntityType.invoice:
      handleInvoiceAction(context, entities, action);
      break;
    case EntityType.payment:
      handlePaymentAction(context, entities, action);
      break;
    case EntityType.quote:
      handleQuoteAction(context, entities, action);
      break;
    case EntityType.task:
      handleTaskAction(context, entities, action);
      break;
    case EntityType.project:
      handleProjectAction(context, entities, action);
      break;
    case EntityType.expense:
      handleExpenseAction(context, entities, action);
      break;
    case EntityType.vendor:
      handleVendorAction(context, entities, action);
      break;
    case EntityType.user:
      handleUserAction(context, entities, action);
      break;
    case EntityType.companyGateway:
      handleCompanyGatewayAction(context, entities, action);
      break;
    case EntityType.taxRate:
      handleTaxRateAction(context, entities, action);
      break;
    case EntityType.group:
      handleGroupAction(context, entities, action);
      break;
    case EntityType.document:
      handleDocumentAction(context, entities, action);
      break;
    // STARTER: actions - do not remove comment
    case EntityType.recurringExpense:
      handleRecurringExpenseAction(context, entities, action);
      break;
    case EntityType.subscription:
      handleSubscriptionAction(context, entities, action);
      break;
    case EntityType.taskStatus:
      handleTaskStatusAction(context, entities, action);
      break;
    case EntityType.expenseCategory:
      handleExpenseCategoryAction(context, entities, action);
      break;
    case EntityType.recurringInvoice:
      handleRecurringInvoiceAction(context, entities, action);
      break;
    case EntityType.webhook:
      handleWebhookAction(context, entities, action);
      break;
    case EntityType.token:
      handleTokenAction(context, entities, action);
      break;
    case EntityType.paymentTerm:
      handlePaymentTermAction(context, entities, action);
      break;
    case EntityType.design:
      handleDesignAction(context, entities, action);
      break;
    case EntityType.credit:
      handleCreditAction(context, entities, action);
      break;
    default:
      print(
          'Error: unhandled type ${entities.first.entityType} in handleEntitiesActions');
  }
}

void selectEntity({
  @required BuildContext context,
  @required BaseEntity entity,
  bool longPress = false,
  bool forceView = false,
  BaseEntity filterEntity,
}) {
  final store = StoreProvider.of<AppState>(navigatorKey.currentContext);
  final state = store.state;
  final uiState = state.uiState;
  final entityUIState = state.getUIState(entity.entityType);
  final isInMultiselect =
      state.getListState(entity.entityType).isInMultiselect();

  if (longPress == true) {
    final longPressIsSelection =
        (state.prefState.longPressSelectionIsDefault ?? true) ||
            state.prefState.moduleLayout == ModuleLayout.table;
    if (longPressIsSelection &&
        state.uiState.currentRoute != DashboardScreenBuilder.route) {
      handleEntityAction(entity, EntityAction.toggleMultiselect);
    } else {
      editEntity(context: context, entity: entity);
    }
  } else if (isInMultiselect && forceView != true) {
    handleEntityAction(entity, EntityAction.toggleMultiselect);
  } else if (isDesktop(context) && !state.prefState.isPreviewVisible) {
    if (uiState.isEditing && entityUIState.editingId == entity.id) {
      viewEntitiesByType(entityType: entity.entityType);
    } else {
      if (!state.prefState.isPreviewVisible) {
        store.dispatch(TogglePreviewSidebar());
      }
      viewEntity(entity: entity);
    }
  } else if (isDesktop(context) &&
      (uiState.isEditing || uiState.previewStack.isNotEmpty)) {
    viewEntity(entity: entity);
  } else if (isDesktop(context) &&
      !forceView &&
      uiState.isViewing &&
      !entity.entityType.isSetting &&
      entityUIState.selectedId == entity.id) {
    if (entityUIState.tabIndex > 0) {
      store.dispatch(PreviewEntity());
    } else if (state.prefState.tapSelectedToEdit) {
      editEntity(context: context, entity: entity);
    } else if (state.prefState.isModuleTable) {
      store.dispatch(TogglePreviewSidebar());
    }
  } else {
    ClientEntity client;
    if (forceView && entity is BelongsToClient) {
      client = state.clientState.get((entity as BelongsToClient).clientId);
    }

    viewEntity(entity: entity, filterEntity: client);
  }
}

void inspectEntity({
  BaseEntity entity,
  bool longPress = false,
}) {
  final store = StoreProvider.of<AppState>(navigatorKey.currentContext);
  final state = store.state;
  final previewStack = state.uiState.previewStack;

  if (isDesktop(navigatorKey.currentContext)) {
    if (longPress) {
      viewEntity(entity: entity);
    } else if (previewStack.isNotEmpty) {
      final entityType = previewStack.last;
      viewEntityById(
        filterEntity: entity,
        entityType: entityType,
        entityId: state.getUIState(entityType).selectedId,
      );
    } else {
      store.dispatch(FilterByEntity(entity: entity));
    }
  } else {
    if (longPress) {
      showEntityActionsDialog(entities: [entity]);
    } else {
      viewEntity(entity: entity);
    }
  }
}

void checkForChanges({
  @required Store<AppState> store,
  @required BuildContext context,
  @required Function callback,
  bool force = false,
}) {
  if (context == null) {
    print('WARNING: context is null in hasChanges');
    return;
  }

  if (force) {
    store.dispatch(DiscardChanges());
    store.dispatch(ResetSettings());
    callback();
  } else if (store.state.hasChanges() && !isMobile(context)) {
    showDialog<MessageDialog>(
        context: context,
        builder: (BuildContext dialogContext) {
          final localization = AppLocalization.of(context);
          return MessageDialog(localization.errorUnsavedChanges,
              dismissLabel: localization.continueEditing, onDiscard: () {
            store.dispatch(DiscardChanges());
            store.dispatch(ResetSettings());
            callback();
          });
        });
  } else {
    callback();
  }
}
