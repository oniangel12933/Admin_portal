// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/presenters/entity_presenter.dart';

class VendorPresenter extends EntityPresenter {
  static List<String> getDefaultTableFields(UserCompanyEntity userCompany) {
    return [
      VendorFields.number,
      VendorFields.name,
      VendorFields.city,
      VendorFields.phone,
      EntityFields.state,
      EntityFields.createdAt,
    ];
  }

  static List<String> getAllTableFields(UserCompanyEntity userCompany) {
    return [
      ...getDefaultTableFields(userCompany),
      ...EntityPresenter.getBaseFields(),
      VendorFields.address1,
      VendorFields.address2,
      VendorFields.postalCode,
      VendorFields.countryId,
      VendorFields.privateNotes,
      VendorFields.website,
      VendorFields.vatNumber,
      VendorFields.idNumber,
      VendorFields.currencyId,
      VendorFields.customValue1,
      VendorFields.customValue2,
      VendorFields.customValue3,
      VendorFields.customValue4,
      VendorFields.updatedAt,
      VendorFields.archivedAt,
      VendorFields.documents,
      VendorFields.contacts,
    ];
  }

  @override
  Widget getField({String field, BuildContext context}) {
    final vendor = entity as VendorEntity;
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;

    switch (field) {
      case VendorFields.name:
        return Text(vendor.name);
      case VendorFields.city:
        return Text(vendor.city);
      case VendorFields.phone:
        return Text(vendor.phone);
      case VendorFields.state:
        return Text(vendor.state);
      case VendorFields.address1:
        return Text(vendor.address1);
      case VendorFields.address2:
        return Text(vendor.address2);
      case VendorFields.idNumber:
        return Text(vendor.idNumber);
      case VendorFields.number:
        return Text(vendor.number);
      case VendorFields.postalCode:
        return Text(vendor.postalCode);
      case VendorFields.countryId:
        return Text(state.staticState.countryMap[vendor.countryId]?.name ?? '');
      case VendorFields.privateNotes:
        return Text(vendor.privateNotes);
      case VendorFields.website:
        return Text(vendor.website);
      case VendorFields.vatNumber:
        return Text(vendor.vatNumber);
      case VendorFields.currencyId:
        return Text(
            state.staticState.currencyMap[vendor.currencyId]?.name ?? '');
      case VendorFields.customValue1:
        return Text(presentCustomField(context, vendor.customValue1));
      case VendorFields.customValue2:
        return Text(presentCustomField(context, vendor.customValue2));
      case VendorFields.customValue3:
        return Text(presentCustomField(context, vendor.customValue3));
      case VendorFields.customValue4:
        return Text(presentCustomField(context, vendor.customValue4));
      case VendorFields.documents:
        return Text('${vendor.documents.length}');
      case VendorFields.contacts:
        return Text(
          vendor.contacts.map((contact) => contact.fullName).join('\n'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        );
    }

    return super.getField(field: field, context: context);
  }
}
