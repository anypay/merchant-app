import 'package:universal_html/html.dart' show window;

class Storage {
  static Future<String> read(String key) async {
    return await window.localStorage[key];
  }

  static Future<void> write(String key, String value) async {
    window.localStorage[key] = value;
  }

  static Future<void> delete(String key) async {
    window.localStorage[key] = null;
  }
}
