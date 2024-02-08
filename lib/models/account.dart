import 'package:app/models/address.dart';
import 'dart:convert';

class Account {
  Map<String, dynamic> addresses = {};
  bool fetchingCoins = false;
  String? ambassadorEmail;
  String? physicalAddress;
  String? businessName;
  String? denomination;
  String? email;

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

  Address? addressFor(code) {
    return addresses[code] ?? null;
  }

  String? get preferredCoinCode {
    if (coins.length == 0) return null;
    var codes = coins.map((a) => a['code']);
    if (codes.contains('BSV'))
      return 'BSV';
    else return codes.first;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'ambassador_email': ambassadorEmail,
      'physical_address': physicalAddress,
      'business_name': businessName,
      'denomination': denomination,
      'email': email,
    };
  }

  factory Account.fromMap(Map<String, dynamic> body) {
    var json = body['account'] ?? body;

    return Account(
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
