import 'package:app/routes/edit_backend_url.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:app/routes/edit_business_info.dart';
import 'package:app/routes/forgot_password.dart';
import 'package:app/routes/create_account.dart';
import 'package:app/routes/set_currency.dart';
import 'package:app/routes/new_address.dart';
import 'package:app/routes/new_invoice.dart';
import 'package:app/routes/navigation.dart';
import 'package:app/routes/addresses.dart';
import 'package:app/routes/settings.dart';
import 'package:app/routes/payments.dart';
import 'package:app/routes/payment.dart';
import 'package:app/routes/invoice.dart';
import 'package:app/routes/login.dart';
import 'routes/about.dart';

class AnyFluroRouter {
  static FluroRouter router = FluroRouter();

  static newHandler(klass, List<String> keys) {
    return Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      var klassParams = keys.map((key) => params[key][0].toString()).toList();

      if (klassParams.length == 0) {
        return klass();
      } else if(klassParams.length == 1) {
        return klass(klassParams[0]);
      } else {
        return klass(klassParams[0], klassParams[1]);
      }
    });
  }

  static void setupRouter() {
    router.define(
      'login',
      handler: newHandler(() => Login(), []),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      'registration',
      handler: newHandler(() => CreateAccount(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'register-business',
      handler: newHandler(() => EditBusinessInfo(allowBack: false), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'password-reset',
      handler: newHandler(() => ForgotPassword(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'invoices/:id',
      handler: newHandler((id) => ShowInvoice(id), ['id']),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'new-invoice',
      handler: newHandler(() => NewInvoice(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'navigation',
      handler: newHandler(() => Navigation(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings',
      handler: newHandler(() => Settings(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings/business-info',
      handler: newHandler(() => EditBusinessInfo(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings/currency',
      handler: newHandler(() => SetCurrency(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings/backend_url',
      handler: newHandler(() => EditBackEndUrl(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings/addresses',
      handler: newHandler(() => Addresses(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'settings/about',
      handler: newHandler(() => About(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'payments',
      handler: newHandler(() => Payments(), []),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'payments/:id',
      handler: newHandler((id) => Payment(id), ['id']),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'pay/:id',
      handler: newHandler((id) => NewInvoice(merchantId: id), ['id']),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      'new-address/:code/:chain',
      handler: newHandler((code, chain) => NewAddress(code, chain), ['code', 'chain']),
      transitionType: TransitionType.inFromBottom,
    );
  }
}
