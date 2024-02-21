import 'package:app/authentication.dart';
import 'package:app/package_info_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app_controller.dart';
import 'package:app/router.dart';

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
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF404040)),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
            background: AppController.white,
            secondary: AppController.blue,
            brightness: Brightness.light),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.black,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white), //text (and icon)
          ),
        ),
        fontFamily: 'Ubuntu',
      );
      var darkTheme = ThemeData(
        primaryColorDark: Color(0xffCCCCCC),
        primaryColorLight: Color(0xFFFFFFFF),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
            background: Color(0xff222222),
            secondary: Color(0xff2196f3),
            brightness: Brightness.dark),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ), //button color
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.black), //text (and icon)
          ),
        ),
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
