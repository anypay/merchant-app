import 'package:app/client.dart';
import 'dart:convert';

class Invoice {
  List paymentOptions;
  String currency;
  DateTime expiry;
  String address;
  double amount;
  String status;
  String uri;
  String uid;

  Invoice({
    this.paymentOptions,
    this.currency,
    this.address,
    this.amount,
    this.status,
    this.expiry,
    this.uri,
    this.uid,
  });

  bool isExpired() {
    return expiry.isBefore(DateTime.now());
  }

  String payUri([useCurrency]) {
    useCurrency = useCurrency ?? currency;
    String host = Client.host;
    String protocol = {
      'BTC': 'bitcoin',
      'BCH': 'bitcoincash',
      'DASH': 'dash',
    }[useCurrency] ?? 'pay';

    return "$protocol:?r=$host/r/$uid";
  }

  String uriFor(currency, {protocol}) {
    var option = paymentOptions.firstWhere((option) {
      return option['currency'] == currency;
    });
    return option['uri'];
  }

  factory Invoice.fromMap(Map<String, dynamic> body) {
    var json = body;
    return Invoice(
      paymentOptions: json['payment_options'],
      expiry: DateTime.parse(json['expiry']),
      currency: json['currency'],
      address: json['address'],
      amount: json['amount'],
      status: json['status'],
      uri: json['uri'],
      uid: json['uid'],
    );
  }

  factory Invoice.fromJson(String body) {
    return Invoice.fromMap(jsonDecode(body));
  }
}

