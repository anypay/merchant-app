import 'package:app/currencies.dart';
import 'package:app/client.dart';
import 'dart:convert';

class Invoice {
  String denominationCurrency;
  num denominationAmount;
  DateTime completedAt;
  List paymentOptions;
  String currency;
  DateTime expiry;
  String address;
  bool complete;
  String status;
  String hash;
  num amount;
  String uri;
  String uid;

  Invoice({
    this.denominationCurrency,
    this.denominationAmount,
    this.paymentOptions,
    this.completedAt,
    this.complete,
    this.currency,
    this.address,
    this.amount,
    this.status,
    this.expiry,
    this.hash,
    this.uri,
    this.uid,
  });

  String amountWithDenomination() {
    var symbol = Currencies.all[denominationCurrency]['symbol'];
    return "$symbol$denominationAmount";
  }

  String inCurrency() {
    var symbol = Currencies.all[denominationCurrency]['symbol'];
    return "$amount $currency";
  }

  bool isUnpaid() {
    return !isExpired() && !isPaid();
  }

  bool isPaid() {
    return status == 'paid' ||
        status == 'overpaid';
  }

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
    if (protocol == 'pay') return payUri(currency);

    var option = paymentOptions.firstWhere((option) {
      return option['currency'] == currency;
    });
    return option['uri'];
  }

  factory Invoice.fromMap(Map<String, dynamic> body) {
    var json = body;
    return Invoice(
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at']),
      denominationCurrency: json['denomination_currency'],
      denominationAmount: json['denomination_amount'],
      paymentOptions: json['payment_options'],
      expiry: DateTime.parse(json['expiry']),
      complete: json['complete'] ?? false,
      currency: json['currency'],
      address: json['address'],
      amount: json['amount'],
      status: json['status'],
      hash: json['hash'],
      uri: json['uri'],
      uid: json['uid'],
    );
  }

  factory Invoice.fromJson(String body) {
    return Invoice.fromMap(jsonDecode(body));
  }
}

