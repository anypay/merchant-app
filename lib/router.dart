import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'routes/forgot_password.dart';
import 'routes/create_account.dart';
import 'routes/new_address.dart';
import 'routes/new_invoice.dart';
import 'routes/quick_start.dart';
import 'routes/login.dart';

class FluroRouter {
  static Router router = Router();


  static newHandler(klass, [key]) {
    return Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      if (key == null) return klass();
      else return klass(params[key][0]);
    });
  }

  static void setupRouter() {
    router.define(
      '/login',
      handler: newHandler(() => Login()),
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/quick-start',
      handler: newHandler(() => QuickStart()),
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/registration',
      handler: newHandler(() => CreateAccount()),
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/password-reset',
      handler: newHandler(() => ForgotPassword()),
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/new-address/:code',
      handler: newHandler((code) => NewAddress(code), 'code'),
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/new-invoice',
      handler: newHandler(() => NewInvoice()),
      transitionType: TransitionType.inFromRight,
    );
  }
}
