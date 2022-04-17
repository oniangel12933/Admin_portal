// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/.env.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/repositories/product_repository.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/product/product_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/product/edit/product_edit_vm.dart';
import 'package:invoiceninja_flutter/ui/product/product_screen.dart';
import 'package:invoiceninja_flutter/ui/product/view/product_view_vm.dart';

List<Middleware<AppState>> createStoreProductsMiddleware([
  ProductRepository repository = const ProductRepository(),
]) {
  final viewProductList = _viewProductList();
  final viewProduct = _viewProduct();
  final editProduct = _editProduct();
  final loadProducts = _loadProducts(repository);
  final loadProduct = _loadProduct(repository);
  final saveProduct = _saveProduct(repository);
  final archiveProduct = _archiveProduct(repository);
  final deleteProduct = _deleteProduct(repository);
  final restoreProduct = _restoreProduct(repository);
  final saveDocument = _saveDocument(repository);

  return [
    TypedMiddleware<AppState, ViewProductList>(viewProductList),
    TypedMiddleware<AppState, ViewProduct>(viewProduct),
    TypedMiddleware<AppState, EditProduct>(editProduct),
    TypedMiddleware<AppState, LoadProducts>(loadProducts),
    TypedMiddleware<AppState, LoadProduct>(loadProduct),
    TypedMiddleware<AppState, SaveProductRequest>(saveProduct),
    TypedMiddleware<AppState, ArchiveProductsRequest>(archiveProduct),
    TypedMiddleware<AppState, DeleteProductsRequest>(deleteProduct),
    TypedMiddleware<AppState, RestoreProductsRequest>(restoreProduct),
    TypedMiddleware<AppState, SaveProductDocumentRequest>(saveDocument),
  ];
}

Middleware<AppState> _editProduct() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as EditProduct;

    next(action);

    store.dispatch(UpdateCurrentRoute(ProductEditScreen.route));

    if (store.state.prefState.isMobile) {
      navigatorKey.currentState.pushNamed(ProductEditScreen.route);
    }
  };
}

Middleware<AppState> _viewProduct() {
  return (Store<AppState> store, dynamic dynamicAction,
      NextDispatcher next) async {
    final action = dynamicAction as ViewProduct;

    next(action);

    store.dispatch(UpdateCurrentRoute(ProductViewScreen.route));

    if (store.state.prefState.isMobile) {
      navigatorKey.currentState.pushNamed(ProductViewScreen.route);
    }
  };
}

Middleware<AppState> _viewProductList() {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as ViewProductList;

    next(action);

    if (store.state.isStale) {
      store.dispatch(RefreshData());
    }

    store.dispatch(UpdateCurrentRoute(ProductScreen.route));

    if (store.state.prefState.isMobile) {
      navigatorKey.currentState.pushNamedAndRemoveUntil(
          ProductScreen.route, (Route<dynamic> route) => false);
    }
  };
}

Middleware<AppState> _archiveProduct(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as ArchiveProductsRequest;
    final prevProducts = action.productIds
        .map((id) => store.state.productState.map[id])
        .toList();
    repository
        .bulkAction(
            store.state.credentials, action.productIds, EntityAction.archive)
        .then((List<ProductEntity> products) {
      store.dispatch(ArchiveProductsSuccess(products));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((dynamic error) {
      print(error);
      store.dispatch(ArchiveProductsFailure(prevProducts));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _deleteProduct(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as DeleteProductsRequest;
    final prevProducts = action.productIds
        .map((id) => store.state.productState.map[id])
        .toList();
    repository
        .bulkAction(
            store.state.credentials, action.productIds, EntityAction.delete)
        .then((List<ProductEntity> products) {
      store.dispatch(DeleteProductsSuccess(products));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(DeleteProductsFailure(prevProducts));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _restoreProduct(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as RestoreProductsRequest;
    final prevProducts = action.productIds
        .map((id) => store.state.productState.map[id])
        .toList();
    repository
        .bulkAction(
            store.state.credentials, action.productIds, EntityAction.restore)
        .then((List<ProductEntity> products) {
      store.dispatch(RestoreProductsSuccess(products));
      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(RestoreProductsFailure(prevProducts));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _saveProduct(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as SaveProductRequest;
    repository
        .saveData(store.state.credentials, action.product)
        .then((ProductEntity product) {
      if (action.product.isNew) {
        store.dispatch(AddProductSuccess(product));
      } else {
        store.dispatch(SaveProductSuccess(product));
      }
      action.completer.complete(product);
    }).catchError((Object error) {
      print(error);
      store.dispatch(SaveProductFailure(error));
      action.completer.completeError(error);
    });

    next(action);
  };
}

Middleware<AppState> _loadProduct(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as LoadProduct;

    if (Config.DEMO_MODE) {
      next(action);
      return;
    }

    store.dispatch(LoadProductRequest());
    repository
        .loadItem(store.state.credentials, action.productId)
        .then((product) {
      store.dispatch(LoadProductSuccess(product));

      if (action.completer != null) {
        action.completer.complete(null);
      }
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadProductFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _loadProducts(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as LoadProducts;

    store.dispatch(LoadProductsRequest());
    repository.loadList(store.state.credentials).then((data) {
      store.dispatch(LoadProductsSuccess(data));
      if (action.completer != null) {
        action.completer.complete(null);
      }
      store.dispatch(LoadInvoices());
    }).catchError((Object error) {
      print(error);
      store.dispatch(LoadProductsFailure(error));
      if (action.completer != null) {
        action.completer.completeError(error);
      }
    });

    next(action);
  };
}

Middleware<AppState> _saveDocument(ProductRepository repository) {
  return (Store<AppState> store, dynamic dynamicAction, NextDispatcher next) {
    final action = dynamicAction as SaveProductDocumentRequest;
    if (store.state.isEnterprisePlan) {
      repository
          .uploadDocument(
              store.state.credentials, action.product, action.multipartFile)
          .then((product) {
        store.dispatch(SaveProductSuccess(product));
        action.completer.complete(null);
      }).catchError((Object error) {
        print(error);
        store.dispatch(SaveProductDocumentFailure(error));
        action.completer.completeError(error);
      });
    } else {
      const error = 'Uploading documents requires an enterprise plan';
      store.dispatch(SaveProductDocumentFailure(error));
      action.completer.completeError(error);
    }

    next(action);
  };
}
