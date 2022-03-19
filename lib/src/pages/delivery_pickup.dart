import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  DeliveryPickupWidget({Key? key, this.routeArgument,}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController? _con;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller as DeliveryPickupController?;

  }
  void _selectTab(int tabItem) {
    Navigator.of(context).pushNamed('/Pages', arguments: tabItem);
  }
  bool selected = true;
  @override
  Widget build(BuildContext context) {
    if (_con!.list == null) {
      _con!.list = new PaymentMethodList(context);
//      widget.pickup = widget.list.pickupList.elementAt(0);
//      widget.delivery = widget.list.pickupList.elementAt(1);
    }

    if (!_con!.getDeliveryMethod().selected! && selected){
      _con!.toggleDelivery();
      selected = false;
    }
    

    return Scaffold(
      key: _con!.scaffoldKey,
      // bottomNavigationBar: CartBottomDetailsWidget(con: _con),
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
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
//              title: new Container(height: 5.0),
              icon: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                    BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                  ],
                ),
                child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
              )),
          BottomNavigationBarItem(
            icon: new Icon(Icons.local_mall),
//            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.favorite),
//            title: new Container(height: 0.0),
          ),
        ],
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context)!.delivery_or_pickup,
          style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
           ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor, ),
        ],
      ),
      body:
      // SingleChildScrollView(
      //   padding: EdgeInsets.symmetric(vertical: 10),
      //   child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[

            // Padding(
            //   padding: const EdgeInsets.only(left: 20, right: 10),
            //   child: ListTile(
            //     contentPadding: EdgeInsets.symmetric(vertical: 0),
            //     leading: Icon(
            //       Icons.domain,
            //       color: Theme.of(context).hintColor,
            //     ),
            //     title: Text(
            //       S.of(context).pickup,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: Theme.of(context).textTheme.headline4,
            //     ),
            //     subtitle: Text(
            //       S.of(context).pickup_your_product_from_the_market,
            //       maxLines: 1,
            //       overflow: TextOverflow.ellipsis,
            //       style: Theme.of(context).textTheme.caption,
            //     ),
            //   ),
            // ),
            // PickUpMethodItem(
            //     paymentMethod: _con.getPickUpMethod(),
            //     onPressed: (paymentMethod) {
            //       _con.togglePickUp();
            //     }),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.map,
                      color: Theme.of(context).hintColor,
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 20, left: 20, right: 10),
                      child:  InkWell(child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Text(
                          S.of(context)!.address,
                          style: TextStyle(
                              color:Theme.of(context).primaryColor),
                        ),
                      ),onTap: (){
                        Navigator.of(context).pushNamed('/DeliveryAddresses');
                      },)//
                  ),
                    title: Text(
                      S.of(context)!.delivery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: _con!.carts.isNotEmpty && Helper.canDelivery(_con!.carts[0].product!.market!, carts: _con!.carts)
                        ? Text(
                            S.of(context)!.click_to_confirm_your_address_and_pay_or_long_press,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          )
                        : Text(
                            S.of(context)!.deliveryMsgNotAllowed,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                  ),
                ),
    //      Navigator.of(context).pushNamed('/DeliveryAddresses');

                // _con.carts.isNotEmpty && Helper.canDelivery(_con.carts[0].product.market, carts: _con.carts)
                //     ?
                DeliveryAddressesItemWidget(
                        paymentMethod: _con!.getDeliveryMethod(),
                        address: _con!.deliveryAddress,
                        onPressed: (Address _address) {
                          if (_con!.deliveryAddress!.id == null || _con!.deliveryAddress!.id == 'null') {
                            // DeliveryAddressDialog(
                            //   context: context,
                            //   address: _address,
                            //   onChanged: (Address _address) {
                            //     _con.addAddress(_address);
                            //   },
                            // );
                            Navigator.of(context).pushNamed('/DeliveryAddresses');
                          } else {
                            _con!.toggleDelivery();
                          }
                        },
                        onLongPress: (Address _address) {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (Address _address) {
                              _con!.updateAddress(_address);
                            },
                          );
                        },
                      )
                    // : NotDeliverableAddressesItemWidget()
              ],
            )
            ,Spacer(),
            // ,   SizedBox( ) , // use Expanded
            if (_con!.deliveryAddress!.address != null)...{
              CartBottomDetailsWidget(con: _con!)
            }

          ],
        ),
      // ),
    );
  }
}
