import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import 'package:app/native_storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

class AppController extends StatefulWidget {
  final Function(BuildContext) builder;

  static final globalKey = new GlobalKey<NavigatorState>();
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
    enableDarkMode = value ?? !enableDarkMode;
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
    if (enableDarkMode)
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

  static BuildContext getCurrentContext() {
    return globalKey.currentState.overlay.context;
  }

  static void openDialog(title, body, {path: null, buttonText: null, buttons: null}) async {
    var context = getCurrentContext();
    buttons ??= [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(title),
          subtitle: Text(body),
        ),
        actions: <Widget>[
          ...buttons.map((button) {
            return FlatButton(
              child: Text(button['text']),
              onPressed: () {
                Navigator.of(context).pop();
                button['onPressed']();
              },
            );
          }),
          FlatButton(
            child: Text(buttonText ?? 'Ok'),
            onPressed: () {
              Navigator.of(context).pop();
              if (path != null)
                openPath(path);
            },
          ),
        ],
      ),
    );
  }

  static void closeUntilPath(String path) {
    Navigator.pushNamedAndRemoveUntil(getCurrentContext(), path, (Route<dynamic> route) => false);
  }

  static void openPath(String path) async {
    if (path != null) Navigator.pushNamed(getCurrentContext(), path);
  }

  const AppController(
      {Key key, this.builder})
  : super(key: key);

  @override
  AppControllerState createState() => new AppControllerState();

  static AppControllerState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<AppControllerState>());
  }
}

class AppControllerState extends State<AppController> {

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}
