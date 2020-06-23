import 'package:app/authentication.dart';
import 'package:flutter/material.dart';

import 'package:app/native_storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  static bool enableDarkMode = false;

  static String logoImagePath() {
    var modifier = enableDarkMode ? '-white' : '';
    return 'assets/images/anypay-full-logo$modifier.png';
  }

  static Color randomColor = randomizeColor();

  static Color randomizeColor() {
    randomColor = (colors..shuffle()).first;
  }

  static void toggleDarkMode([value = null]) {
    AppBuilder.enableDarkMode = value ?? !AppBuilder.enableDarkMode;
    saveDarkModeToDisk();
  }

  static Future<void> checkForDarkMode(context) {
    return Storage.read('enableDarkMode').then((darkMode) {
      if (darkMode != null) enableDarkMode = true;
    });
  }

  static Future<void> saveDarkModeToDisk() async {
    if (AppBuilder.enableDarkMode)
      return await Storage.write('AppBuilder.enableDarkMode', 'true');
    else return await Storage.delete('enableDarkMode');
  }

  static List<Color> colors = [
    0xFF8c5ca6,
    0xFF0177c0,
    0xFF1a8e5a,
    0xFFcfa015,
    0xFFc74a43,
  ].map((hex) => Color(hex)).toList();

  const AppBuilder(
      {Key key, this.builder})
  : super(key: key);

  @override
  AppBuilderState createState() => new AppBuilderState();

  static AppBuilderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<AppBuilderState>());
  }
}

class AppBuilderState extends State<AppBuilder> {

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}
