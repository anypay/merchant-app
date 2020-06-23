import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app/authentication.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/back_button.dart';
import 'package:share/share.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';

import 'dart:async';



class Invoice extends StatelessWidget {
  Invoice(this.id);

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
  bool choosingCurrency = false;
  bool usePayProtocol = true;
  var _successMessage = '';
  Timer periodicRequest;
  String notesError;
  String currency;
  String uri;
  Color qrColor;
  String id;

  var invoice;
  var notes = TextEditingController();

  @override
  void dispose() {
    periodicRequest.cancel();
    notes.dispose();
    super.dispose();
  }

  List<Color> colors = ([
    0xFF8c5ca6,
    0xFF0177c0,
    0xFF1a8e5a,
    0xFFcfa015,
    0xFFc74a43,
  ]..shuffle()).map((hex) => Color(hex)).toList();


  void _done() {
    setState(() { notesError = ""; });

    if (notes.text.length > 0)
      Client.setInvoiceNotes(invoice.uid, notes.text).then((response) {
        if (response['success'])
          _backToNewInvoice();
        else setState(() => notesError = 'something went wrong!');
      });
    else _backToNewInvoice();
  }

  void _backToNewInvoice() {
    Navigator.pushNamedAndRemoveUntil(context, '/new-invoice', (Route<dynamic> route) => false);
  }

  void _togglePayUri() {
    usePayProtocol = !usePayProtocol;
    _rebuild();
  }

  void _chooseCurrency() {
    choosingCurrency = true;
    _rebuild();
  }

  void _copyUri() {
    Clipboard.setData(ClipboardData(text: uri));
    setState(() => _successMessage = "Coppied!" ); 
    Timer(Duration(seconds: 2), () {
      setState(() => _successMessage = "" ); 
    });
  }

  void _shareUri() async {
    await Share.share(uri);
  }

  void _rebuild() {
    setState(() {
      currency = currency ?? invoice.currency;
      uri = invoice.uriFor(currency, protocol: usePayProtocol ? 'pay' : null);
    });
  }

  void _fetchInvoice() {
    if (invoice == null || invoice.isUnpaid())
      Client.getInvoice(id).then((response) {
        invoice = response['invoice'];
        _rebuild();
      });
  }

  @override
  void initState() {
    super.initState();
    qrColor = colors.first;
    periodicRequest = Timer.periodic(Duration(seconds: 2), (timer) => _fetchInvoice());
  }

  Widget _ChooseCurrencyMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ...(invoice.paymentOptions.map((option) {
          return Container(
            width: 235,
            margin: EdgeInsets.only(bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                currency = option['currency'];
                choosingCurrency = false;
                _rebuild();
              },
              child: Row(
                children: [
                  Container(
                    width: 40,
                    margin: EdgeInsets.all(10.0),
                    child: Image.network(
                      Coins.all[option['currency']]['icon']
                    ),
                  ),
                  Text(
                    option['currency'],
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  )
                ]
              )
            )
          );
        }))
      ]
    );
  }

  Widget _PaidScreen() {
    return Column(
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
          colors: colors,
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
              color: Color(0xFF707070),
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Text(invoice.amountWithDenomination(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF707070),
              fontSize: 28,
            ),
          ),
        ),
        Container(
          child: Text(invoice.inCurrency(),
            style: TextStyle(
              color: Color(0xFF707070),
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
              color: Color(0xFF404040),
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

  Widget _InvoiceComponent() {
    if (invoice == null)
      return Container(
        child: SpinKitCircle(color: qrColor),
        height: 360,
      );
    else if (invoice.isPaid())
      return _PaidScreen();
    else if (choosingCurrency)
      return _ChooseCurrencyMenu();
    else if (invoice.isExpired())
      return _ExpiredInvoice();
    else return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_successMessage,
          style: TextStyle(color: Colors.green),
        ),
        Container(
          width: 235,
          margin: EdgeInsets.only(bottom: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    margin: EdgeInsets.all(10.0),
                    child: Image.network(
                      Coins.all[currency]['icon']
                    ),
                  ),
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ]
              ),
              Container(
                width: 40,
                margin: EdgeInsets.all(10.0),
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
        GestureDetector(
          onTap: _togglePayUri,
          child: QrImage(
            foregroundColor: qrColor,
            version: QrVersions.auto,
            size: 235.0,
            data: uri,
          ),
        ),
        Container(
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
                        image: AssetImage('assets/images/copy_icon.png'),
                        width: 20,
                      )
                    )
                  ]
                )
              ),
              GestureDetector(
                onTap: _shareUri,
                child: Row(
                  children: <Widget>[
                    Text('Share', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    )),
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Image(
                        image: AssetImage('assets/images/share.png'),
                        width: 20,
                      )
                    )
                  ]
                )
              )
            ]
          )
        )
      ]
    );
  }

  Widget _BackButton() {
    var onTap;
    if (choosingCurrency)
      onTap = () {
        choosingCurrency = false;
        _rebuild();
      };
    return CircleBackButton(
      margin: EdgeInsets.only(top: 20.0),
      backPath: '/new-invoice',
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _InvoiceComponent(),
            _BackButton(),
          ],
        ),
      ),
    );
  }
}


