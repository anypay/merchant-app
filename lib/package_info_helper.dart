import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoPlusHelper {
  static String version = "";
  static String build = "";
  static Future init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    build = packageInfo.buildNumber;
  }
}
