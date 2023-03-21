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

class AnyFluroRouter {
  static FluroRouter router = FluroRouter();

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
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/registration',
      handler: newHandler(() => CreateAccount()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/register-business',
      handler: newHandler(() => EditBusinessInfo(allowBack: false)),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/password-reset',
      handler: newHandler(() => ForgotPassword()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/invoices/:id',
      handler: newHandler((id) => ShowInvoice(id), 'id'),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/new-invoice',
      handler: newHandler(() => NewInvoice()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/navigation',
      handler: newHandler(() => Navigation()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/settings',
      handler: newHandler(() => Settings()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/settings/business-info',
      handler: newHandler(() => EditBusinessInfo()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/settings/currency',
      handler: newHandler(() => SetCurrency()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/settings/addresses',
      handler: newHandler(() => Addresses()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/payments',
      handler: newHandler(() => Payments()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/payments/:id',
      handler: newHandler((id) => Payment(id), 'id'),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/pay/:id',
      handler: newHandler((id) => NewInvoice(merchantId: id), 'id'),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/new-address/:code',
      handler: newHandler((code) => NewAddress(code), 'code'),
      transitionType: TransitionType.inFromBottom,
    );
  }
}
