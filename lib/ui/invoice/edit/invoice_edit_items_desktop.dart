// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Project imports:
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/product/product_selectors.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/ui/app/app_border.dart';
import 'package:invoiceninja_flutter/ui/app/entity_dropdown.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/custom_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/decorated_form_field.dart';
import 'package:invoiceninja_flutter/ui/app/forms/growable_form_field.dart';
import 'package:invoiceninja_flutter/ui/app/icon_text.dart';
import 'package:invoiceninja_flutter/ui/app/invoice/tax_rate_dropdown.dart';
import 'package:invoiceninja_flutter/ui/app/scrollable_listview.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_items_vm.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_vm.dart';
import 'package:invoiceninja_flutter/utils/colors.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class InvoiceEditItemsDesktop extends StatefulWidget {
  const InvoiceEditItemsDesktop({
    @required this.viewModel,
    @required this.entityViewModel,
    @required this.isTasks,
  });

  final EntityEditItemsVM viewModel;
  final AbstractInvoiceEditVM entityViewModel;
  final bool isTasks;

  @override
  _InvoiceEditItemsDesktopState createState() =>
      _InvoiceEditItemsDesktopState();
}

class _InvoiceEditItemsDesktopState extends State<InvoiceEditItemsDesktop> {
  static const COLUMN_ITEM = 'item';
  static const COLUMN_DESCRIPTION = 'description';
  static const COLUMN_UNIT_COST = 'unit_cost';
  static const COLUMN_QUANTITY = 'quantity';
  static const COLUMN_CUSTOM1 = 'custom1';
  static const COLUMN_CUSTOM2 = 'custom2';
  static const COLUMN_CUSTOM3 = 'custom3';
  static const COLUMN_CUSTOM4 = 'custom4';
  static const COLUMN_TAX1 = 'tax1';
  static const COLUMN_TAX2 = 'tax2';
  static const COLUMN_TAX3 = 'tax3';
  static const COLUMN_DISCOUNT = 'discount';

  final _debouncer = Debouncer();
  TextEditingController _textEditingController;
  bool _isReordering = false;
  int _updatedAt;
  int _autocompleteFocusIndex = -1;
  final _columns = <String>[];

  @override
  void initState() {
    super.initState();

    _updateColumns();
  }

