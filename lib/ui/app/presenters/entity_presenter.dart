// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class EntityPresenter {
  EntityPresenter initialize(BaseEntity entity, BuildContext context) {
    this.entity = entity;
    this.context = context;

    return this;
  }

  BaseEntity entity;
  BuildContext context;

  String title({bool isNarrow = false}) {
    final localization = AppLocalization.of(context);
    final type = localization.lookup('${entity.entityType}');
    var name = entity.listDisplayName;

    // TODO replace with this: https://github.com/flutter/flutter/issues/45336
    if ((name ?? '').isEmpty) {
      name = localization.pending;
    } else if (name.length > 10) {
      return name;
    }

    if ([
          EntityType.client,
          EntityType.vendor,
          EntityType.project,
          EntityType.user,
          EntityType.product,
        ].contains(entity.entityType) ||
        isNarrow) {
      return name;
    } else {
      return '$type $name';
    }
  }

  static List<String> getBaseFields() {
    return [
      EntityFields.createdAt,
      EntityFields.updatedAt,
      EntityFields.archivedAt,
      EntityFields.assignedTo,
      EntityFields.createdBy,
      EntityFields.state,
      EntityFields.isDeleted,
    ];
  }

  Widget getField({String field, BuildContext context}) {
    final localization = AppLocalization.of(context);
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;

    switch (field) {
      case EntityFields.createdAt:
        return Text(formatDate(
            convertTimestampToDateString(entity.createdAt), context,
            showTime: true));
      case EntityFields.updatedAt:
        return Text(entity.updatedAt == 0
            ? ''
            : formatDate(
                convertTimestampToDateString(entity.updatedAt), context,
                showTime: true));
      case EntityFields.archivedAt:
        return Text(entity.archivedAt == 0
            ? ''
            : formatDate(
                convertTimestampToDateString(entity.archivedAt), context,
                showTime: true));
      case EntityFields.state:
        return Text(entity.isActive
            ? localization.active
            : entity.isArchived
                ? localization.archived
                : localization.deleted);
      case EntityFields.createdBy:
        return Text(
            state.userState.map[entity.createdUserId]?.listDisplayName ?? '');
      case EntityFields.assignedTo:
        return Text(
            state.userState.map[entity.assignedUserId]?.listDisplayName ?? '');
      case EntityFields.isDeleted:
        return Text(entity.isDeleted ? localization.yes : localization.no);
    }

    return Text('Error: $field not found');
  }

  static bool isFieldLocalized(String field) => [
        'status',
      ].contains(field);

  static bool isFieldAmount(String field) {
    return ['quantity'].contains(field);
  }

  static bool isFieldNumeric(String field) {
    if (field.startsWith('converted_')) {
      return true;
    }

    final value = [
      'balance',
      'paid_to_date',
      'amount',
      'quantity',
      'price',
      'cost',
      'line_total',
      'discount',
      'profit',
      'total',
      'payment',
      'expense',
      'invoice_amount',
      'invoice_balance',
      'client_balance',
      'credit_balance',
      'tax_rate',
      'tax_amount',
      'tax_paid',
      'payment_amount',
      'net_balance',
      'rate',
      'calculated_rate',
      'duration',
      'net_amount',
      'net_total',
      'age_group_0',
      'age_group_30',
      'age_group_60',
      'age_group_90',
      'age_group_120',
    ].contains(field);

    return value;
  }

  String presentCustomField(BuildContext context, String value) {
    if (['yes', 'no'].contains(value)) {
      final localization = AppLocalization.of(context);
      return localization.lookup(value);
    } else if (RegExp('^\\d{4}-\\d{2}-\\d{2}\$').hasMatch(value)) {
      return formatDate(value, context);
    }

    return value;
  }
}
