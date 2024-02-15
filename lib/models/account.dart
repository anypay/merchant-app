import 'package:app/coins.dart';
import 'package:app/models/address.dart';
import 'dart:convert';

class Account {
  Map<CoinCode, dynamic> addresses = {};
  bool fetchingCoins = false;
  String? physicalAddress;
  String? businessName;
  String? denomination;
  String? email;

  List coins = [];

  Account({
    this.physicalAddress,
    this.businessName,
    this.denomination,
    this.email,
  });

  String toJson() {
    return jsonEncode(toMap());
  }

  Address? addressFor(CoinCode coinCode) {
    return addresses[coinCode];
  }

  String? get preferredCoinCode {
    if (coins.length == 0) {
      return null;
    };

    var codes = coins.map((coin) => coin['code']);

    if (codes.contains('BSV')) {
      return 'BSV';
    }

    else {
      return codes.first;
    };
  }

  Map<dynamic, dynamic> toMap() {
    return {
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
