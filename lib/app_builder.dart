import 'package:app/authentication.dart';
import 'package:flutter/scheduler.dart';
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
    return randomColor;
  }

  static void toggleDarkMode([value = null]) {
    AppBuilder.enableDarkMode = value ?? !AppBuilder.enableDarkMode;
    saveDarkModeToDisk();
  }

  static Future<void> checkForDarkMode(context) {
    return Storage.read('enableDarkMode').then((darkMode) {
      if (darkMode == null)
        enableDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
      else if (darkMode != 'false') enableDarkMode = true;
    });
  }

  static Future<void> saveDarkModeToDisk() async {
    if (AppBuilder.enableDarkMode)
      return await Storage.write('enableDarkMode', 'true');
    else return await Storage.write('enableDarkMode', 'false');
  }

  static Color yellow = Color(0xFFcfa015);
  static Color purple = Color(0xFF8c5ca6);
  static Color green = Color(0xFF1a8e5a);
  static Color blue = Color(0xFF0177c0);
  static Color red = Color(0xFFc74a43);
  static Color white = Colors.white;
  static Color grey = Colors.grey;

  static List<Color> colors = [
    purple,
    yellow,
    green,
    blue,
    red,
  ].toList();

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