import 'package:timeago/timeago.dart' as timeago;
import 'package:app/authentication.dart';
import 'package:app/currencies.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";
import 'dart:convert';
import 'dart:io';

class Invoice {
  String denominationCurrency;
  num denominationAmountPaid;
  num denominationAmount;
  DateTime completedAt;
  List paymentOptions;
  String itemName;
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
    this.denominationAmountPaid,
    this.denominationCurrency,
    this.denominationAmount,
    this.paymentOptions,
    this.completedAt,
    this.complete,
    this.itemName,
    this.currency,
    this.address,
    this.notes,
    this.amount,
    this.status,
    this.expiry,
    this.hash,
    this.uri,
    this.uid,
  });

  String orderNotes() {
    var _notes = (notes ?? []).map((note) => note['content']).join(", ");
    if (notes != null && notes.length > 0)
      return "Order notes: $_notes";
    else return "";
  }

  int decimalPlaces() {
    return (Currencies.all[denominationCurrency] ?? {})['decimal_places'] ?? 2;
  }

  String paidAmountWithDenomination() {
    return amountWithDenomination(denominationAmountPaid);
  }

  String amountWithDenomination([amount = null]) {
    var defaultCurrency = Authentication.currentAccount.denomination;
    var symbol = (Currencies.all[denominationCurrency ?? defaultCurrency] ?? {})['symbol'] ?? "";
    amount ??= denominationAmount;

    try {
      return NumberFormat.currency(
        decimalDigits: decimalPlaces(),
        locale: Platform.localeName,
        symbol: symbol,
      ).format(amount);
    } catch(e) {
      // Fallback in case there is an unsupported locale
      var str = amount.toStringAsFixed(decimalPlaces());
      str = str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return "$symbol$str";
    }
  }

  String inCurrency() {
    var defaultCurrency = Authentication.currentAccount.denomination;
    var symbol = Currencies.all[denominationCurrency ?? defaultCurrency]['symbol'];
    return "$amount $currency";
  }

  bool isUnpaid() {
    return status == 'unpaid';
  }

  bool isUnderpaid() {
    return status == 'underpaid';
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

  String completedAtTimeAgo() {
    if (completedAt == null) return '';
    return timeago.format(completedAt);
  }

  String formatCompletedAt() {
    if (completedAt == null) return '';
    else return DateFormat('E, MMMM d, h:mma').format(completedAt);
  }

  factory Invoice.fromMap(Map<String, dynamic> body) {
    var json = body;
    return Invoice(
      completedAt: json['completed_at'] == null ? null : DateTime.parse(json['completed_at']).toLocal(),
      expiry: json['expiry'] == null ? null : DateTime.parse(json['expiry']).toLocal(),
      denominationAmountPaid: json['denomination_amount_paid'],
      denominationCurrency: json['denomination_currency'],
      denominationAmount: json['denomination_amount'],
      paymentOptions: json['payment_options'],
      complete: json['complete'] ?? false,
      itemName: json['item_name'],
      currency: json['currency'],
      address: json['address'],
      amount: json['amount'],
      status: json['status'],
      notes: json['notes'],
      hash: json['hash'],
      uri: json['uri'],
      uid: json['uid'],
    );
  }

  factory Invoice.fromJson(String body) {
    return Invoice.fromMap(jsonDecode(body));
  }
}

