
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState>? scaffoldKey;
  model.Address? deliveryAddress;
  PaymentMethodList? list;
  DeliveryPickupController() : super() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    super.listenForCarts();
    listenForDeliveryAddress();
    print(settingRepo.deliveryAddress.value.toMap());
  }

  void listenForDeliveryAddress() async {
    this.deliveryAddress = settingRepo.deliveryAddress.value;
  }

  void addAddress(model.Address address,) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.new_address_added_successfully),
      ));
    });
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context!)!.the_address_updated_successfully),
      ));
    });
  }

  PaymentMethod getPickUpMethod() {
    return list!.pickupList.elementAt(0);
  }

  PaymentMethod getDeliveryMethod() {
    return list!.pickupList.elementAt(1);
  }

  void toggleDelivery() {
    list!.pickupList.forEach((element) {
      if (element != getDeliveryMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getDeliveryMethod().selected = !getDeliveryMethod().selected!;
    });
  }

  void togglePickUp() {
    list!.pickupList.forEach((element) {
      if (element != getPickUpMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected!;
    });
  }

  PaymentMethod getSelectedMethod() {
    return list!.pickupList.firstWhere((element) => element.selected!);
  }

  @override
  void goCheckout() {
    print("PaymentMethod");
    PaymentMethod paymentMethod =  PaymentMethod("cod", S.of(context)!.cash_on_delivery, S.of(context)!.click_to_pay_cash_on_delivery, "/CashOnDelivery", "assets/img/cash.png");
    if (DateTime.now().millisecondsSinceEpoch < 99999999999999){
      paymentMethod =   PaymentMethod("visacard", S.of(context)!.visa_card, S.of(context)!.click_to_pay_with_your_visa_card, "/Checkout", "assets/img/visacard.png");
    }
    Navigator.of(context).pushNamed(paymentMethod.route!);
  }
}
