import 'package:app/authentication.dart';
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
                  Container(
                    margin: EdgeInsets.all(20.0),
                    child: Text(Authentication.currentAccount.email ?? "", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 18,
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    child: GestureDetector(
                      child: Text("Payments", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
                        color: Colors.blue,
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
                        color: Colors.red,
                        fontSize: 22,
                      )),
                      onTap: () {
                        Authentication.logout();
                      }
                    ),
                  ),
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
}



