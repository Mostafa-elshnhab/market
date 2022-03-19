import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import 'CircularLoadingWidget.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key? key,
    required CartController con,
  })  : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? CircularLoadingWidget(height: 200)
        : Container(
            height: 160,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context)!.subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1!, zeroPlaceholder: '0')
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context)!.delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      if (Helper.canDelivery(_con.carts[0].product!.market!, carts: _con.carts))
                        Helper.getPrice(_con.carts[0].product!.market!.deliveryFee!, context,
                            style: Theme.of(context).textTheme.subtitle1!, zeroPlaceholder: 'Free')
                      else
                        Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1!, zeroPlaceholder: 'Free')
                    ],
                  ),
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Text(
                  //         '${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)',
                  //         style: Theme.of(context).textTheme.bodyText1,
                  //       ),
                  //     ),
                  //     Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                  //   ],
                  // ),
                  SizedBox(height: 10),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: FlatButton(
                          onPressed: () {
                            DateTime date = new DateTime.now();
                            CartController.timeOrder = (date.microsecondsSinceEpoch / 1000000).round();
                            // if (CartController.timeOrder == 0){
                            //   _con.scaffoldKey.currentState?.showSnackBar(SnackBar(
                            //     content: Text("رجاءً تحديد الوقت"),
                            //       action: SnackBarAction(
                            //         label: "تحديد",
                            //         textColor: Theme.of(context).accentColor,
                            //         onPressed: () {
                            //           DateTime start = DateTime.now().add(new Duration(days: 1));
                            //           start = new DateTime(start.year,start.month,start.day,13);
                            //
                            //           DateTime currentTime = DateTime.now().add(new Duration(days: 2));
                            //           currentTime = new DateTime(currentTime.year,currentTime.month,currentTime.day,15);
                            //           DatePicker.showDateTimePicker(context,
                            //               showTitleActions: true,
                            //               minTime: start,
                            //               maxTime: DateTime.now().add(new Duration(days: 60))
                            //               // ,currentTime: currentTime
                            //               , onChanged: (date) {
                            //                 print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            //               }, onConfirm: (date) {
                            //                 print('confirm $date');
                            //                    CartController.timeOrder = (date.microsecondsSinceEpoch / 1000000).round();
                            //
                            //               }, locale:  setting.value.mobileLanguage.value.languageCode == "ar"? LocaleType.ar:LocaleType.en);
                            //         },
                            //       )
                            //   ));
                            //   return ;
                            // }else{
                            //   date = new DateTime.fromMicrosecondsSinceEpoch(CartController.timeOrder * 1000000);
                            // }
                            // print(date.hour);
                            // if (!(date.hour  >= 10 && date.hour <= 23)){
                            //   _con.scaffoldKey.currentState?.showSnackBar(SnackBar(
                            //     content: Text("ساعات العمل :من 10 صباحاً الى 23 مساءً"),
                            //   ));
                            // }else{
                            //
                            // }

                            _con.goCheckout();
                          },
                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14),
                           color: !_con.carts[0].product!.market!.closed! ? Theme.of(context).accentColor : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Text(
                            S.of(context)!.checkout,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(_con.total, context,
                            style: Theme.of(context).textTheme.headline4!.merge(TextStyle(color: Theme.of(context).primaryColor)), zeroPlaceholder: 'Free'),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
