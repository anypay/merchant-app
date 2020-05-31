import 'package:email_validator/email_validator.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/currencies.dart';
import 'package:app/client.dart';

class SetCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SetCurrencyPage(title: 'Set Currency');
  }
}

class SetCurrencyPage extends StatefulWidget {
  SetCurrencyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SetCurrencyPageState createState() => _SetCurrencyPageState();
}

class _SetCurrencyPageState extends State<SetCurrencyPage> {
  var visibleCurrencies = Currencies.all;
  var _errorMessage = '';

  _back() {
    if (Navigator.canPop(context))
      Navigator.pop(context, true);
    else
      Navigator.pushNamedAndRemoveUntil(context, '/settings', (Route<dynamic> route) => false);
  }

  void _filterList(text) {
    setState(() {
      text = text.toLowerCase();
      visibleCurrencies = Map.from(Currencies.all)..removeWhere((key, value) {
        return !key.toLowerCase().contains(text) &&
          !(value['currency_name'] as String).toLowerCase().contains(text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 40.0),
                      child: RaisedButton(
                        onPressed: () {
                          if (Navigator.canPop(context))
                            Navigator.pop(context, true);
                          else
                            Navigator.pushNamedAndRemoveUntil(context, '/navigation', (Route<dynamic> route) => false);
                        },
                        child: Text('BACK'),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 40.0, bottom: 40.0),
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search Currencies'
                          ),
                          onChanged: (text) {
                            _filterList(text);
                          }
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: visibleCurrencies.keys.map((currency) {
                        var details = visibleCurrencies[currency];
                        var name = details['currency_name'];
                        var symbol = details['symbol'];
                        var display = [currency, symbol, name];
                        display.removeWhere((value) => value == null);

                        return Container(
                          width: 400,
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0),
                            ),
                          ),
                          child: GestureDetector(
                            child: Text(display.join(' - '),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              Authentication.updateAccount({
                                'denomination': currency,
                              }).then((response) {
                                setState(() {
                                  if (response['success'])
                                    _back();
                                  else _errorMessage = response['message'];
                                });
                              });
                            }
                          ),
                        );
                      }).toList(),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: RaisedButton(
                        onPressed: () {
                          if (Navigator.canPop(context))
                            Navigator.pop(context, true);
                          else
                            Navigator.pushNamedAndRemoveUntil(context, '/navigation', (Route<dynamic> route) => false);
                        },
                        child: Text('BACK'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


