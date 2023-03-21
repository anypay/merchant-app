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
  String blockchainUrl;
  List paymentOptions;
  String redirectUrl;
  String accountId;
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
    this.blockchainUrl,
    this.completedAt,
    this.redirectUrl,
    this.accountId,
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

  String getBlockchainUrl() {
    if (blockchainUrl != null && blockchainUrl.length > 0)
      return blockchainUrl;
    else if (currency == 'BSV')
      return "https://whatsonchain.com/tx/$hash";
    else if (currency == 'BCH')
      return "https://explorer.bitcoin.com/bch/tx/$hash";
    else if (currency == 'DASH')
      return "https://chainz.cryptoid.info/dash/tx.dws?$hash";
  }

  String noteText() {
    return (notes ?? []).map((note) => note['content']).join(", ");
  }

  String orderNotes() {
    if (notes != null && notes.length > 0)
      return "Order notes: ${noteText()}";
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

  Map<String, dynamic> get bsvPaymentOption {
    return paymentOptions.firstWhere((option) => option['currency'] == 'BSV', orElse: () => null);
  }

  String urlStyleUri([useCurrency]) {
    useCurrency = useCurrency ?? currency;
    String host = Client.host;
    String protocol = {
      'BTC': 'bitcoin',
      'BCH': 'bitcoincash',
      'DASH': 'dash',
      'BSV': 'pay',
    }[useCurrency] ?? 'pay';

    return "$protocol:?r=$host/r/$uid";
  }

  String uriFor(currency, {format}) {
    if (format == 'pay') return "pay:?r=${Client.host}/r/$uid";
    if (format == 'url') return urlStyleUri(currency);

    return paymentOptionFor(currency)['uri'];
  }

  Map<String, dynamic> paymentOptionFor(currency) {
    return paymentOptions.firstWhere((option) {
      return option['currency'] == currency;
    }) ?? {};
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
      accountId: json['account_id']?.toString(),
      paymentOptions: json['payment_options'],
      blockchainUrl: json['blockchain_url'],
      complete: json['complete'] ?? false,
      redirectUrl: json['redirect_url'],
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

