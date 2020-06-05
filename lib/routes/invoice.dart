import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/client.dart';
import '../coins.dart';

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
  bool usePayProtocol = true;
  String currency;
  String uri;

  Color qrColor = Color(([
    0xFF8c5ca6,
    0xFF0177c0,
    0xFF1a8e5a,
    0xFFcfa015,
    0xFFc74a43,
  ]..shuffle()).first);

  final String id;
  var invoice;

  void _togglePayUri() {
    usePayProtocol = !usePayProtocol;
    _rebuild();
  }

  void _chooseCurrency() {
    currency = null;
  }

  void _copyUri() {
    Clipboard.setData(new ClipboardData(text: uri));
  }

  void _openUri() async {
    await launch(uri);
  }

  void _rebuild() {
    setState(() {
      currency = currency ?? invoice.currency;
      uri = invoice.uriFor(currency, protocol: usePayProtocol ?? 'pay');
    });
  }

  @override
  void initState() {
    super.initState();
    Client.getInvoice(id).then((response) {
      invoice = response['invoice'];
      _rebuild();
    });
  }

  Widget _ChooseCurrencyMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: invoice.paymentOptions.map((option) {
        return Container(
          width: 235,
          margin: EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Container(
                width: 40,
                margin: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: Image.network(
                  Coins.all[currency]['icon']
                ),
              ),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 40,
                ),
              )
            ]
          )
        );
      })
    );
  }

  Widget _InvoiceComponent() {
    if (currency == null)

    else if (invoice.isExpired())
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
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/new-invoice', (Route<dynamic> route) => false);
            },
            child: Image(
              image: AssetImage('images/next_arrow.png'),
              width: 60,
            )
          ),
        ],
      );
    else return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 235,
          margin: EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Container(
                width: 40,
                margin: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                child: Image.network(
                  Coins.all[currency]['icon']
                ),
              ),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 40,
                ),
              )
              GestureDetector(
                onTap: _chooseCurrency,
                child: Icon(Icons.cached),
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
                        image: AssetImage('images/copy_icon.png'),
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
                        image: AssetImage('images/wallet_icon.png'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            invoice == null ? Container() : _InvoiceComponent(),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                onPressed: () {
                  if (Navigator.canPop(context))
                    Navigator.pop(context, true);
                  else
                    Navigator.pushNamedAndRemoveUntil(context, '/new-invoice', (Route<dynamic> route) => false);
                },
                child: Text('BACK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


