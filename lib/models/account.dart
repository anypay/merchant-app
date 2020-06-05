import 'package:app/currencies.dart';
import 'dart:convert';

class Account {
  String ambassadorEmail;
  String physicalAddress;
  String businessName;
  String denomination;
  String email;

  List coins = [];

  Account({
    this.ambassadorEmail,
    this.physicalAddress,
    this.businessName,
    this.denomination,
    this.email,
  });

  String toJson() {
    return jsonEncode(toMap());
  }

  String currencySymbol() {
    return (Currencies.all[denomination ?? 'USD'])['symbol'];
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'ambassador_email': ambassadorEmail,
      'physical_address': physicalAddress,
      'business_name': businessName,
      'denomination': denomination,
      'email': email,
    } as Map;
  }

  factory Account.fromMap(Map<String, dynamic> body) {
    var json = body['account'] ?? body;
    return Account(
      ambassadorEmail: json['ambassador_email'],
      physicalAddress: json['physical_address'],
      businessName: json['business_name'],
      denomination: json['denomination'],
      email: json['email'],
    );
  }

  factory Account.fromJson(String body) {
    return Account.fromMap(jsonDecode(body));
  }
}
