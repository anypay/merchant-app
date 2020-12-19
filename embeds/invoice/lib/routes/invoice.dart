import 'package:moneybutton_flutter_web/moneybutton_flutter_web.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/models/invoice.dart';
import 'package:app/app_controller.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';
import 'dart:html';

import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) '../web_launcher.dart';


class ShowInvoice extends StatelessWidget {
  ShowInvoice(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return InvoicePage(id: id);
  }
}

class InvoicePage extends StatefulWidget {
  InvoicePage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _InvoicePageState createState() => _InvoicePageState(id);
}

class _InvoicePageState extends State<InvoicePage> {
  _InvoicePageState(this.id);

  Map<String, dynamic> chosenPaymentOption;
  bool _showLinkToWalletHelp = false;
  bool businessNameFetched = false;
  bool _moneyButtonLoaded = false;
  bool choosingCurrency = false;
  String _successMessage = '';
  bool usePayProtocol = true;
  bool _invoiceReady = false;
  bool _submitting = false;
  StreamSubscription event;
  Timer havingTroubleTimer;
  bool useUrlStyle = true;
  bool _disposed = false;
  Timer periodicRequest;
  String _errorMessage;
  String businessName;
  String currency;
  Color qrColor;
  String uri;
  String id;


  Invoice invoice;
  Map<String, dynamic> get bsvPaymentOption => invoice.bsvPaymentOption;

  final FocusNode keyboardFocusNode = FocusNode();


  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(keyboardFocusNode); // <-- yup.  magic. no idea.
    return RawKeyboardListener(
      focusNode: keyboardFocusNode,
      autofocus: true,
      onKey: (key) {
        if (key.data.keyLabel == 'Escape')
          postMessage(event: 'close');
      },
      child: GestureDetector(
        onTap: _closeKeyboard,
        child: Scaffold(
          floatingActionButton: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: CircleBackButton(
                  margin: EdgeInsets.all(AppController.scale(30)),
                  onTap: () => postMessage(event: 'close'),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Visibility(
                  visible: _showInvoice(),
                  child: GestureDetector(
                    onTap: _openHelpUrl,
                    child: Image(
                      image: AssetImage(AppController.havingIssuesImagePath()),
                      width: AppController.scale(40),
                    )
                  )
                ),
              ),
            ]
          ),
          body: Center(
            // child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _PageContent(),
                  Container(),
                ],
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    event.cancel();
    super.dispose();
    _disposed = true;
    periodicRequest.cancel();
    havingTroubleTimer.cancel();
  }

  void _copyUri() {
    Clipboard.setData(ClipboardData(text: uri));
    setState(() => _successMessage = "Coppied!" );
    Timer(Duration(seconds: 2), () {
      setState(() => _successMessage = "" );
    });
  }

  void _openHelpUrl() async {
    await launch("https://api.anypayinc.com/support/unauthenticated");
  }

  void _openUri() async {
    await launch(uri);
  }

  void _done() {
    if (_submitting) return;
    _closeKeyboard();
    setState(() {
      _submitting = true;
    });
    periodicRequest.cancel();
  }

  void _backToNewInvoice() {
    AppController.closeUntilPath('/new-invoice');
  }

  void _toggleUrlStyle() {
    useUrlStyle = !useUrlStyle;
    _rebuild();
  }

  void _chooseCurrency() {
    if (invoice.paymentOptions.length > 1)
      choosingCurrency = true;
    _rebuild();
  }

  String getFormat() {
    if (usePayProtocol)
      return 'pay';
    else if (useUrlStyle)
      return 'url';
  }

  void _rebuild() {
    setState(() {
      currency = currency ?? invoice?.currency;
      uri = invoice?.uriFor(currency, format: getFormat());
    });
    if (invoice != null && _invoiceReady == false) {
      Timer(Duration(milliseconds: 10), () {
        _invoiceReady = true;
        _rebuild();
      });
    }
  }

  void _fetchInvoice() {
    if (invoice == null || (invoice.isUnpaid && !invoice.isExpired))
      Client.getInvoice(id).then((response) {
        _errorMessage = null;
        if (response['success']) {
          var wasExpired = invoice?.isExpired;
          var statusWas = invoice?.status;
          invoice = response['invoice'];
          if (invoice.isExpired == true) {
            if (wasExpired != true)
              postMessage(event: 'update', status: 'expired');
          } else if (statusWas != invoice.status)
            postMessage(event: 'update', status: invoice.status);

          _fetchBusinessName();
        } else _errorMessage = response['message'];

        // Checking if disposed to prevent memory leaks
        if (!_disposed) _rebuild();
      });
  }

