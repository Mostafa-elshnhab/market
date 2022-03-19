import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class CheckoutWidget extends StatefulWidget {
//  RouteArgument routeArgument;
//  CheckoutWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CheckoutWidgetState createState() => _CheckoutWidgetState();
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  CheckoutController? _con;
  _CheckoutWidgetState() : super(CheckoutController()) {
    _con = controller as CheckoutController?;
  }

  @override
  void initState() {
    _con!.listenForCarts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context)!.checkout,
          style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
        ),
        leading: IconButton(
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/Pages', arguments: 3);
          },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
      ),
      body: _con!.loading
          ? CircularLoadingWidget(height: 400)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                WebView(
                  initialUrl: _con!.urlPay.value,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    // _controller.complete(webViewController);
                  },

                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('https://www.youtube.com/')) {
                      print('blocking navigation to $request}');
                      return NavigationDecision.prevent;
                    }
                    print('allowing navigation to $request');
                    return NavigationDecision.navigate;
                  },

                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                    // Successful
                    if (url.toLowerCase().contains("successful")){
                      Navigator.of(context).pushNamed('/Pages', arguments: 3);
                    }
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                  },
                  gestureNavigationEnabled: true,onProgress: (x){
                  print('Page  onProgress: $x');
                  setState(() {
                    _con!.loadingUrl = x;
                  });

                },
                ),
                if (_con!.loadingUrl < 90)...{
                  CircularLoadingWidget(height: 400)
                }
                // Positioned(
                //   bottom: 0,
                //   child: Container(
                //     height: 255,
                //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                //     decoration: BoxDecoration(
                //         color: Theme.of(context).primaryColor,
                //         borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                //         boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
                //     child: SizedBox(
                //       width: MediaQuery.of(context).size.width - 40,
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisSize: MainAxisSize.max,
                //         children: <Widget>[
                //           Row(
                //             children: <Widget>[
                //               Expanded(
                //                 child: Text(
                //                   S.of(context).subtotal,
                //                   style: Theme.of(context).textTheme.bodyText1,
                //                 ),
                //               ),
                //               Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1)
                //             ],
                //           ),
                //           SizedBox(height: 3),
                //           Row(
                //             children: <Widget>[
                //               Expanded(
                //                 child: Text(
                //                   S.of(context).delivery_fee,
                //                   style: Theme.of(context).textTheme.bodyText1,
                //                 ),
                //               ),
                //               Helper.getPrice(_con.carts[0].product.market.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                //             ],
                //           ),
                //           SizedBox(height: 3),
                //           // Row(
                //           //   children: <Widget>[
                //           //     Expanded(
                //           //       child: Text(
                //           //         "${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)",
                //           //         style: Theme.of(context).textTheme.bodyText1,
                //           //       ),
                //           //     ),
                //           //     Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                //           //   ],
                //           // ),
                //           Divider(height: 30),
                //           Row(
                //             children: <Widget>[
                //               Expanded(
                //                 child: Text(
                //                   S.of(context).total,
                //                   style: Theme.of(context).textTheme.headline6,
                //                 ),
                //               ),
                //               Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline6)
                //             ],
                //           ),
                //           SizedBox(height: 20),
                //           SizedBox(
                //             width: MediaQuery.of(context).size.width - 40,
                //             child: FlatButton(
                //               onPressed: () {
                //                 // if (_con.creditCard.validated()) {
                //                 //   Navigator.of(context).pushNamed('/OrderSuccess', arguments: new RouteArgument(param: 'Credit Card (Stripe Gateway)'));
                //                 // } else {
                //                 //   _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(
                //                 //     content: Text(S.of(context).your_credit_card_not_valid),
                //                 //   ));
                //                 // }
                //                 // _con.payment = new Payment("Credit Card (Stripe Gateway)");
                //                 _con.payment = new Payment("Credit Card");
                //
                //                 _con.onLoadingCartDone();
                //               },
                //               padding: EdgeInsets.symmetric(vertical: 14),
                //               color: Theme.of(context).accentColor,
                //               shape: StadiumBorder(),
                //               child: Text(
                //                 S.of(context).confirm_payment,
                //                 textAlign: TextAlign.start,
                //                 style: TextStyle(color: Theme.of(context).primaryColor),
                //               ),
                //             ),
                //           ),
                //           SizedBox(height: 10),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
    );
  }

}
