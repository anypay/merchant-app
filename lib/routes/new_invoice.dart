import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import 'dart:math';

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
  String _visiblePrice = 0.toStringAsFixed(2);
  var _errorMessage = '';
  String _currencySymbol;
  double _price = 0;

  void _rebuild() {
    setState(() {
      _currencySymbol = Authentication.currentAccount.currencySymbol();
    });
  }

  void _submit() {
    setState(() { _errorMessage = ""; });
    if (Authentication.currentAccount.coins.length > 0)
      Client.createInvoice(_price, 'BSV').then((response) {
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
                  _price > 0 ? '$_currencySymbol$_visiblePrice' : "",
                  style: TextStyle(
                    fontSize: _scale(40, minValue: 40),
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

  void _backspace() {
    setState(() {
      _price = (_price * 10).truncateToDouble()/100;
      _visiblePrice = _price.toStringAsFixed(2);
    });
  }

  void _updatePrice(i) {
    setState(() {
      _price = (_price * 1000 + i).truncateToDouble()/100;
      _visiblePrice = _price.toStringAsFixed(2);
    });
  }

  Widget _generateButton({text, onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: _scaledVerticalMargin(30),
        width: 100,
        child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _scale(31, minValue: 25),
            color: Color(0xFF404040),
            fontWeight: FontWeight.bold,
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

