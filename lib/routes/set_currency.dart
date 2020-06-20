import 'package:email_validator/email_validator.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
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
  var _chosenCurrency;

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

  Widget _FilterBar() {
    return Container(
      width: 400,
      child: Row(
        children: <Widget>[
          CircleBackButton(
            margin: EdgeInsets.only(top: 10.0, left: 10.0),
            backPath: '/navigation',
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 0.0, bottom: 10.0),
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
    );
  }

  List<Widget> _CurrencyList() {
    return visibleCurrencies.keys.map((currency) {
      var details = visibleCurrencies[currency];
      var name = details['currency_name'];
      var symbol = details['symbol'];
      var display = [currency, symbol, name];
      display.removeWhere((value) => value == null);

      return Container(
        width: 400,
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: _chosenCurrency == currency ? Color(0xFFEEEEEE) : Colors.white,
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
            setState(() { _chosenCurrency = currency; });
            Authentication.updateAccount({
              'denomination': currency,
            }).then((response) {
              setState(() {
                if (response['success']) _back();
                else _errorMessage = response['message'];
              });
            });
          }
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              margin: EdgeInsets.only(top: 50.0),
            ),
            _FilterBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _CurrencyList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


