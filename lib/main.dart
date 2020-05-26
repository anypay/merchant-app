import 'package:flutter/material.dart';
import 'router.dart';


void main() {
  FluroRouter.setupRouter();

  runApp(MaterialApp(
    onGenerateRoute: FluroRouter.router.generator,
    title: 'Anypay Cash Register',
    initialRoute: '/login',
  ));
}
