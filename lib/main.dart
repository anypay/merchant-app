import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/router.dart';

import 'package:app/storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Authentication.checkForAuth().then((auth) {
    FluroRouter.setupRouter();

    runApp(MaterialApp(
      initialRoute: auth ? '/new-invoice' : '/login',
      onGenerateRoute: FluroRouter.router.generator,
      theme: ThemeData(fontFamily: 'Ubuntu'),
      title: 'Anypay Cash Register',
    ));
  });
}
