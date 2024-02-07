import 'dart:convert';

class Merchant {
  Map<String, dynamic> addresses = {};
  bool fetchingCoins = false;
  String denomination;
  int accountId;
  String name;

  Merchant({
    this.name,
    this.accountId,
    this.denomination,
  });

  factory Merchant.fromMap(Map<String, dynamic> body) {
    var json = body['merchant'] ?? body;
    return Merchant(
      name: json['business_name'],
      accountId: json['account_id'],
      denomination: json['denomination'],
    );
  }

  factory Merchant.fromJson(String body) {
    return Merchant.fromMap(jsonDecode(body));
  }
}
