
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  GlobalKey<ScaffoldState>? scaffoldKey;
  static String hint = "";
  static int timeOrder = 0;
  var _profileSettingsFormKey = new GlobalKey<FormState>();
  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String? message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.product!.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String? message,}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts( ) async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context)!.carts_refreshed_successfuly,);
  }

  void removeFromCart({required Cart cart}) async {
    setState(() {
      this.carts.remove(cart);
    });
    removeCart(cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.the_product_was_removed_from_your_cart(cart.product!.name!)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.product!.price!;
      cart.options!.forEach((element) {
        cartPrice += element.price!;
      });
      cartPrice *= cart.quantity!;
      subTotal += cartPrice;
    });
    if(carts.length > 0){
      if (Helper.canDelivery(carts[0].product!.market!, carts: carts)) {
        deliveryFee = carts[0].product!.market!.deliveryFee!;
      }
      taxAmount = (subTotal + deliveryFee) * carts[0].product!.market!.defaultTax! / 100;
      total = subTotal + taxAmount + deliveryFee;
    }

    setState(() {});
  }

  void doApplyCoupon(String code,{String? message,}) async {
    // print("mdslkdanklsdanlkads0");

    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
      print("mdslkdanklsdanlkads0");
      print(coupon.toMap());
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
    });
  }

  incrementQuantity(Cart cart ) {
    if (cart.quantity! >= 99
        ||((cart.product!.packageItemsCount != null &&
            cart.product!.packageItemsCount != "") &&
            (cart.quantity! + 1>int.parse(cart.product!.packageItemsCount! )))) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.Notpossible_product),
      ));
    }else{
      cart.quantity=cart.quantity! +1;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity! > 1) {
      cart.quantity=-1;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout() {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context)!.settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      if (carts[0].product!.market!.closed!) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context!)!.this_market_is_closed_),
        ));
      } else {
        Navigator.of(context!).pushNamed('/DeliveryPickup');
      }
    }
  }
  Color getCouponIconColor() {
    if (coupon.valid == true) {
      return Colors.green;
    } else if (coupon.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(context!).focusColor.withOpacity(0.7);
  }
}
