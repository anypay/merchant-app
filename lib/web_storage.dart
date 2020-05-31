import 'dart:html' show window;

class Storage {
  static Future<String> read(String key) async {
    return await window.localStorage[key];
  }

  static void write(String key, String value) async {
    window.localStorage[key] = value;
  }
}
