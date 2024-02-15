class Coins {

  static Map<CoinCode, dynamic> all = {};
  static Map<CoinCode, dynamic> supported = {};
}

class CoinCode {
  String code;
  String chain;

  CoinCode(this.code, this.chain);

  @override
  int get hashCode => Object.hash(code, chain);

  @override
  bool operator ==(Object other) {
    return other is CoinCode &&
        other.code == code &&
        other.chain == chain;
  }

  factory CoinCode.fromString(String code) {
    var coinCode = code.contains('_') ? code.split('_')[0] : code;
    var coinChain = code.contains('_') ? code.split('_')[1] : code;

    return CoinCode(coinCode, coinChain);
  }
}
