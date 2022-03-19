import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController? _con;

  SplashScreenState( ) : super(SplashScreenController()) {
    _con = controller! as SplashScreenController?;
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() {

    _con!.progress.addListener(() {
      double progress = 0;
      _con!.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        try {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
           _con!.progress = null!;

          return;
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con!.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Image.asset(
                'assets/img/backSteer.jpg',
                fit: BoxFit.cover,
                // width: double.infinity,
                height: double.infinity,
              )),

              // SizedBox(height: 50),
              // CircularProgressIndicator(
              //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
