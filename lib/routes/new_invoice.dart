import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';

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
  double _price = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          margin: EdgeInsets.only(top: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  _price > 0 ? '\$$_visiblePrice' : "",
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ..._generateNumberButtons(),
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    child: GestureDetector(
                      onTap: _backspace,
                      child: Text(_price > 0 ? "⌫" : "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.bold,
                        )
                      )
                    )
                  ),
                  GestureDetector(
                    onTap: _submit,
                    child: Visibility(
                      visible: _price > 0,
                      maintainAnimation: true,
                      maintainState: true,
                      maintainSize: true,
                      child: Image(
                        image: AssetImage('images/next_arrow.png'),
                        width: 60,
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/navigation'),
        child: Icon(Icons.menu),
        tooltip: 'navigation',
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

  List<Widget> _generateNumberButtons() {
    return List<Widget>.generate(11, (i)  {
      int num = (i + 1) % 11;
      return GestureDetector(
        onTap: () { _updatePrice(num); },
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 25),
          width: 100,
          child: Text(
            num == 10 ? '' : num.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              color: Color(0xFF404040),
              fontWeight: FontWeight.bold,
            )
          ),
        )
      );
    });
  }

}

