import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'app_controller.dart';
import 'router.dart';

void main() {
  Router.setupRouter();
  runApp(AnypayInvoice());
}

class AnypayInvoice extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AppController(builder: (context) {
      var theme;

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      theme = AppController.lightTheme;

      if (AppController.enableDarkMode) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        theme = AppController.darkTheme;
      }

      return MaterialApp(
        onGenerateRoute: Router.router.generator,
        navigatorKey: AppController.globalKey,
        title: 'Anypay Cash Register',
        initialRoute: '/',
        theme: theme,
      );
    });
  }
}
