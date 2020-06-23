import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";
import 'dart:math';
import 'dart:io';


class NewInvoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewInvoicePage(title: 'Anypay Cash Register');
  }
}


class NewInvoicePage extends StatefulWidget {
  NewInvoicePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewInvoicePageState createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  String _visiblePrice = '';
  int _decimalPlaces = 2;
  var _errorMessage = '';
  String _currencySymbol;
  num _price = 0;

  void _rebuild() {
    setState(() {
      var data = Authentication.currentAccount.currencyData();
      _currencySymbol = data['symbol'] ?? '';
      _decimalPlaces = data['decimal_places'] ?? 2;
      _setVisiblePrice();
    });
  }

  void _submit() {
    setState(() { _errorMessage = ""; });
    var account = Authentication.currentAccount;
    if (account.coins.length > 0)
      Client.createInvoice(_price, account.preferredCoinCode()).then((response) {
        if (response['success']) {
          var invoiceId = response['invoiceId'];
          Navigator.pushNamed(context, '/invoices/$invoiceId');
        } else setState(() { _errorMessage = response['message']; });
      });
    else Navigator.pushNamed(context, '/settings/addresses');
  }

  @override
  void initState() {
    super.initState();
    Authentication.getAccount().then((account) {
      _rebuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
              Container(
                child: Text(
                  _price > 0 ? '$_visiblePrice' : "",
                  style: TextStyle(
                    fontSize: (40 - 1.5*max(_visiblePrice.length-8, 0)).toDouble(),
                  )
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ..._generateNumberButtons(),
                  _generateButton(
                    text: _price > 0 ? "⌫" : "",
                    onTap: _backspace,
                    font: 'Default',
                  ),
                  GestureDetector(
                    onTap: _submit,
                    child: Visibility(
                      visible: _price > 0,
                      maintainAnimation: true,
                      maintainState: true,
                      maintainSize: true,
                      child: Image(
                        image: AssetImage('assets/images/next_arrow.png'),
                        width: _scale(50),
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        child: Align(
          alignment: Alignment(-0.85, -0.85),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/navigation').then((value) => _rebuild()),
            child: Image(
              image: AssetImage('assets/images/anypay-logo.png'),
              width: _scale(70),
            )
          )
        )
      ),
    );
  }

  void _setVisiblePrice() {
    try {
      _visiblePrice = NumberFormat.currency(
        decimalDigits: _decimalPlaces,
        locale: Platform.localeName,
        symbol: _currencySymbol,
      ).format(_price);
    } catch(e) {
      // Fallback in case there is an unsupported locale
      _visiblePrice = _price.toStringAsFixed(_decimalPlaces);
      _visiblePrice = _visiblePrice.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      _visiblePrice = "$_currencySymbol$_visiblePrice";
    }
  }

  void _backspace() {
    setState(() {
      var denominator = pow(10, _decimalPlaces);
      _price = (_price * 0.1 * denominator).truncateToDouble()/denominator;
      _setVisiblePrice();
    });
  }

  void _updatePrice(i) {
    setState(() {
      if (_price >= 92233720368547.76) return;
      var denominator = pow(10, _decimalPlaces);
      _price = (_price * 10 * denominator + i).round().toDouble()/denominator;
      _setVisiblePrice();
    });
  }

  Widget _generateButton({text, onTap, font}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: _scaledVerticalMargin(30),
        width: 100,
        child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _scale(31, minValue: 25),
            fontFamily: font ?? 'Ubuntu',
            fontWeight: FontWeight.bold,
            color: Color(0xFF404040),
          )
        ),
      )
    );
  }
  List<Widget> _generateNumberButtons() {
    return List<Widget>.generate(11, (i)  {
      int num = (i + 1) % 11;
      return _generateButton(
        text: num == 10 ? '' : num.toString(),
        onTap: () { _updatePrice(num); },
      );
    });
  }

  double _scale(num value, {num maxValue, num minValue}) {
    var screenData = MediaQuery.of(context);
    value = value * screenData.size.height/650;
    value = min(value, maxValue ?? double.maxFinite);
    value = max(value, minValue ?? 0);
    return value;
  }

  EdgeInsets _scaledVerticalMargin(num value, {num maxValue, num minValue}) {
    value = _scale(value, maxValue: maxValue, minValue: minValue);
    return EdgeInsets.only(top: value, bottom: value);
  }

}