  void _updateColumns() {
    final viewModel = widget.viewModel;
    final lineItems = viewModel.invoice.lineItems;
    final state = viewModel.state;
    final company = state.company;

    final includedLineItems = lineItems.where((lineItem) {
      return (lineItem.typeId == InvoiceItemEntity.TYPE_TASK &&
              widget.isTasks) ||
          (lineItem.typeId != InvoiceItemEntity.TYPE_TASK && !widget.isTasks) ||
          lineItem.isEmpty;
    }).toList();

    final hasTax1 = company.enableFirstItemTaxRate ||
        includedLineItems.any((item) => item.taxName1.isNotEmpty);
    final hasTax2 = company.enableSecondItemTaxRate ||
        includedLineItems.any((item) => item.taxName2.isNotEmpty);
    final hasTax3 = company.enableThirdItemTaxRate ||
        includedLineItems.any((item) => item.taxName3.isNotEmpty);
    final hasAnyTax = hasTax1 || hasTax2 || hasTax3;

    final customField1 =
        widget.isTasks ? CustomFieldType.task1 : CustomFieldType.product1;
    final customField2 =
        widget.isTasks ? CustomFieldType.task2 : CustomFieldType.product2;
    final customField3 =
        widget.isTasks ? CustomFieldType.task3 : CustomFieldType.product3;
    final customField4 =
        widget.isTasks ? CustomFieldType.task4 : CustomFieldType.product4;

    List<String> pdfColumns = company.settings
        .getFieldsForSection(
            widget.isTasks ? kPdfFieldsTaskColumns : kPdfFieldsProductColumns)
        .map((value) => value.split('.')[1])
        .toList();

    if (widget.isTasks) {
      if (pdfColumns.isEmpty) {
        pdfColumns = [
          TaskItemFields.service,
          TaskItemFields.description,
          TaskItemFields.rate,
          TaskItemFields.hours,
        ];
      } else {
        if (!pdfColumns.contains(TaskItemFields.service)) {
          pdfColumns = [TaskItemFields.service, ...pdfColumns];
        }
        if (!pdfColumns.contains(TaskItemFields.rate)) {
          pdfColumns = [...pdfColumns, TaskItemFields.rate];
        }
        if (!pdfColumns.contains(TaskItemFields.hours)) {
          pdfColumns = [...pdfColumns, TaskItemFields.hours];
        }
      }
    } else {
      if (pdfColumns.isEmpty) {
        pdfColumns = [
          ProductItemFields.item,
          ProductItemFields.description,
          ProductItemFields.unitCost,
          ProductItemFields.quantity,
        ];
      } else {
        if (!pdfColumns.contains(ProductItemFields.item)) {
          pdfColumns = [ProductItemFields.item, ...pdfColumns];
        }
        if (!pdfColumns.contains(ProductItemFields.unitCost)) {
          pdfColumns = [...pdfColumns, ProductItemFields.unitCost];
        }
        if (!pdfColumns.contains(ProductItemFields.quantity) &&
            company.enableProductQuantity) {
          pdfColumns = [...pdfColumns, ProductItemFields.quantity];
        }
      }
    }

    if (hasAnyTax && !pdfColumns.contains(ProductItemFields.tax)) {
      pdfColumns = [...pdfColumns, ProductItemFields.tax];
    }

    if (company.hasCustomField(customField1) &&
        !pdfColumns.contains(customField1)) {
      pdfColumns.add(customField1);
    }
    if (company.hasCustomField(customField2) &&
        !pdfColumns.contains(customField2)) {
      pdfColumns.add(customField2);
    }
    if (company.hasCustomField(customField3) &&
        !pdfColumns.contains(customField3)) {
      pdfColumns.add(customField3);
    }
    if (company.hasCustomField(customField4) &&
        !pdfColumns.contains(customField4)) {
      pdfColumns.add(customField4);
    }

    _columns.clear();

    for (var column in pdfColumns) {
      if (ProductItemFields.item == column ||
          TaskItemFields.service == column) {
        _columns.add(COLUMN_ITEM);
      } else if (ProductItemFields.description == column) {
        _columns.add(COLUMN_DESCRIPTION);
      } else if (ProductItemFields.unitCost == column ||
          TaskItemFields.rate == column) {
        _columns.add(COLUMN_UNIT_COST);
      } else if ((ProductItemFields.quantity == column ||
              TaskItemFields.hours == column) &&
          (company.enableProductQuantity || widget.isTasks)) {
        _columns.add(COLUMN_QUANTITY);
      } else if ((ProductItemFields.custom1 == column ||
              TaskItemFields.custom1 == column) &&
          company.hasCustomField(customField1)) {
        _columns.add(COLUMN_CUSTOM1);
      } else if ((ProductItemFields.custom2 == column ||
              TaskItemFields.custom2 == column) &&
          company.hasCustomField(customField2)) {
        _columns.add(COLUMN_CUSTOM2);
      } else if ((ProductItemFields.custom3 == column ||
              TaskItemFields.custom3 == column) &&
          company.hasCustomField(customField3)) {
        _columns.add(COLUMN_CUSTOM3);
      } else if ((ProductItemFields.custom4 == column ||
              TaskItemFields.custom4 == column) &&
          company.hasCustomField(customField4)) {
        _columns.add(COLUMN_CUSTOM4);
      } else if (ProductItemFields.tax == column) {
        if (hasTax1) {
          _columns.add(COLUMN_TAX1);
        }
        if (hasTax2) {
          _columns.add(COLUMN_TAX2);
        }
        if (hasTax3) {
          _columns.add(COLUMN_TAX3);
        }
      } else if (ProductItemFields.discount == column &&
          company.enableProductDiscount) {
        _columns.add(COLUMN_DISCOUNT);
      }
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isTasks != widget.isTasks) {
      _isReordering = false;
      _updateColumns();
    }
  }

