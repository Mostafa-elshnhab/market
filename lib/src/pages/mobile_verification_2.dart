import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../models/route_argument.dart';
import '../repository/user_repository.dart' as userRepo;

class MobileVerification2 extends StatefulWidget {
  final RouteArgument? routeArgument;
  MobileVerification2({Key? key, this.routeArgument,}) : super(key: key);

  @override
  _MobileVerification2State createState() => _MobileVerification2State();
}

class _MobileVerification2State extends StateMVC<MobileVerification2> {
  UserController? _con;
  _MobileVerification2State() : super(UserController()) {
    _con = controller as UserController?;

  }
  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }else{
      _con!.user.phone =  widget.routeArgument!.param["phone"];
      _con!.user.name =  widget.routeArgument!.param["name"];
      _con!.verificationId =  widget.routeArgument!.param["verificationId"];
    }

  }
  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con!.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(29.5),
                child: Text(
                  S.of(context)!.lets_start_with_login,
                  style: Theme.of(context).textTheme.headline2!.merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 50,
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                  BoxShadow(
                    blurRadius: 50,
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  )
                ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con!.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: _ac.appWidth(100),
                        child: Column(
                          children: <Widget>[
                            Text(
                              S.of(context)!.verify_your_account,
                              style: Theme.of(context).textTheme.headline5,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      if (_con!.user.name == "")
                      ...{
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _con!.user.name = input,
                          validator: (input) => input!.length < 3 ? S.of(context)!.should_be_more_than_3_letters : null,
                          decoration: InputDecoration(
                            labelText: S.of(context)!.full_name,
                            labelStyle: TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: S.of(context)!.john_doe,
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).accentColor),
                            border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          ),
                        ),

                        SizedBox(height: 20),
                      },

                      TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (input) => _con!.user.verify_code = input,
                        validator: (input) => (input!.length != 6)? S.of(context)!.digit_code : null,
                        decoration: InputDecoration(
                          labelText: S.of(context)!.code,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: "000000",
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.mail, color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        S.of(context)!.sms_sent +" "+_con!.user.phone!,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                       BlockButtonWidget(
                        onPressed: () {
//                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                           _con!.verification_code();
                        },
                        color: Theme.of(context).accentColor,
                        text: Text(S.of(context)!.verify.toUpperCase(),
                            style: Theme.of(context).textTheme.headline6!.merge(TextStyle(color: Theme.of(context).primaryColor))),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[

                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Login');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context)!.login_with_email),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


//import 'package:flutter/material.dart';
//
//import '../../generated/l10n.dart';
//import '../elements/BlockButtonWidget.dart';
//import '../helpers/app_config.dart' as config;
//
//class MobileVerification2 extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    final _ac = config.App(context);
//    return Scaffold(
//      body: Padding(
//        padding: const EdgeInsets.all(40),
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            SizedBox(
//              width: _ac.appWidth(100),
//              child: Column(
//                children: <Widget>[
//                  Text(
//                    'Verify Your Account',
//                    style: Theme.of(context).textTheme.headline5,
//                    textAlign: TextAlign.center,
//                  ),
//                  SizedBox(height: 10),
//                  Text(
//                    'We are sending OTP to validate your mobile number. Hang on!',
//                    style: Theme.of(context).textTheme.bodyText2,
//                    textAlign: TextAlign.center,
//                  ),
//                ],
//              ),
//            ),
//            SizedBox(height: 50),
//            TextField(
//              style: Theme.of(context).textTheme.headline5,
//              textAlign: TextAlign.center,
//              decoration: new InputDecoration(
//                enabledBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2)),
//                ),
//                focusedBorder: new UnderlineInputBorder(
//                  borderSide: new BorderSide(
//                    color: Theme.of(context).focusColor.withOpacity(0.5),
//                  ),
//                ),
//                hintText: '000-000',
//              ),
//            ),
//            SizedBox(height: 15),
//            Text(
//              'SMS has been sent to +155 4585 555',
//              style: Theme.of(context).textTheme.caption,
//              textAlign: TextAlign.center,
//            ),
//            SizedBox(height: 80),
//            new BlockButtonWidget(
//              onPressed: () {
//                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
//              },
//              color: Theme.of(context).accentColor,
//              text: Text(S.of(context).verify.toUpperCase(),
//                  style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Theme.of(context).primaryColor))),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
