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

  static Handler _login = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => Login());
  static Handler _quickStart = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => QuickStart());
  static Handler _newInvoice = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => NewInvoice());
  static Handler _createAccount = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => CreateAccount());
  static Handler _forgotPassword = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => ForgotPassword());
  static Handler _newAddress = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => NewAddress(params['code'][0]));

  static void setupRouter() {
    router.define(
      '/login',
      handler: _login,
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/quick-start',
      handler: _quickStart,
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/registration',
      handler: _createAccount,
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/password-reset',
      handler: _forgotPassword,
      transitionType: TransitionType.inFromRight,
    );
    router.define(
      '/new-address/:code',
      handler: _newAddress,
      transitionType: TransitionType.inFromRight,
    );
  }
}
