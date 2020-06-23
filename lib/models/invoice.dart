import 'package:app/currencies.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";
import 'dart:convert';
import 'dart:io';

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
  List notes;
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

  int decimalPlaces() {
    return (Currencies.all[denominationCurrency] ?? {})['decimal_places'] ?? 2;
  }

  String amountWithDenomination() {
    var symbol = (Currencies.all[denominationCurrency] ?? {})['symbol'] ?? "";

    try {
      return NumberFormat.currency(
        decimalDigits: decimalPlaces(),
        locale: Platform.localeName,
        symbol: symbol,
      ).format(denominationAmount);
    } catch(e) {
      // Fallback in case there is an unsupported locale
      var str = denominationAmount.toStringAsFixed(decimalPlaces());
      str = str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return "$symbol$str";
    }
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

  String urlStyleUri([useCurrency]) {
    useCurrency = useCurrency ?? currency;
    String host = Client.host;
    String protocol = {
      'BTC': 'bitcoin',
      'BCH': 'bitcoincash',
      'DASH': 'dash',
      'BSV': 'pay',
    }[useCurrency];

    return "$protocol:?r=$host/r/$uid";
  }

  String uriFor(currency, {format}) {
    if (format == 'pay') return "pay:?r=${Client.host}/r/$uid";
    if (format == 'url') return urlStyleUri(currency);

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

