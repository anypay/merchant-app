import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/models/merchant.dart';
import 'package:app/authentication.dart';
import 'package:app/models/invoice.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';
import 'package:universal_html/html.dart' show HtmlDocument;
import 'package:universal_html/html.dart' show window;
import 'dart:async';
import 'dart:math';


class NewInvoice extends StatelessWidget {
  NewInvoice({this.merchantId});

  final String merchantId;

  @override
  Widget build(BuildContext context) {
    return NewInvoicePage(merchantId: merchantId);
  }
}


class NewInvoicePage extends StatefulWidget {
  NewInvoicePage({Key key, this.merchantId}) : super(key: key);

  final String merchantId;

  @override
  _NewInvoicePageState createState() => _NewInvoicePageState(merchantId: merchantId);
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  _NewInvoicePageState({this.merchantId});

  String _visiblePrice = '';
  String _errorMessage = '';
  bool _submitting = false;
  Merchant merchant;
  String merchantId;
  Invoice _invoice;
  num _price = 0;

  @override
  void initState() {
    _rebuild();
    super.initState();
    _fetchMerchant();
    _checkForDarkMode();
    if (merchantId == null)
      Authentication.getAccount().then((account) {
        _rebuild();
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _MerchantName(),
              Container(
                width: AppController.scale(300, maxValue: 720, minValue: 300),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: Text(_errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppController.red),
                      ),
                    ),
                    _VisiblePrice(),
                    _Buttons(),
                  ],
                ),
              ),
            ]
          )
        ),
      ),
      floatingActionButton: _navButton(),
    );
  }

  void _rebuild() {
    setState(() {
      _setInvoice();
      _setVisiblePrice();
    });
  }

  String get preferredCoinCode {
    return merchant?.denomination ?? Authentication.currentAccount.preferredCoinCode;
  }

  void _submit() {
    _submitting = true;
    AppController.randomizeColor();
    setState(() { _errorMessage = ""; });
    var account = Authentication.currentAccount;

    if (account.coins.length == 0 && account.fetchingCoins)
      Timer(Duration(milliseconds: 500), _submit);
    else if (preferredCoinCode != null)
      Client.createInvoice(_price, preferredCoinCode, accountId: merchant?.accountId).then((response) {
        if (response['success']) {
          var invoiceId = response['invoiceId'];
          Navigator.pushNamed(context, '/invoices/$invoiceId', arguments: {
            'redirectUrl': merchant != null ? (window.document as HtmlDocument).referrer : null,
            'merchant': merchant,
          }).then((_) {
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

  void _fetchMerchant() {
    if (merchantId != null)
      Client.fetchMerchant(merchantId).then((response) {
        if (response['success'])
          merchant = response['merchant'];
        else _errorMessage = response['message'];
        _rebuild();
      });
  }

  void _checkForDarkMode() {
    AppController.checkForDarkMode(context).then((_) {
      AppController.of(context).rebuild();
    });
  }

  Widget _MerchantName() {
    if (merchantId == null) return Container();
    if (merchant == null && _errorMessage == '')
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: SpinKitCircle(
          size: AppController.scale(30, minValue: 20),
          color: AppController.randomColor,
        )
      );
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(merchant.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          shadows: <Shadow>[
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 3.0,
              color: Color.fromARGB(180, 0, 0, 0),
            ),
          ],
          fontWeight: FontWeight.bold,
          fontSize: (65 - 1.5*max(merchant.name.length-8, 0)).toDouble(),
        )
      )
    );
  }

  Widget _VisiblePrice() {
    return Container(
      child: Text(
        _price > 0 ? '$_visiblePrice' : "",
        style: TextStyle(
          fontSize: (40 - 1.5*max(_visiblePrice.length-8, 0)).toDouble(),
        )
      ),
    );
  }

  Widget _Buttons() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: <Widget>[
        ..._generateNumberButtons(),
        _generateButton(
          text: "",
          onTap: _backspace,
          font: 'San Francisco',
          icon: _price > 0 ? AppController.backspaceImagePath() : null,
        ),
        Container(
          margin: EdgeInsets.only(top: AppController.scale(10)),
          height: AppController.scale(50, minValue: 40),
          child: _submitting ?
          SpinKitCircle(
              size: AppController.scale(50, minValue: 40),
              color: AppController.randomColor,
          ) : GestureDetector(
            onTap: _submit,
            child: Visibility(
              visible: _price > 0,
              maintainAnimation: true,
              maintainState: true,
              maintainSize: true,
              child: Image(
                image: AssetImage('assets/images/next_arrow.png'),
                width: AppController.scale(50, minValue: 40),
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _navButton() {
    return Align(
      alignment: Alignment(-0.85, -0.95),
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            !Authentication.isAuthenticated()? Container() : GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/navigation').then((value) => _rebuild()),
              child: Container(
                margin: EdgeInsets.only(top: 10.0, left: AppController.leftPadding() + 30),
                child: Icon(Icons.menu, size: 20+AppController.scale(20.0)),
              )
            ),
            Image(
              image: AssetImage('assets/images/anypay-logo.png'),
              width: 20 + AppController.scale(40),
            )
          ]
        )
      )
    );
  }

  void _setInvoice() {
    _invoice = Invoice(
      denominationCurrency: merchant?.denomination ?? Authentication.currentAccount?.denomination,
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

  Widget _generateButton({text, onTap, font, icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: AppController.scale(35)),
        height: AppController.scale(60),
        width: AppController.scale(100, maxValue: 240, minValue: 100).floor().toDouble(),
        child: icon == null ? Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppController.scale(31, minValue: 25),
            fontFamily: font ?? 'Ubuntu',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorLight,
          )
        ) : Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: AppController.scale(8) - 2),
            child: Image.asset(icon, width: 10 + AppController.scale(24))
          )
        )
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

}

