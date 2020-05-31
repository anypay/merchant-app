import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static Future<String> read(String key) async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'uid');
  }

  static void write(String key, String value) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }
}

