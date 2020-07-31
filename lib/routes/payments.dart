import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";

class Payments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaymentsPage();
  }
}

class PaymentsPage extends StatefulWidget {
  PaymentsPage({Key key}) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool _awaitingResponse = true;
  bool _showMore = false;
  var allInvoices = [];
  String _errorMessage;
  num page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        child: Align(
          alignment: Alignment(-0.83, -1),
          child: SafeArea(
            child: CircleBackButton(
              margin: EdgeInsets.only(right: 20.0, top: 35 + AppController.topPadding()),
              backPath: '/navigation',
            )
          )
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _TitleBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _InvoiceList()
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getNextPage() {
    page += 1;
    Client.getInvoices(page: page).then((response) {
      setState(() {
        _awaitingResponse = false;
        if (response['success']) {
          _showMore = response['invoices'].length > 0;
          allInvoices = [
            ...allInvoices,
            ...(response['invoices']),
          ];
        } else _errorMessage = response['message'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getNextPage();
  }

  void openPayment(id) {
    Navigator.pushNamed(context, '/payments/$id');
  }

  List<Widget> _InvoiceList() {
    if (_errorMessage != null)
      return [Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: AppController.red))];
    else if (allInvoices.length == 0)
      return [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: _awaitingResponse ?
            SpinKitCircle(color: AppController.blue) :
            Text("No payments yet!", textAlign: TextAlign.center),
        )
      ];
    else return [
      ...allInvoices.map((invoice) {
        return _Invoice(invoice);
      }),
      _MoreButton(),
    ];
  }

  Widget _Invoice(invoice) {
    var amount = invoice.amountWithDenomination();
    var currency = invoice.currency;
    amount = "$amount $currency";
    return GestureDetector(
      onTap: () => openPayment(invoice.uid),
      child: Container(
        width: 400,
        padding: EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 1.0)),
        ),
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 28,
                ),
              ),
              Visibility(
                visible: invoice.orderNotes().length > 0,
                child: Text(invoice.orderNotes(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 28,
                  ),
                ),
              ),
              Text(invoice.formatCompletedAt(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 20,
                ),
              ),
              Text(invoice.completedAtTimeAgo(),
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _MoreButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.0)),
      ),
      margin: EdgeInsets.only(bottom: 40),
      padding: EdgeInsets.only(top: 20),
      child: Visibility(
        visible: _showMore,
        child: GestureDetector(
          onTap: _getNextPage,
          child: Text('More',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppController.blue,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _TitleBar() {
    return Container(
      margin: EdgeInsets.only(top: 10 + AppController.topPadding(), bottom: 10.0),
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Payments', style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
          )),
        ],
      )
    );
  }
}




