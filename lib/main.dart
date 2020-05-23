import 'package:flutter/material.dart';
import 'routes/new_invoice.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => NewInvoice(),
  },
));

