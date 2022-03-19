
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../models/user.dart' as use;
import '../repository/user_repository.dart' as repository;
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends ControllerMVC {
  use.User user = new use.User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState>? loginFormKey;
  GlobalKey<ScaffoldState>? scaffoldKey;
  FirebaseMessaging? _firebaseMessaging;
  String verificationId = "";
  OverlayEntry? loader;
  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
//    _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging!.getToken().then((String? _deviceToken) {
      // user.apiToken = _deviceToken;
      print("token: ${_deviceToken}");
      user.deviceToken = _deviceToken;
      repository.currentUser.value.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {

    FocusScope.of(context).unfocus();
    if (loginFormKey!.currentState!.validate()) {

      loginFormKey!.currentState!.save();
      Overlay.of(context)!.insert(loader!);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context)!.wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader!.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context)!.this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader!);
      });
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context)!.insert(loader!);
      repository.register(user).then((value) {

        if (value != null && value.apiToken != null) {

          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context)!.wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        // print("eeeeeeeeeee");
        // print(e);
        loader!.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context)!.this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader!);
      });
    }
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context)!.insert(loader!);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context)!.your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context)!.login,
              onPressed: () {
                Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader!.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context)!.error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader!);
      });
    }
  }
//   void verification_register() async {
//     FocusScope.of(context).unfocus();
//     if (loginFormKey.currentState.validate()) {
//       loginFormKey.currentState.save();
//       register_phone();
//
// //      Navigator.of(context).pushReplacementNamed('/MobileVerification2',arguments: RouteArgument(param: {"phone":user.phone,"name":user.name}));
//
//     }
//   }
  void verification_login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context)!.insert(loader!);

      // login_phone();
      //
      repository.findByPhone(this.user.phone!).then((value) {
        submitPhoneNumber("+966${this.user.phone}",value);
      }).catchError((e) {
        // loader.remove();
        // scaffoldKey?.currentState?.showSnackBar(SnackBar(
        //   content: Text(S.of(context).this_email_account_exists),
        // ));
        submitPhoneNumber("+966${this.user.phone}","");
      }).whenComplete(() {
        // Helper.hideLoader(loader);
      });
    }
  }


  void verification_code() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context)!.insert(loader!);

      login_verification_code(user.verify_code!);

    }
  }
  ////////////////////////////////////
  Future<void> submitPhoneNumber(String number,String name) async {
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = number;
    print("phoneNumber");
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more readable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      print(phoneAuthCredential);
      loader!.remove();

    }

    void verificationFailed(FirebaseAuthException error) {
      print(error);
      loader!.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(error.message!),
      ));
    }

    void codeSent(String verificationId, [int? code]) {
      print('codeSent');
      this.verificationId = verificationId;
      loader!.remove();
      Navigator.of(context).pushReplacementNamed('/MobileVerification2',arguments: RouteArgument(param: {"phone":user.phone,"name":name,"verificationId":this.verificationId}));
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      loader!.remove();
      print('codeAutoRetrievalTimeout');
    }

    print("FirebaseAuthFirebaseAuthFirebaseAuth ${phoneNumber}");
    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,
      timeout: Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }



  void login_verification_code(String smsCode) async {
    /// get the `smsCode` from the user

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    print("verify_codeverify_code:");
    print(this.verificationId);
    print(smsCode);

    try {
      await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
          verificationId: this.verificationId, smsCode: smsCode))
          .then((value){
        repository.login_verification_code(this.user.name!,this.user.phone!).then((value) {
          loader!.remove();
          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed('/Pages', arguments: 2);
        }).catchError((e) {
          loader!.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context)!.this_email_account_exists),
          ));
        });
      });
     } catch (e) {
      loader!.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
     print(e.toString());

    }

  }
  /////////////////////////////////
  // void login_verification_code2() async {
  //   FocusScope.of(context).unfocus();
  //   if (loginFormKey.currentState.validate()) {
  //     loginFormKey.currentState.save();
  //     Overlay.of(context).insert(loader);
  //     repository.verification_code(user).then((value) {
  //       print("sdalsn");
  //       print(value);
  //       if (value != null && value.apiToken != null) {
  //         Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
  //       } else {
  //         scaffoldKey?.currentState?.showSnackBar(SnackBar(
  //           content: Text(S.of(context).wrong_email_or_password),
  //         ));
  //       }
  //     }).catchError((e) {
  //       loader?.remove();
  //       scaffoldKey?.currentState?.showSnackBar(SnackBar(
  //         content: Text(S.of(context).input_error),
  //       ));
  //     }).whenComplete(() {
  //       Helper.hideLoader(loader);
  //     });
  //   }
  // }
  // void login_phone() async {
  //   FocusScope.of(context).unfocus();
  //   if (loginFormKey.currentState.validate()) {
  //     loginFormKey.currentState.save();
  //     Overlay.of(context).insert(loader);
  //     repository.login_phone(user).then((value) {
  //       Navigator.of(context).pushReplacementNamed('/MobileVerification2',arguments: RouteArgument(param: {"phone":user.phone}));
  //     }).catchError((e) {
  //       loader?.remove();
  //       scaffoldKey?.currentState?.showSnackBar(SnackBar(
  //         content: Text(S.of(context).dont_account_phone),
  //       ));
  //     }).whenComplete(() {
  //       Helper.hideLoader(loader);
  //     });
  //   }
  // }

  // void register_phone() async {
  //   FocusScope.of(context).unfocus();
  //   if (loginFormKey.currentState.validate()) {
  //     loginFormKey.currentState.save();
  //     Overlay.of(context).insert(loader);
  //     repository.register_phone(user).then((value) {
  //       Navigator.of(context).pushReplacementNamed('/MobileVerification2',arguments: RouteArgument(param: {"phone":user.phone}));
  //     }).catchError((e) {
  //       loader?.remove();
  //       scaffoldKey?.currentState?.showSnackBar(SnackBar(
  //         content: Text(S.of(context).input_error),
  //       ));
  //     }).whenComplete(() {
  //       Helper.hideLoader(loader);
  //     });
  //   }
  // }
}
