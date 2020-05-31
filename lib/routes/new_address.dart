import 'package:flutter/material.dart';
import 'package:app/client.dart';
import '../coins.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Container(
                  width: 75,
                  margin: EdgeInsets.only(
                    top: 10.0,
                    left: 50.0,
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
            Container(
              width: 300,
              margin: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_successMessage,
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(_errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'paste $code address'
                    ),
                    onChanged: (text) {
                      Client.setAddress(code, text).then((response) {
                        setState(() {
                          if (response['success'])
                            _successMessage = 'Saved!';
                          else _errorMessage = response['message'];
                        });
                      });
                    }
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                onPressed: () {
                  if (Navigator.canPop(context))
                    Navigator.pop(context, true);
                  else
                    Navigator.pushNamedAndRemoveUntil(context, '/settings', (Route<dynamic> route) => false);
                },
                child: Text('BACK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

