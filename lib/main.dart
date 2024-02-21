import 'package:app/authentication.dart';
import 'package:app/client.dart';
import 'package:app/package_info_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app_controller.dart';
import 'package:app/router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfoPlusHelper.init(); 
  Authentication.checkForAuth().then((isAuthenticated) {
    AnyFluroRouter.setupRouter();
    runApp(Anypay(isAuthenticated));
  });
  Firebase.initializeApp();
}

class Anypay extends StatelessWidget {
  Anypay(this.isAuthenticated);

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return AppController(builder: (context) {
      var theme;
      var lightTheme = ThemeData(
        primaryColorDark: Color(0xFF707070),
        primaryColorLight: Color(0xFF404040),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.black,
            ), //button color
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white), //text (and icon)
          ),
        ),
        brightness: Brightness.light,
        accentColor: AppController.blue,
        fontFamily: 'Ubuntu',
      );
      var darkTheme = ThemeData(
        primaryColorDark: Color(0xffCCCCCC),
        primaryColorLight: Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ), //button color
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.black), //text (and icon)
          ),
        ),
        accentColor: Color(0xff2196f3),
        brightness: Brightness.dark,
        fontFamily: 'Ubuntu',
      );

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      theme = lightTheme;

      if (AppController.enableDarkMode) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        theme = darkTheme;
      }

      return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          if (child == null) {
            throw 'MaterialApp builder child is null';
          }

          return SafeArea(
            child: child,
          );
        },
        initialRoute: isAuthenticated ? 'new-invoice' : 'login',
        onGenerateRoute: AnyFluroRouter.router.generator,
        navigatorKey: AppController.globalKey,
        title: 'Anypay Cash Register',
        theme: theme,
      );
    });
  }
}
