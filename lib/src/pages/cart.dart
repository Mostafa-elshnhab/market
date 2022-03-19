import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:intl/intl.dart';

class CartWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  CartWidget({Key? key, this.routeArgument, }) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  DeliveryPickupController? _con;
  _CartWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController?;
    CartController.hint = "";
    CartController.timeOrder = 0;
  }

  @override
  void initState() {
    _con!.listenForCarts();
    super.initState();
  }

  void _selectTab(int tabItem) {
    Navigator.of(context).pushNamed('/Pages', arguments: tabItem);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con!.scaffoldKey,
//        bottomNavigationBar: CartBottomDetailsWidget(con: _con),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: 2,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(

//                title: new Container(height: 5.0),
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                      BoxShadow(
                          color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                    ],
                  ),
                  child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
              icon: new Icon(Icons.local_mall),
//              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.favorite),
//              title: new Container(height: 0.0),
            ),
          ],
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              if (widget.routeArgument != null) {
                Navigator.of(context).pushReplacementNamed(widget.routeArgument!.param,
                    arguments: RouteArgument(id: widget.routeArgument!.id));
              } else {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
              }
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context)!.cart,
            style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _con!.refreshCarts,
          child: _con!.carts.isEmpty
              ? EmptyCartWidget()
              : Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                     Column(
                      children: [
                         Expanded(
                            child: SingleChildScrollView(
                                child:  Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 10),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                leading: Icon(
                                  Icons.shopping_cart,
                                  color: Theme.of(context).hintColor,
                                ),
                                trailing: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 10),
                                    child:  InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          color: Theme.of(context).accentColor,
                                        ),
                                        child: Text(
                                          S.of(context)!.address,
                                          style: TextStyle(color: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pushNamed('/DeliveryAddresses');
                                      },
                                    ) //
                                    ),
                                title: Text(
                                  S.of(context)!.shopping_cart,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                subtitle: _con!.carts.isNotEmpty &&
                                        Helper.canDelivery(_con!.carts[0].product!.market!, carts: _con!.carts)
                                    ? Text(
                                        (_con!.deliveryAddress != null && _con!.deliveryAddress!.address! != null)
                                            ? _con!.deliveryAddress!.address!
                                            : "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.caption,
                                      )
                                    : Text(
                                        S.of(context)!.deliveryMsgNotAllowed,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.caption!.merge(TextStyle(color: Colors.red)),
                                      ),
                              ),
                            ),

                            // Container(
                            //   padding: const EdgeInsets.all(18),
                            //   margin: EdgeInsets.only(bottom: 15),
                            //   decoration: BoxDecoration(
                            //       color: Theme.of(context).primaryColor,
                            //       borderRadius: BorderRadius.all(Radius.circular(20)),
                            //       boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, 2), blurRadius: 5.0)]),
                            //   child: TextField(
                            //     keyboardType: TextInputType.text,
                            //     onSubmitted: (String value) {
                            //       _con.doApplyCoupon(value);
                            //     },
                            //     cursorColor: Theme.of(context).accentColor,
                            //     controller: TextEditingController()..text = coupon?.code ?? '',
                            //     decoration: InputDecoration(
                            //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            //       floatingLabelBehavior: FloatingLabelBehavior.always,
                            //       hintStyle: Theme.of(context).textTheme.bodyText1,
                            //       suffixText: coupon?.valid == null ? '' : (coupon.valid ? S.of(context).validCouponCode : S.of(context).invalidCouponCode),
                            //       suffixStyle: Theme.of(context).textTheme.caption.merge(TextStyle(color: _con.getCouponIconColor())),
                            //       suffixIcon: Padding(
                            //         padding: const EdgeInsets.symmetric(horizontal: 15),
                            //         child: Icon(
                            //           Icons.confirmation_number,
                            //           color: _con.getCouponIconColor(),
                            //           size: 28,
                            //         ),
                            //       ),
                            //       hintText: S.of(context).haveCouponCode,
                            //       border: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            //       focusedBorder: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            //       enabledBorder: OutlineInputBorder(
                            //           borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            //     ),
                            //   ),
                            // ),
                            // Container(
                            //     padding: const EdgeInsets.all(18),
                            //     margin: EdgeInsets.only(bottom: 15),
                            //     decoration: BoxDecoration(
                            //         color: Theme.of(context).primaryColor,
                            //         borderRadius: BorderRadius.all(Radius.circular(20)),
                            //         boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, 2), blurRadius: 5.0)]),
                            //     child: new Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text("وقت التوصيل :"),
                            //         // SizedBox(width: 20,),
                            //         Spacer(),
                            //         if (CartController.timeOrder == 0)...{
                            //           new Expanded(child: Text("يجب اختيار الوقت")),
                            //         }else...{
                            //           new Expanded(child: Text("${
                            //         DateFormat('yyyy-MM-dd – kk:mm').format(new DateTime.fromMicrosecondsSinceEpoch(CartController.timeOrder * 1000000))
                            //           }")),
                            //         },
                            //         // Spacer(),
                            //         InkWell(
                            //           onTap: (){
                            //             DateTime start = DateTime.now().add(new Duration(days: 1));
                            //             start = new DateTime(start.year,start.month,start.day,13);
                            //
                            //             DateTime currentTime = DateTime.now().add(new Duration(days: 2));
                            //             currentTime = new DateTime(currentTime.year,currentTime.month,currentTime.day,15);
                            //              DatePicker.showDateTimePicker(context,
                            //                 showTitleActions: true,
                            //                 minTime: start,
                            //                 maxTime: DateTime.now().add(new Duration(days: 60))
                            //                  // ,currentTime: currentTime
                            //                 , onChanged: (date) {
                            //                   print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            //                 }, onConfirm: (date) {
                            //                   print('confirm $date');
                            //                   setState(() {
                            //                     CartController.timeOrder = (date.microsecondsSinceEpoch / 1000000).round();
                            //
                            //                   });
                            //                 }, locale:  setting.value.mobileLanguage.value.languageCode == "ar"? LocaleType.ar:LocaleType.en);
                            //           },
                            //           child:
                            //           Container(
                            //               padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            //               decoration: BoxDecoration(
                            //                 borderRadius: BorderRadius.all(Radius.circular(5)),
                            //                 color: Theme.of(context).accentColor,
                            //               ),
                            //               child: Text(
                            //                 S.of(context).edit,
                            //                 style: TextStyle(
                            //                     color:Theme.of(context).primaryColor ),
                            //               )
                            //           ),
                            //         )
                            //       ],
                            //     )
                            // ),
                            Container(
                              padding: const EdgeInsets.all(18),
                              margin: EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).focusColor.withOpacity(0.15),
                                        offset: Offset(0, 2),
                                        blurRadius: 5.0)
                                  ]),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                onChanged: (String value) {
                                  // _con.get
                                  CartController.hint = value;
                                },
                                cursorColor: Theme.of(context).accentColor,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  hintStyle: Theme.of(context).textTheme.bodyText1,
                                  suffixStyle: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .merge(TextStyle(color: _con!.getCouponIconColor())),
                                  hintText: S.of(context)!.hint,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                ),
                              ),
                            ),

                            ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              primary: true,
                              itemCount: _con!.carts.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 15);
                              },
                              itemBuilder: (context, index) {
                                return CartItemWidget(
                                  cart: _con!.carts.elementAt(index),
                                  heroTag: 'cart',
                                  increment: () {
                                    _con!.incrementQuantity(_con!.carts.elementAt(index),);
                                  },
                                  decrement: () {
                                    _con!.decrementQuantity(_con!.carts.elementAt(index));
                                  },
                                  onDismissed: () {
                                    _con!.removeFromCart(cart: _con!.carts.elementAt(index),);
                                  },
                                );
                              },
                            ),
                            // ,
                          ],
                        ))),
                        if (_con!.deliveryAddress != null && _con!.deliveryAddress!.address != null) ...{
                          CartBottomDetailsWidget(con: _con!)
                        }
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
