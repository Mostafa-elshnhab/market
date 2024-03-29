import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/razorpay_controller.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class RazorPayPaymentWidget extends StatefulWidget {
  RouteArgument?routeArgument;

  RazorPayPaymentWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _RazorPayPaymentWidgetState createState() => _RazorPayPaymentWidgetState();
}

class _RazorPayPaymentWidgetState extends StateMVC<RazorPayPaymentWidget> {
  RazorPayController? _con;

  _RazorPayPaymentWidgetState() : super(RazorPayController()) {
    _con = controller as RazorPayController?;
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
          S.of(context)!.razorpayPayment,
          style: Theme.of(context).textTheme.headline6!.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(

            initialUrlRequest: URLRequest(
                url: Uri.parse( _con!.url!)
            ),
//            initialHeaders: {},
            initialOptions: new InAppWebViewGroupOptions(android: AndroidInAppWebViewOptions(textZoom: 120)),
            onWebViewCreated: (InAppWebViewController controller) {
              _con!.webView = controller;
            },
            onLoadStart: (InAppWebViewController controller,  url) {
              setState(() {
                _con!.url = url.toString();
              });
              if (url == "${GlobalConfiguration().getString('base_url')}payments/razorpay") {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
              }
            },
            onProgressChanged: (InAppWebViewController controller, int progress) {
              setState(() {
                _con!.progress = progress / 100;
              });
            },
          ),
          _con!.progress! < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: _con!.progress,
                    backgroundColor: Theme.of(context).accentColor.withOpacity(0.2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
