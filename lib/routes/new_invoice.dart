import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:app/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/app_builder.dart';
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
  String _visiblePrice = '';
  bool _submitting = false;
  var _errorMessage = '';
  Invoice _invoice;
  num _price = 0;

  void _rebuild() {
    setState(() {
      _setInvoice();
      _setVisiblePrice();
    });
  }

  void _submit() {
    if (_submitting) return;

    _submitting = true;
    AppBuilder.randomizeColor();
    setState(() { _errorMessage = ""; });
    var account = Authentication.currentAccount;

    if (account.coins.length > 0)
      Client.createInvoice(_price, account.preferredCoinCode()).then((response) {
        if (response['success']) {
          var invoiceId = response['invoiceId'];
          Navigator.pushNamed(context, '/invoices/$invoiceId').then((_) {
            setState(() { _submitting = false; });
          });
        } else setState(() {
          _errorMessage = response['message'];
          _submitting = false;
        });
      });
    else Navigator.pushNamed(context, '/settings/addresses').then((result) {
     _submitting = false;
     _rebuild();
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
                  _submitting ?
                  SpinKitCircle(color: AppBuilder.randomColor) : GestureDetector(
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

  void _setInvoice() {
    _invoice = Invoice(
      denominationCurrency: Authentication.currentAccount.denomination,
      denominationAmount: _price,
    );
  }

  void _setVisiblePrice() {
    _setInvoice();
    _visiblePrice = _invoice.amountWithDenomination();
  }

  void _backspace() {
    var denominator = pow(10, _invoice.decimalPlaces());
    _price = (_price * 0.1 * denominator).truncateToDouble()/denominator;
    _errorMessage = "";
    _rebuild();
  }

  void _updatePrice(i) {
    if (_price >= 92233720368547.76) return;
    var denominator = pow(10, _invoice.decimalPlaces());
    _price = (_price * 10 * denominator + i).round().toDouble()/denominator;
    _errorMessage = "";
    _rebuild();
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
            color: Theme.of(context).primaryColorLight,
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

