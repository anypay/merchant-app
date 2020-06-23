import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';

class NewAddress extends StatelessWidget {
  NewAddress(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return NewAddressPage(code: code);
  }
}

class NewAddressPage extends StatefulWidget {
  NewAddressPage({Key key, this.code}) : super(key: key);

  final String code;

  @override
  _NewAddressPageState createState() => _NewAddressPageState(code);
}

class _NewAddressPageState extends State<NewAddressPage> {
  _NewAddressPageState(this.code);

  final _formKey = GlobalKey<FormState>();
  final String code;

  var _errorMessage = '';
  var _successMessage = '';

  @override
  void initState() {
    super.initState();
    Authentication.fetchCoins().then((v) {
      setState(() {
        _successMessage = Authentication.currentAccount.addressFor(this.code) ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: Row(
                children: [
                  Container(
                    width: 75,
                    margin: EdgeInsets.only(
                      top: 10.0,
                      right: 50.0,
                      bottom: 10.0,
                    ),
                    child: Image.network(
                      Coins.all[code]['icon']
                    ),
                  ),
                  Text(
                    Coins.all[code]['name'],
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  )
                ]
              ),
            ),
            Container(
              width: 300,
              margin: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_successMessage,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  Text(_errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'paste $code address'
                    ),
                    onChanged: (text) {
                      setState(() {
                        _successMessage = '';
                        _errorMessage = '';
                      });
                      Client.setAddress(code, text).then((response) {
                        setState(() {
                          if (response['success']) {
                            _successMessage = 'Saved!';
                            _errorMessage = "";
                            Authentication.fetchCoins();

                            Timer(Duration(seconds: 2), () {
                              Navigator.pushNamedAndRemoveUntil(context, '/new-invoice', (Route<dynamic> route) => false);
                            });
                          } else _errorMessage = response['message'];
                        });
                      });
                    }
                  ),
                ],
              ),
            ),
            CircleBackButton(
              margin: EdgeInsets.only(top: 20.0),
              backPath: '/settings',
            ),
          ],
        ),
      ),
    );
  }
}

