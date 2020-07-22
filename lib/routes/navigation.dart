import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationPage(title: 'Navigation');
  }
}

class NavigationPage extends StatefulWidget {
  NavigationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _AccountEmailAddress(),
                  _ToggleDarkMode(),
                  ..._Links(),
                  CircleBackButton(
                    margin: EdgeInsets.all(20.0),
                    backPath: '/new-invoice',
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _Links() {
    return [
      Container(
        margin: EdgeInsets.all(20.0),
        child: GestureDetector(
          child: Text("Payments", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppController.blue,
            fontSize: 22,
          )),
          onTap: () {
            Navigator.pushNamed(context, '/payments');
          }
        ),
      ),
      Container(
        margin: EdgeInsets.all(20.0),
        child: GestureDetector(
          child: Text("Settings", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppController.blue,
            fontSize: 22,
          )),
          onTap: () {
            Navigator.pushNamed(context, '/settings');
          }
        ),
      ),
      Container(
        margin: EdgeInsets.all(20.0),
        child: GestureDetector(
          child: Text("Logout", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppController.red,
            fontSize: 22,
          )),
          onTap: () {
            Authentication.logout();
          }
        ),
      )
    ];
  }

  Widget _ToggleDarkMode() {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: GestureDetector(
        child: Text(
          AppController.enableDarkMode ? "Light Mode" : "Dark Mode",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppController.blue,
            fontSize: 22,
          ),
        ),
        onTap: () {
          AppController.toggleDarkMode();
          AppController.of(context).rebuild();
        }
      ),
    );
  }

  Widget _AccountEmailAddress() {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Text(Authentication.currentAccount.email ?? "", style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppController.grey,
        fontSize: 18,
      )),
    );
  }
}



