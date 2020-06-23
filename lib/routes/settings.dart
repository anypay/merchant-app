import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/currencies.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsPage(title: 'Settings');
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _successMessage = '';
  var denomination;
  var symbol;

  void _rebuild() {
    setState(() {
      denomination = Authentication.currentAccount.denomination ?? 'USD';
      symbol = Currencies.all[denomination]['symbol'];
    });
  }

  @override
  void initState() {
    _rebuild();
    super.initState();
    Authentication.getAccount().then((account) {
      _rebuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_successMessage,
              style: TextStyle(color: Colors.green),
            ),
            Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Row(
                              children: <Widget>[
                                Text("Currency ", style: TextStyle(
                                  fontSize: 22,
                                )),
                                Text("($symbol$denomination)", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                )),
                              ],
                            )
                          ),
                          Icon(Icons.edit),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings/currency').then((value) {
                          _successMessage = 'Saved!';
                          _rebuild();
                        });
                      }
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    child: GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Text("Business Info", style: TextStyle(
                              fontSize: 22,
                            )),
                          ),
                          Icon(Icons.edit),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings/business-info');
                      }
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(20.0),
                            child: Text("Addresses", style: TextStyle(
                              fontSize: 22,
                            ))
                          ),
                          Icon(Icons.edit),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings/addresses').then((value) {
                          _successMessage = '';
                          _rebuild();
                        });
                      }
                    ),
                  ),
                  CircleBackButton(
                    margin: EdgeInsets.only(top: 20.0),
                    backPath: '/navigation',
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


