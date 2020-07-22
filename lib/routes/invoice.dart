import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rect_getter/rect_getter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app/authentication.dart';
import 'package:app/models/invoice.dart';
import 'package:app/app_controller.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/back_button.dart';
import 'package:share/share.dart';
import 'package:app/events.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';


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

  var notes = TextEditingController();
  bool choosingCurrency = false;
  bool usePayProtocol = true;
  bool _invoiceReady = false;
  var _successMessage = '';
  StreamSubscription event;
  bool useUrlStyle = true;
  bool _disposed = false;
  Timer periodicRequest;
  var _errorMessage;
  String notesError;
  String currency;
  Color qrColor;
  String uri;
  String id;

  var invoice;


  var sharePlacement;

  @override
  void dispose() {
    event.cancel();
    notes.dispose();
    super.dispose();
    _disposed = true;
    periodicRequest.cancel();
  }

  void _copyUri() {
    Clipboard.setData(ClipboardData(text: uri));
    setState(() => _successMessage = "Coppied!" );
    Timer(Duration(seconds: 2), () {
      setState(() => _successMessage = "" );
    });
  }

  void _openUri() async {
    await launch(uri);
  }

  void _done() {
    _closeKeyboard();
    setState(() { notesError = ""; });
    periodicRequest.cancel();

    if (notes.text.length > 0)
      Client.setInvoiceNotes(invoice.uid, notes.text).then((response) {
        if (response['success'])
          _backToNewInvoice();
        else setState(() => notesError = 'something went wrong!');
      });
    else _backToNewInvoice();
  }

  void _backToNewInvoice() {
    AppController.closeUntilPath('/new-invoice');
  }

  void _toggleUrlStyle() {
    useUrlStyle = !useUrlStyle;
    _rebuild();
  }

  void _chooseCurrency() {
    choosingCurrency = true;
    _rebuild();
  }

  void _shareUri() async {
    await Share.share(uri,
      sharePositionOrigin: sharePlacement.getRect()
    );
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
    if (invoice == null || (invoice.isUnpaid() && !invoice.isExpired()))
      Client.getInvoice(id).then((response) {
        _errorMessage = null;
        if (response['success'])
          invoice = response['invoice'];
        else _errorMessage = response['message'];

        // Checking if disposed to prevent memory leaks
        if (!_disposed) _rebuild();
      });
  }

  @override
  void initState() {
    super.initState();
    qrColor = AppController.randomColor;
    _fetchInvoice();
    periodicRequest = Timer.periodic(Duration(seconds: 2), (timer) => _fetchInvoice());
    event = Events.on('invoice.paid', (payload) {
      invoice = Invoice.fromMap(payload);
      _rebuild();
    });
  }

  Widget _ChooseCurrencyMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 235,
          child: GestureDetector(
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
            width: 235,
            child: GestureDetector(
              child: _PaymentTitle(option['currency']),
              onTap: () {
                currency = option['currency'];
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
          _BackButton(),
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
                    image: AssetImage('assets/images/copy_icon.png'),
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
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            width: 150,
            image: AssetImage('assets/images/anypay-logo.png')
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
                fontSize: 48,
              ),
            ),
          ),
          Container(
            child: Text(Authentication.currentAccount.businessName ?? "",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(invoice.amountWithDenomination(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
                fontSize: 28,
              ),
            ),
          ),
          Container(
            child: Text(invoice.inCurrency(),
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            width: 300,
            child: TextFormField(
              controller: notes,
              validator: (value) {
                if (notesError.length > 0)
                  return notesError;
              },
              decoration: InputDecoration(
                labelText: 'Add note...'
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 35),
            child: GestureDetector(
              onTap: _done,
              child: Image(
                image: AssetImage('assets/images/next_arrow.png'),
                width: 50,
              )
            ),
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
        GestureDetector(
          onTap: _done,
          child: Image(
            image: AssetImage('assets/images/next_arrow.png'),
            width: 60,
          )
        ),
      ],
    );
  }

  Widget _PaymentTitle(currency) {
    if (currency == 'anypay')
      return Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: [
            Container(
              width: 60,
              child: Image(
                image: AssetImage('assets/images/anypay-logo.png')
              ),
            ),
            Text('Anypay',
              style: TextStyle(fontSize: 35),
            ),
          ]
        )
      );
    else if (Coins.supported[currency] != null)
      return Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: [
            Container(
              width: 40,
              margin: EdgeInsets.all(10.0),
              child: Image.network(
                Coins.supported[currency]['icon']
              ),
            ),
            Text(currency,
              style: TextStyle(fontSize: 40),
            ),
          ]
        )
      );
    else return Container();
  }

  Widget _InvoiceComponent() {
    if (invoice == null)
      if (_errorMessage != null)
        return Text(_errorMessage, style: TextStyle(color: AppController.red));
      else return Container(
          child: SpinKitCircle(color: qrColor),
          height: 360,
        );
    else if (invoice.isUnderpaid())
      return _UnderpaidScreen();
    else if (invoice.isPaid())
      return _PaidScreen();
    else if (choosingCurrency)
      return _ChooseCurrencyMenu();
    else if (invoice.isExpired())
      return _ExpiredInvoice();
    else return AnimatedOpacity(
      opacity: _invoiceReady ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_successMessage,
            style: TextStyle(color: AppController.green),
          ),
          Container(
            width: 235,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PaymentTitle(usePayProtocol ? 'anypay' : currency),
                Container(
                  width: 40,
                  margin: EdgeInsets.only(top: 5.0, bottom: 20.0),
                  child: GestureDetector(
                    onTap: _chooseCurrency,
                    child: Icon(
                      Icons.cached,
                      size: 40,
                    ),
                  )
                )
              ]
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 12.0,
                color: qrColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            child: Container(
              color: AppController.white,
              margin: EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: _toggleUrlStyle,
                child: QrImage(
                  foregroundColor: Color(0xFF404040),
                  version: QrVersions.auto,
                  size: 235.0,
                  data: uri,
                ),
              ),
            ),
          ),
          kIsWeb ? _WebShareOptions() :
          (sharePlacement = RectGetter.defaultKey(
            child: Container(
              width: 235,
              margin: EdgeInsets.only(top: 20.0),
              child: GestureDetector(
                onTap: _shareUri,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Share Payment Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Image(
                          image: AppController.enableDarkMode ?
                            AssetImage('assets/images/share-white.png') :
                            AssetImage('assets/images/share.png'),
                        width: 20,
                      )
                    )
                  ]
                )
              )
            )
          ))
        ]
      )
    );
  }

  Widget _BackButton() {
    var onTap;
    if (choosingCurrency)
      onTap = () {
        choosingCurrency = false;
        _rebuild();
      };
    return Visibility(
      visible: invoice == null || !invoice.isExpired() && (invoice.isUnpaid() || invoice.isUnderpaid()),
      child: CircleBackButton(
        margin: EdgeInsets.only(top: 20.0),
        backPath: '/new-invoice',
        opaque: false,
        onTap: onTap,
      )
    );
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeKeyboard,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _InvoiceComponent(),
                _BackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


