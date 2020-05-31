import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/router.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Authentication.checkForAuth().then((auth) {
    FluroRouter.setupRouter();

    runApp(MaterialApp(
      onGenerateRoute: FluroRouter.router.generator,
      title: 'Anypay Cash Register',
      initialRoute: auth ? '/new-invoice' : '/login',
    ));
  });
}
