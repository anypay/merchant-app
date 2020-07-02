import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app_builder.dart';
import 'package:app/router.dart';

import 'package:app/native_storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Authentication.checkForAuth().then((isAuthenticated) {
    FluroRouter.setupRouter();
    runApp(Anypay(isAuthenticated));
  });
}

class Anypay extends StatelessWidget {
  Anypay(this.isAuthenticated);

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      var theme;
      var lightTheme = ThemeData(
        primaryColorDark: Color(0xFF707070),
        primaryColorLight: Color(0xFF404040),
        brightness: Brightness.light,
        accentColor: AppBuilder.blue,
        fontFamily: 'Ubuntu',
      );
      var darkTheme = ThemeData(
        primaryColorDark: Color(0xffCCCCCC),
        primaryColorLight: Color(0xFFFFFFFF),
        accentColor: Color(0xff2196f3),
        brightness: Brightness.dark,
        fontFamily: 'Ubuntu',
      );

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      theme = lightTheme;

      if (AppBuilder.enableDarkMode) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        theme = darkTheme;
      }

      return MaterialApp(
        initialRoute: isAuthenticated ? '/new-invoice' : '/login',
        onGenerateRoute: FluroRouter.router.generator,
        navigatorKey: AppBuilder.globalKey,
        title: 'Anypay Cash Register',
        theme: theme,
      );
    });
  }
}
