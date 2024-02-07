// import 'package:timeago/timeago.dart' as timeago;
// import 'package:app/authentication.dart';
// import 'package:app/currencies.dart';
// import 'package:app/client.dart';
// import "package:intl/intl.dart";
import 'dart:convert';
// import 'dart:io';

class Address {
  int id;
  String note;
  String value;
  String currency;
  String paymail;

  Address({
    this.id,
    this.note,
    this.value,
    this.paymail,
    this.currency,
  });

  String toString() {
    return paymail ?? value ?? '';
  }

  factory Address.fromMap(Map<String, dynamic> body) {
    var json = body;
    return Address(
      id: json['id'],
      note: json['note'],
      value: json['value'],
      paymail: json['paymail'],
      currency: json['currency'],
    );
  }

  factory Address.fromJson(String body) {
    return Address.fromMap(jsonDecode(body));
  }
}

