import 'package:flutter/material.dart' hide Router;
import 'package:fluro/fluro.dart';
import 'routes/invoice.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Router {
  static FluroRouter router = FluroRouter();

  static newHandler(klass, [key]) {
    return Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      if (key == null) return klass();
      else return klass(params[key][0]);
    });
  }

  static void setupRouter() {
    router.define(
      '/',
      // Replace this with a blank page? Or maybe remove it entirely?
      handler: newHandler(() => Home()),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      '/invoices/:id',
      handler: newHandler((id) => ShowInvoice(id), 'id'),
      transitionType: TransitionType.inFromBottom,
    );
  }
}
