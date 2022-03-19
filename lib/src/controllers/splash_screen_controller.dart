
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState>?scaffoldKey;
   FirebaseMessaging? firebaseMessaging ;
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    firebaseMessaging!.requestPermission(sound: true, badge: true, alert: true);
    firebaseMessaging!.getToken().then((String? _deviceToken) {

      print("token: ${_deviceToken}");
      userRepo.currentUser.value.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
    configureFirebase(firebaseMessaging!);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null && settingRepo.setting.value.appName != '' && settingRepo.setting.value.mainColor != null) {
        if (progress!= null) {
          progress.value["Setting"] = 41;
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          progress.notifyListeners();
        }
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        if (progress!= null){
          progress.value["User"] = 59;
          progress.notifyListeners();
        }

      }
    });
    Timer(Duration(seconds: 20), () {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context)!.verify_your_internet_connection),
      ));
    });

  }

  void configureFirebase(FirebaseMessaging? _firebaseMessaging) {
    print("sadamsklas");
    try {
      var initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings();

      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,

                  color: Colors.blue,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: "@mipmap/ic_launcher",
                ),
              ));
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text(notification.title!),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(notification.body!)],
                    ),
                  ),
                );
              });
        }
      });

      _firebaseMessaging!.requestPermission(

              sound: true, badge: true, alert: true);
      //انا اللي موقف دي
//      _firebaseMessaging.onIosSettingsRegistered
//          .listen((IosNotificationSettings settings) {
//        print("Settings registered: $settings");
//      });
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
      print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
    }
  }

  Future notificationOnResume(Map<String, dynamic> message) async {
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 3);
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        if (message['data']['id'] == "orders") {
          await settingRepo.saveMessageId(message['google.message_id']);
          settingRepo.navigatorKey.currentState!.pushReplacementNamed('/Pages', arguments: 3);
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnMessage(Map<String, dynamic> message) async {
     Fluttertoast.showToast(
       msg: message['notification']['title'],
       toastLength: Toast.LENGTH_LONG,
       gravity: ToastGravity.TOP,
       timeInSecForIosWeb: 5,
     );
    _showNotification(message);


  }
  Future _showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails();

    await flutterLocalNotificationsPlugin.show(
        0, message["notification"]["title"].toString(), message["notification"]["body"].toString(), platformChannelSpecifics,
        payload: "5");
  }
  Future onSelectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }

//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SecondScreen(payload)),
//     );
  }

}
