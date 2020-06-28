import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/app_builder.dart';
import 'package:app/client.dart';

import 'package:timeago/timeago.dart' as timeago;

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
  var _showMore = false;
  var allInvoices = [];
  var _errorMessage;
  var page = 0;

  _getNextPage() {
    page += 1;
    Client.getInvoices(page: page).then((response) {
      setState(() {
        if (response['success']) {
          _showMore = response['invoices'].length > 0;
          allInvoices = [
            ...allInvoices,
            ...response['invoices']..removeWhere((invoice) => !invoice.complete),
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
      return [Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: AppBuilder.red))];
    else if (allInvoices.length == 0)
      return [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: SpinKitCircle(color: AppBuilder.blue),
        )
      ];
    else return [
      ...allInvoices.map((invoice) {
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
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: <Widget>[
                  Text(amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 28,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(timeago.format(invoice.completedAt),
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      _MoreButton(),
    ];
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
              color: AppBuilder.blue,
              fontSize: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _TitleBar() {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 10.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        child: Align(
          alignment: Alignment(-0.85, -1),
          child: CircleBackButton(
            margin: EdgeInsets.only(right: 20.0, top: 65),
            backPath: '/navigation',
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
}




