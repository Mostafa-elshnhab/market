import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;

class LoginPhoneWidget extends StatefulWidget {

  LoginPhoneWidget({Key? key,}) : super(key: key);

  @override
  _LoginPhoneWidgetState createState() => _LoginPhoneWidgetState();
}

class _LoginPhoneWidgetState extends StateMVC<LoginPhoneWidget> {
  UserController?_con;
  _LoginPhoneWidgetState() : super(UserController()) {
    _con = controller as UserController?;
  }
  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
  }
  @override
  Widget build(BuildContext context) {

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
                      Text(
                        S.of(context)!.verify_phone,
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        S.of(context)!.Please_enter_your_phone_number,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        onChanged: (input) {
                          _con!.user.phone = input ;
                        },
                        validator: (input) => (input!.length != 10) ? "05xxxxxxxx" : null,
                        decoration: InputDecoration(
                          labelText: S.of(context)!.phone,
                          labelStyle: TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '05xxxxxxxx',
                          hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phone, color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          S.of(context)!.next,
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          _con!.verification_login();
                         },
                      ),
                      SizedBox(height: 20),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context)!.skip),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      )
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  // FlatButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pushReplacementNamed('/SignUpPhone');
                  //   },
                  //   textColor: Theme.of(context).hintColor,
                  //   child: Text(S.of(context).i_dont_have_an_account),
                  // ),
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