  void _updateTable() {
    setState(() {
      _updatedAt = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _onChanged(
    InvoiceItemEntity lineItem,
    int index, {
    bool debounce = true,
  }) {
    final viewModel = widget.viewModel;
    final lineItems = viewModel.invoice.lineItems;

    if (index == lineItems.length) {
      viewModel.onChangedInvoiceItem(lineItem, index);
    } else if (lineItem != lineItems[index]) {
      if (debounce) {
        _debouncer.run(() {
          viewModel.onChangedInvoiceItem(lineItem, index);
        });
      } else {
        viewModel.onChangedInvoiceItem(lineItem, index);
      }
    }
  }

  void _onFocusChange() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      Debouncer.complete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    final viewModel = widget.viewModel;
    final state = viewModel.state;
    final company = state.company;

    final invoice = viewModel.invoice;
    final client = state.clientState.get(invoice.clientId);
    final precision =
        state.staticState.currencyMap[client.currencyId]?.precision ?? 2;
    final lineItems = invoice.lineItems.toList();
    final includedLineItems = lineItems.where((lineItem) {
      return (lineItem.typeId == InvoiceItemEntity.TYPE_TASK &&
              widget.isTasks) ||
          (lineItem.typeId != InvoiceItemEntity.TYPE_TASK && !widget.isTasks) ||
          lineItem.isEmpty;
    }).toList();
    final productState = state.productState;
    final productIds = memoizedDropdownProductList(
        productState.map, productState.list, state.userState.map);

    final customField1 =
        widget.isTasks ? CustomFieldType.task1 : CustomFieldType.product1;
    final customField2 =
        widget.isTasks ? CustomFieldType.task2 : CustomFieldType.product2;
    final customField3 =
        widget.isTasks ? CustomFieldType.task3 : CustomFieldType.product3;
    final customField4 =
        widget.isTasks ? CustomFieldType.task4 : CustomFieldType.product4;

    final tableFontColor = state.prefState
            .customColors[PrefState.THEME_INVOICE_HEADER_FONT_COLOR] ??
        '';

    final tableHeaderColor = state.prefState
            .customColors[PrefState.THEME_INVOICE_HEADER_BACKGROUND_COLOR] ??
        '';

    final tableHeaderColumns = <Widget>[];

    for (var i = 0; i < _columns.length; i++) {
      final column = _columns[i];
      String label = '';
      bool isNumeric = false;
      if (column == COLUMN_ITEM) {
        label = localization.item;
      } else if (column == COLUMN_DESCRIPTION) {
        label = localization.description;
      } else if (column == COLUMN_CUSTOM1) {
        label = company.getCustomFieldLabel(customField1);
      } else if (column == COLUMN_CUSTOM2) {
        label = company.getCustomFieldLabel(customField2);
      } else if (column == COLUMN_CUSTOM3) {
        label = company.getCustomFieldLabel(customField3);
      } else if (column == COLUMN_CUSTOM4) {
        label = company.getCustomFieldLabel(customField4);
      } else if ([COLUMN_TAX1, COLUMN_TAX2, COLUMN_TAX3].contains(column)) {
        label = localization.tax +
            (company.settings.enableInclusiveTaxes
                ? ' - ${localization.inclusive}'
                : '');
      } else if (column == COLUMN_QUANTITY) {
        label = widget.isTasks ? localization.hours : localization.quantity;
        isNumeric = true;
      } else if (column == COLUMN_UNIT_COST) {
        label = widget.isTasks ? localization.rate : localization.unitCost;
        isNumeric = true;
      } else if (column == COLUMN_DISCOUNT) {
        label = localization.discount;
        isNumeric = true;
      }
      tableHeaderColumns.add(TableHeader(
        label,
        isFirst: i == 0,
        isNumeric: isNumeric,
      ));
    }

    if (_isReordering) {
      return FormCard(
        padding: const EdgeInsets.symmetric(horizontal: kMobileDialogPadding),
        children: [
          DecoratedBox(
            decoration: tableHeaderColor.isNotEmpty
                ? BoxDecoration(
                    color: convertHexStringToColor(tableHeaderColor),
                  )
                : BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                ...tableHeaderColumns
                    .map((widget) => Expanded(child: widget))
                    .toList(),
                Expanded(
                  child: TableHeader(
                    localization.lineTotal,
                    isNumeric: true,
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                    color: tableFontColor.isNotEmpty
                        ? convertHexStringToColor(tableFontColor)
                        : null,
                    onPressed: () {
                      setState(() => _isReordering = false);
                    },
                    icon: Icon(Icons.close))
              ],
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            primary: false,
            buildDefaultDragHandles: false,
            itemCount: lineItems.length,
            itemBuilder: (context, index) {
              final item = lineItems[index];

              if ((item.typeId == InvoiceItemEntity.TYPE_TASK &&
                      !widget.isTasks) ||
                  (item.typeId != InvoiceItemEntity.TYPE_TASK &&
                      widget.isTasks)) {
                return SizedBox(key: ObjectKey(item));
              }

              return ReorderableDragStartListener(
                index: index,
                key: ObjectKey(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ..._columns
                          .map((column) {
                            if (column == COLUMN_ITEM) {
                              return Text(item.productKey ?? '');
                            } else if (column == COLUMN_DESCRIPTION) {
                              return Text(
                                item.notes ?? '',
                                maxLines: 2, // TODO change to 1
                                overflow: TextOverflow.ellipsis,
                              );
                            } else if (column == COLUMN_CUSTOM1) {
                              return Text(item.customValue1 ?? '');
                            } else if (column == COLUMN_CUSTOM2) {
                              return Text(item.customValue2 ?? '');
                            } else if (column == COLUMN_CUSTOM3) {
                              return Text(item.customValue3 ?? '');
                            } else if (column == COLUMN_CUSTOM4) {
                              return Text(item.customValue4 ?? '');
                            } else if (column == COLUMN_TAX1) {
                              return Text(item.taxName1 ?? '');
                            } else if (column == COLUMN_TAX2) {
                              return Text(item.taxName2 ?? '');
                            } else if (column == COLUMN_TAX3) {
                              return Text(item.taxName3 ?? '');
                            } else if (column == COLUMN_UNIT_COST) {
                              return Text(
                                formatNumber(item.cost, context,
                                        formatNumberType:
                                            FormatNumberType.inputMoney,
                                        clientId: invoice.clientId) ??
                                    '',
                                textAlign: TextAlign.right,
                              );
                            } else if (column == COLUMN_QUANTITY) {
                              return Text(
                                formatNumber(item.quantity, context,
                                        formatNumberType:
                                            FormatNumberType.inputAmount,
                                        clientId: invoice.clientId) ??
                                    '',
                                textAlign: TextAlign.right,
                              );
                            } else if (column == COLUMN_DISCOUNT) {
                              return Text(
                                formatNumber(item.discount, context,
                                        formatNumberType:
                                            FormatNumberType.inputAmount,
                                        clientId: invoice.clientId) ??
                                    '',
                                textAlign: TextAlign.right,
                              );
                            }
                          })
                          .map((widget) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: kTableColumnGap),
                                  child: widget,
                                ),
                              ))
                          .toList(),
                      Expanded(
                        child: Text(
                          formatNumber(item.total(invoice, precision), context,
                                  clientId: invoice.clientId) ??
                              '',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.drag_handle),
                      )
                    ],
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              // https://stackoverflow.com/a/54164333/497368
              // These two lines are workarounds for ReorderableListView problems
              if (newIndex > lineItems.length) {
                newIndex = lineItems.length;
              }

              if (oldIndex < newIndex) {
                newIndex--;
              }

              viewModel.onMovedInvoiceItem(oldIndex, newIndex);
            },
          )
        ],
      );
    }

    if (lineItems.where((item) => item.isEmpty).isEmpty) {
      lineItems
          .add(InvoiceItemEntity(quantity: company.defaultQuantity ? 1 : 0));
    }

    tableHeaderColumns.addAll([
      TableHeader(
        localization.lineTotal,
        isNumeric: true,
      ),
      IconButton(
        icon: Icon(Icons.swap_vert),
        color: tableFontColor.isNotEmpty
            ? convertHexStringToColor(tableFontColor)
            : null,
        onPressed: includedLineItems.where((item) => !item.isEmpty).length < 2
            ? null
            : () {
                setState(() => _isReordering = !_isReordering);
              },
      )
    ]);

    return FormCard(
      padding: const EdgeInsets.symmetric(horizontal: kMobileDialogPadding),
      child: Table(
        columnWidths: {
          _columns.indexOf(COLUMN_ITEM): FlexColumnWidth(1.3),
          _columns.indexOf(COLUMN_DESCRIPTION): FlexColumnWidth(2.2),
          _columns.length + 1: FixedColumnWidth(40),
        },
        // TODO change to top once we can set maxLines to 2
        defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
        key: ValueKey('__datatable_${_updatedAt}__'),
        children: [
          TableRow(
            children: tableHeaderColumns,
            decoration: tableHeaderColor.isNotEmpty
                ? BoxDecoration(
                    color: convertHexStringToColor(tableHeaderColor),
                  )
                : BoxDecoration(),
          ),
          for (var index = 0; index < lineItems.length; index++)
            if ((lineItems[index].typeId == InvoiceItemEntity.TYPE_TASK &&
                    widget.isTasks) ||
                (lineItems[index].typeId != InvoiceItemEntity.TYPE_TASK &&
                    !widget.isTasks) ||
                lineItems[index].isEmpty)
              TableRow(
                  key: ValueKey(
                      '__line_item_${index}_${lineItems[index].createdAt}__'),
                  children: [
                    ..._columns.map((column) {
                      if (column == COLUMN_ITEM) {
                        return Focus(
                          onFocusChange: (hasFocus) {
                            _autocompleteFocusIndex = index;
                            _onFocusChange();
                          },
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: RawAutocomplete<ProductEntity>(
                              key: ValueKey('__line_item_${index}_name__'),
                              textEditingController: _textEditingController,
                              initialValue: TextEditingValue(
                                  text: lineItems[index].productKey),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                final options = productIds
                                    .map((productId) =>
                                        productState.map[productId])
                                    .where((product) => product.productKey
                                        .toLowerCase()
                                        .contains(textEditingValue.text
                                            .toLowerCase()))
                                    .toList();

                                if (options.length == 1 &&
                                    options[0].productKey.toLowerCase() ==
                                        lineItems[index]
                                            .productKey
                                            .toLowerCase()) {
                                  return <ProductEntity>[];
                                }

                                return options;
                              },
                              displayStringForOption: (product) =>
                                  product.productKey,
                              onSelected: (product) {
                                final item = lineItems[index];
                                final client =
                                    state.clientState.get(invoice.clientId);
                                final currency = state
                                    .staticState.currencyMap[client.currencyId];

                                double cost = product.price;
                                if (company.convertProductExchangeRate &&
                                    invoice.clientId != null &&
                                    client.currencyId != company.currencyId) {
                                  double exchangeRate = invoice.exchangeRate;
                                  if (!company.convertRateToClient &&
                                      exchangeRate != 0) {
                                    exchangeRate = 1 / exchangeRate;
                                  }
                                  cost = round(cost * exchangeRate,
                                      currency?.precision ?? 2);
                                }

                                final updatedItem = item.rebuild((b) => b
                                  ..productKey = product.productKey
                                  ..notes =
                                      item.isTask ? item.notes : product.notes
                                  ..productCost = item.productCost
                                  ..cost = item.isTask && item.cost != 0
                                      ? item.cost
                                      : cost
                                  ..quantity = item.isTask || item.quantity != 0
                                      ? item.quantity
                                      : viewModel.state.company.defaultQuantity
                                          ? 1
                                          : product.quantity
                                  ..customValue1 = product.customValue1
                                  ..customValue2 = product.customValue2
                                  ..customValue3 = product.customValue3
                                  ..customValue4 = product.customValue4
                                  ..taxName1 =
                                      company.numberOfItemTaxRates >= 1 &&
                                              product.taxName1.isNotEmpty
                                          ? product.taxName1
                                          : item.taxName1
                                  ..taxRate1 =
                                      company.numberOfItemTaxRates >= 1 &&
                                              product.taxName1.isNotEmpty
                                          ? product.taxRate1
                                          : item.taxRate1
                                  ..taxName2 =
                                      company.numberOfItemTaxRates >= 2 &&
                                              product.taxName2.isNotEmpty
                                          ? product.taxName2
                                          : item.taxName2
                                  ..taxRate2 =
                                      company.numberOfItemTaxRates >= 2 &&
                                              product.taxName2.isNotEmpty
                                          ? product.taxRate2
                                          : item.taxRate2
                                  ..taxName3 =
                                      company.numberOfItemTaxRates >= 3 &&
                                              product.taxName3.isNotEmpty
                                          ? product.taxName3
                                          : item.taxName3
                                  ..taxRate3 =
                                      company.numberOfItemTaxRates >= 3 &&
                                              product.taxName3.isNotEmpty
                                          ? product.taxRate3
                                          : item.taxRate3);
                                _onChanged(updatedItem, index, debounce: false);
                                _updateTable();
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return DecoratedFormField(
                                  showClear: false,
                                  autofocus: false,
                                  controller: textEditingController,
                                  keyboardType: TextInputType.text,
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  onChanged: (value) {
                                    _onChanged(
                                        lineItems[index].rebuild(
                                            (b) => b..productKey = value),
                                        index);
                                  },
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<ProductEntity>
                                      onSelected,
                                  Iterable<SelectableEntity> options) {
                                final highlightedIndex =
                                    AutocompleteHighlightedOption.of(context);
                                return Theme(
                                  data: theme,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4,
                                      child: AppBorder(
                                        child: Container(
                                          color: Theme.of(context).cardColor,
                                          width: 250,
                                          constraints:
                                              BoxConstraints(maxHeight: 270),
                                          child: ScrollableListViewBuilder(
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
                                                color: highlightedIndex == index
                                                    ? convertHexStringToColor(state
                                                            .prefState
                                                            .enableDarkMode
                                                        ? kDefaultDarkSelectedColor
                                                        : kDefaultLightSelectedColor)
                                                    : Theme.of(context)
                                                        .cardColor,
                                                child:
                                                    EntityAutocompleteListTile(
                                                  onTap: (entity) =>
                                                      onSelected(entity),
                                                  entity:
                                                      options.elementAt(index),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else if (column == COLUMN_DESCRIPTION) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: GrowableFormField(
                              key: ValueKey(
                                  '__line_item_${index}_description__'),
                              autofocus: _autocompleteFocusIndex == index,
                              initialValue: lineItems[index].notes,
                              onChanged: (value) => _onChanged(
                                  lineItems[index]
                                      .rebuild((b) => b..notes = value),
                                  index),
                            ),
                          ),
                        );
                      } else if (column == COLUMN_CUSTOM1) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: CustomField(
                              field: customField1,
                              value: lineItems[index].customValue1,
                              hideFieldLabel: true,
                              onChanged: (value) => _onChanged(
                                  lineItems[index]
                                      .rebuild((b) => b..customValue1 = value),
                                  index),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_CUSTOM2) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: CustomField(
                              field: customField2,
                              value: lineItems[index].customValue2,
                              hideFieldLabel: true,
                              onChanged: (value) => _onChanged(
                                  lineItems[index]
                                      .rebuild((b) => b..customValue2 = value),
                                  index),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_CUSTOM3) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: CustomField(
                              field: customField3,
                              value: lineItems[index].customValue3,
                              hideFieldLabel: true,
                              onChanged: (value) => _onChanged(
                                  lineItems[index]
                                      .rebuild((b) => b..customValue3 = value),
                                  index),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_CUSTOM4) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: CustomField(
                              field: customField4,
                              value: lineItems[index].customValue4,
                              hideFieldLabel: true,
                              onChanged: (value) => _onChanged(
                                  lineItems[index]
                                      .rebuild((b) => b..customValue4 = value),
                                  index),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_TAX1) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: TaxRateDropdown(
                              onSelected: (taxRate) => _onChanged(
                                lineItems[index].rebuild((b) => b
                                  ..taxName1 = taxRate.name
                                  ..taxRate1 = taxRate.rate),
                                index,
                                debounce: false,
                              ),
                              labelText: null,
                              initialTaxName: lineItems[index].taxName1,
                              initialTaxRate: lineItems[index].taxRate1,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_TAX2) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: TaxRateDropdown(
                              onSelected: (taxRate) => _onChanged(
                                lineItems[index].rebuild((b) => b
                                  ..taxName2 = taxRate.name
                                  ..taxRate2 = taxRate.rate),
                                index,
                                debounce: false,
                              ),
                              labelText: null,
                              initialTaxName: lineItems[index].taxName2,
                              initialTaxRate: lineItems[index].taxRate2,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_TAX3) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: TaxRateDropdown(
                              onSelected: (taxRate) => _onChanged(
                                lineItems[index].rebuild((b) => b
                                  ..taxName3 = taxRate.name
                                  ..taxRate3 = taxRate.rate),
                                index,
                                debounce: false,
                              ),
                              labelText: null,
                              initialTaxName: lineItems[index].taxName3,
                              initialTaxRate: lineItems[index].taxRate3,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_UNIT_COST) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: DecoratedFormField(
                              key: ValueKey('__line_item_${index}_cost__'),
                              textAlign: TextAlign.right,
                              initialValue: formatNumber(
                                  lineItems[index].cost, context,
                                  formatNumberType: FormatNumberType.inputMoney,
                                  clientId: invoice.clientId),
                              onChanged: (value) => _onChanged(
                                lineItems[index].rebuild(
                                    (b) => b..cost = parseDouble(value)),
                                index,
                                debounce: false,
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_QUANTITY) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: DecoratedFormField(
                              key: ValueKey('__line_item_${index}_quantity__'),
                              textAlign: TextAlign.right,
                              initialValue: formatNumber(
                                  lineItems[index].quantity, context,
                                  formatNumberType:
                                      FormatNumberType.inputAmount,
                                  clientId: invoice.clientId),
                              onChanged: (value) => _onChanged(
                                lineItems[index].rebuild(
                                    (b) => b..quantity = parseDouble(value)),
                                index,
                                debounce: false,
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      } else if (column == COLUMN_DISCOUNT) {
                        return Focus(
                          onFocusChange: (hasFocus) => _onFocusChange(),
                          skipTraversal: true,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: kTableColumnGap),
                            child: DecoratedFormField(
                              key: ValueKey('__line_item_${index}_discount__'),
                              textAlign: TextAlign.right,
                              initialValue: formatNumber(
                                  lineItems[index].discount, context,
                                  formatNumberType:
                                      FormatNumberType.inputAmount,
                                  clientId: invoice.clientId),
                              onChanged: (value) => _onChanged(
                                  lineItems[index].rebuild(
                                      (b) => b..discount = parseDouble(value)),
                                  index),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              onSavePressed:
                                  widget.entityViewModel.onSavePressed,
                            ),
                          ),
                        );
                      }
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.only(right: kTableColumnGap),
                      child: TextFormField(
                        key: ValueKey(
                            '__total_${index}_${lineItems[index].total(invoice, precision)}_${invoice.clientId}__'),
                        readOnly: true,
                        enabled: false,
                        initialValue: formatNumber(
                            lineItems[index].total(invoice, precision), context,
                            clientId: invoice.clientId),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      enabled: !lineItems[index].isEmpty,
                      itemBuilder: (BuildContext context) {
                        final sectionIndex =
                            includedLineItems.indexOf(lineItems[index]);
                        final options = {
                          if (widget.isTasks &&
                              (lineItems[index].taskId ?? '').isNotEmpty)
                            localization.viewTask: MdiIcons.chevronDoubleRight,
                          if (sectionIndex > 0)
                            localization.moveTop: MdiIcons.chevronDoubleUp,
                          if (sectionIndex > 1)
                            localization.moveUp: MdiIcons.chevronUp,
                          if (sectionIndex < includedLineItems.length - 2)
                            localization.moveDown: MdiIcons.chevronDown,
                          if (sectionIndex < includedLineItems.length - 1)
                            localization.moveBottom: MdiIcons.chevronDoubleDown,
                          localization.remove: Icons.clear,
                        };

                        return options.keys
                            .map((option) => PopupMenuItem<String>(
                                  child: IconText(
                                    icon: options[option],
                                    text: option,
                                  ),
                                  value: option,
                                ))
                            .toList();
                      },
                      onSelected: (String action) {
                        if (action == localization.viewTask) {
                          viewEntityById(
                              entityId: lineItems[index].taskId,
                              entityType: EntityType.task);
                        } else if (action == localization.moveTop) {
                          viewModel.onMovedInvoiceItem(index, 0);
                        } else if (action == localization.moveUp) {
                          viewModel.onMovedInvoiceItem(index, index - 1);
                        } else if (action == localization.moveDown) {
                          viewModel.onMovedInvoiceItem(index, index + 1);
                        } else if (action == localization.moveBottom) {
                          viewModel.onMovedInvoiceItem(
                              index, lineItems.length - 2);
                        } else if (action == localization.remove) {
                          viewModel.onRemoveInvoiceItemPressed(index);
                        }
                        _updateTable();
                      },
                    ),
                  ])
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader(
    this.label, {
    this.isNumeric = false,
    this.isFirst = false,
  });

  final String label;
  final bool isNumeric;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;

    final tableHeaderColor = state.prefState
            .customColors[PrefState.THEME_INVOICE_HEADER_BACKGROUND_COLOR] ??
        '';
    final tableFontColor = state.prefState
            .customColors[PrefState.THEME_INVOICE_HEADER_FONT_COLOR] ??
        '';

    return Padding(
      padding: EdgeInsets.only(
        top: tableHeaderColor.isEmpty ? 0 : 8,
        bottom: tableHeaderColor.isEmpty ? 8 : 16,
        right: isNumeric ? kTableColumnGap : 0,
        left: tableHeaderColor.isNotEmpty && isFirst ? 4 : 0,
      ),
      child: Text(
        label,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: TextStyle(
            color: tableFontColor.isNotEmpty
                ? convertHexStringToColor(tableFontColor)
                : Colors.grey),
      ),
    );
  }
}
