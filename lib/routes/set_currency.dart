import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:email_validator/email_validator.dart';
import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
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
  Map<String, dynamic> visibleCurrencies = Currencies.all;
  String _errorMessage = '';
  String _chosenCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.only(top: AppController.topPadding()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_errorMessage, style: TextStyle(color: AppController.red)),
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
      ),
    );
  }

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
      margin: EdgeInsets.only(bottom: AppController.scale(10.0)),
      width: 400,
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0),
            child: (_chosenCurrency == null ?
              CircleBackButton(
                backPath: '/navigation',
              ) : SpinKitCircle(color: AppController.randomColor)
            )
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
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight.withOpacity(_chosenCurrency == currency ? 0.1 : 0),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).primaryColorLight,
              width: 1.0
            ),
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Text(display.join(' - '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          onTap: () {
            setState(() { _chosenCurrency = currency; });
            Authentication.updateAccount({
              'denomination': currency,
            }).then((response) {
              setState(() {
                if (response['success']) _back();
                else {
                  _chosenCurrency = null;
                  _errorMessage = response['message'];
                }
              });
            });
          }
        ),
      );
    }).toList();
  }
}


