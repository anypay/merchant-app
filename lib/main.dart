import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/app_controller.dart';
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
    return AppController(builder: (context) {
      var theme;

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      theme = AppController.lightTheme;

      if (AppController.enableDarkMode) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        theme = AppController.darkTheme;
      }

      return MaterialApp(
        initialRoute: isAuthenticated ? '/new-invoice' : '/login',
        onGenerateRoute: FluroRouter.router.generator,
        navigatorKey: AppController.globalKey,
        title: 'Anypay Cash Register',
        theme: theme,
      );
    });
  }
}
