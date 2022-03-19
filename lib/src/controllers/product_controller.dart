import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/favorite.dart';
import '../models/option.dart';
import '../models/product.dart';
import '../repository/cart_repository.dart';
import '../repository/product_repository.dart';

class ProductController extends ControllerMVC {
  Product? product;
  double? quantity = 1;
  double? total = 0;
  List<Cart> carts = [];
  Favorite? favorite;
  bool loadCart = false;
  GlobalKey<ScaffoldState>? scaffoldKey;
  ProductController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForProduct({String? productId, String? message,}) async {
    final Stream<Product> stream = await getProduct(productId!);
    stream.listen((Product _product) {
      setState(() => product = _product);
    }, onError: (a) {
      print(a);
      scaffoldKey!.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      if (message != null) {
        scaffoldKey!.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForFavorite({String? productId}) async {
    final Stream<Favorite> stream = await isFavoriteProduct(productId!);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      print(a);
    });
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameMarkets(Product product) {
    if (carts.isNotEmpty) {
      return carts[0].product?.market?.id == product.market?.id;
    }
    return true;
  }

  Future<void> addToCart(Product product, {bool reset = false,}) async {
    if (product.packageItemsCount != null && product.packageItemsCount != "" &&
        int.parse(product.packageItemsCount!) <= 0){
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.QuantityIsOut),
      ));
      return;
    }
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options = product.options!.where((element) => element.checked!).toList();
    _newCart.quantity = this.quantity;
    // if product exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if ((_newCart.product!.packageItemsCount! != null &&
        _newCart.product!.packageItemsCount! != "") &&
        ( this.quantity!>int.parse(_newCart.product!.packageItemsCount!))){
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.Notpossible_product!),
      ));
      setState(() {
        this.loadCart = false;
      });
      return;
    }
    if (_oldCart != null) {
      if ((_oldCart.product!.packageItemsCount != null &&
          _oldCart.product!.packageItemsCount != "") &&
         (_oldCart.quantity!+this.quantity!>int.parse(_newCart.product!.packageItemsCount!))){
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context)!.Notpossible_product),
        ));
        setState(() {
          this.loadCart = false;
        });
        return;
      }
      _oldCart.quantity =_oldCart.quantity! + this.quantity!;

      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        setState(() {
          this.loadCart = false;
        });
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context)!.this_product_was_added_to_cart),
        ));
      });
    } else {

      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          carts.add(value);
          this.loadCart = false;
        });

      }).whenComplete(() {
        setState(() {
          this.loadCart = false;
        });
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context)!.this_product_was_added_to_cart),
        ));

      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null!);
  }

  void addToFavorite(Product product,) async {
    var _favorite = new Favorite();
    _favorite.product = product;
    _favorite.options = product.options!.where((Option _option) {
      return _option.checked!;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.thisProductWasAddedToFavorite),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite,) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.thisProductWasRemovedFromFavorites),
      ));
    });
  }

  Future<void> refreshProduct() async {
    var _id = product!.id;
    product = new Product();
    listenForFavorite(productId: _id);
    listenForProduct(productId: _id, message: S.of(context)!.productRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = product?.price ?? 0;
    product?.options?.forEach((option) {
      total =total! + (option.checked! ? option.price! : 0);
    });
    total =total!* quantity!;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity! <= 99) {
      this.quantity=this.quantity!+1;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity! > 1) {
      this.quantity=this.quantity!-1;
      calculateTotal();
    }
  }
}