  void postMessage({event, status}) {
    var message = {
      'from': "anypay",
      'event': event,
    };
    if (status != null)
      message['status'] = status;
    window.parent.postMessage(message, '*');
  }

  void _fetchBusinessName() {
    if (invoice?.accountId == null || businessNameFetched) return;
    businessNameFetched = true;
    Client.getAccount(invoice.accountId).then((response) {
      if (response['success'])
        businessName = response['body']['name'];
      print("NAME::::::: ${businessName}");
    });
  }



  @override
  void initState() {
    super.initState();
    _fetchInvoice();
    qrColor = AppController.randomColor;
    periodicRequest = Timer.periodic(Duration(seconds: 2), (timer) => _fetchInvoice());
    havingTroubleTimer = Timer(Duration(seconds: 50), () {
      setState(() => _showLinkToWalletHelp = true );
    });
    // Use if we rebuild with server events:
    // Use if we rebuild with server events:
    // Use if we rebuild with server events:
    // Use if we rebuild with server events:
    //
    // event = Events.on('invoice.paid', (payload) {
    //   invoice = Invoice.fromMap(payload);
    //   _rebuild();
    // });
  }

  Widget _ChooseCurrencyMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 300,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: _PaymentTitle('anypay'),
            onTap: () {
              choosingCurrency = false;
              usePayProtocol = true;
              _rebuild();
            },
          )
        ),
        ...(invoice.paymentOptions.map((option) {
          return Container(
            width: 300,
            margin: EdgeInsets.only(top: 10),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: _PaymentTitle(option['currency'], paymentOption: option),
              onTap: () {
                currency = option['currency'];
                chosenPaymentOption = option;
                choosingCurrency = false;
                usePayProtocol = false;
                useUrlStyle = true;
                _rebuild();
              },
            )
          );
        })),
      ]
    );
  }

  Widget _UnderpaidScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppController.red,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 120,
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(invoice.amountWithDenomination(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).primaryColorLight,
                fontSize: 28,
              ),
            ),
          ),
          Text(invoice.paidAmountWithDenomination(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
              fontSize: 28,
            ),
          ),
        ]
      )
    );
  }

  Widget _WebShareOptions() {
    return Container(
      width: 235,
      margin: EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _copyUri,
            child: Row(
              children: <Widget>[
                Text('Copy', style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                )),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Image(
                    image: AppController.enableDarkMode ?
                      AssetImage('assets/images/copy_icon-white.png') :
                      AssetImage('assets/images/copy_icon.png'),
                    width: 20,
                  )
                )
              ]
            )
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _openUri,
            child: Row(
              children: <Widget>[
                Text('Open Wallet', style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                )),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Image(
                    image: AppController.enableDarkMode ?
                      AssetImage('assets/images/wallet_icon-white.png') :
                      AssetImage('assets/images/wallet_icon.png'),
                    width: 20,
                  )
                )
              ]
            )
          ),
        ]
      ),
    );
  }

  Widget _PaidScreen() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image(
              width: AppController.scale(140),
              image: AssetImage('assets/images/anypay-logo.png')
            ),
          ),
          ConfettiWidget(
            confettiController: ConfettiController(
              duration: Duration(seconds: 1),
            )..play(),
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 60,
            minBlastForce: 30,
            numberOfParticles: 20,
            shouldLoop: false,
            colors: AppController.colors,
          ),
          Container(
            child: Text('PAID!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF34b83a),
                fontSize: AppController.scale(48, minValue: 44),
              ),
            ),
          ),
          Container(
            child: Text(businessName ?? "",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppController.scale(35), bottom: 5),
            child: Text(invoice.amountWithDenomination(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
                fontSize: 28,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: AppController.scale(35)),
            child: Text(invoice.inCurrency(),
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
          Visibility(
            visible: (invoice.notes ?? []).length > 0,
            child: Column(
              children: [
                Text("Order Notes:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 20,
                  ),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(invoice.noteText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppController.scale(30), bottom: 20),
            child: _submitting ?
              SpinKitCircle(
                  size: AppController.scale(50, minValue: 40),
                  color: AppController.randomColor,
              ) : Container(),
          )
        ]
      )
    );
  }

  Widget _ExpiredInvoice() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 35),
          child: Text("Invoice Expired",
            style: TextStyle(
              fontSize: 31,
              color: Theme.of(context).primaryColorLight,
            )
          )
        ),
      ],
    );
  }

  Widget _PaymentTitle(currency, {paymentOption}) {
    paymentOption = paymentOption ?? chosenPaymentOption;
    var coinDetailsSpecified = paymentOption != null;
    var coinIsSupported = Coins.supported[currency] != null;

    paymentOption = paymentOption ?? {};
    if (currency == 'anypay' || coinIsSupported || coinDetailsSpecified)
      return Container(
        child: Row(
          children: currency == 'anypay' ? [
            Container(
              width: 60,
              child: Image(
                image: AssetImage('assets/images/anypay-logo.png')
              ),
            ),
            Text('Anypay',
              style: TextStyle(fontSize: 35),
            ),
          ] : [
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 15, bottom: 15),
              child: Image.network(paymentOption['currency_logo_url'] ?? Coins.supported[currency]['icon']),
            ),
            Text(paymentOption['currency_name'] ?? Coins.supported[currency]['name'],
              style: TextStyle(fontSize: 40),
            ),
          ]
        )
      );
    else return Container();
  }

  bool _showInvoice() {
    return invoice != null &&
      !invoice.isUnderpaid &&
      !invoice.isExpired &&
      !invoice.isPaid &&
      !choosingCurrency;
  }

  Widget _PageContent() {
    if (_showInvoice())
      return _InvoiceComponent();
    else if (invoice == null)
      if (_errorMessage != null)
        return Text(_errorMessage, style: TextStyle(color: AppController.red));
      else return Container(
          child: SpinKitCircle(color: qrColor),
          height: AppController.scale(360),
        );
    else if (invoice.isUnderpaid)
      return _UnderpaidScreen();
    else if (invoice.isPaid)
      return _PaidScreen();
    else if (choosingCurrency)
      return _ChooseCurrencyMenu();
    else if (invoice.isExpired)
      return _ExpiredInvoice();
  }

  Widget _InvoiceComponent() {
    return AnimatedOpacity(
      opacity: _invoiceReady ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(_successMessage,
            style: TextStyle(color: AppController.green),
          ),
          Visibility(
            visible: _showLinkToWalletHelp,
            child: GestureDetector(
              onTap: _openHelpUrl,
              child: Text('Having trouble paying?',
                style: TextStyle(color: AppController.blue)
              )
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _chooseCurrency,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PaymentTitle(usePayProtocol ? 'anypay' : currency),
                  Visibility(
                    visible: invoice.paymentOptions.length > 1,
                    child: Container(
                      width: 40,
                      height: 42,
                      margin: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.expand_more, size: 50)
                    )
                  )
                ]
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 12.0,
                color: qrColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
            ),
            child: Container(
              color: AppController.white,
              margin: EdgeInsets.all(12.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleUrlStyle,
                child: QrImage(
                  foregroundColor: Color(0xFF404040),
                  version: QrVersions.auto,
                  size: AppController.scale(220, maxValue: 280, minValue: 100),
                  data: uri,
                ),
              ),
            ),
          ),
          _WebShareOptions(),
          Container(
            width: 300,
            height: 150,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: 300,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                  child: kIsWeb && bsvPaymentOption == null ? null : 
                    MoneyButton({
                      'clientIdentifier': '3de67950b83c16c9dd343f691bc71887',
                      'outputs': [{
                        "to": bsvPaymentOption['address'],
                        "amount": bsvPaymentOption['amount'],
                        "currency": bsvPaymentOption['currency'],
                      }, {
                        'to': 'steven@simply.cash',
                        'amount': 0.00009, // $0.02
                        'currency': 'BSV'
                      }],
                      'buttonId': bsvPaymentOption['invoice_uid'],
                    }, width: 200,
                    height: 300,
                    onLoaded: () {
                      _moneyButtonLoaded = true;
                    },
                  ),
                )
              )
            )
          )
        ]
      )
    );
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }
}



