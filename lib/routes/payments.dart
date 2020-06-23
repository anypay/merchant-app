import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
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
  var page = 0;
  var allInvoices = [];

  _getNextPage() {
    page += 1;
    Client.getInvoices(page: page).then((response) {
      setState(() {
        allInvoices = [
          ...allInvoices,
          ...response['invoices']..removeWhere((invoice) => !invoice.complete),
        ];
      });
    });
  }

  @override
  void initState() {
    // displayInfo();
    super.initState();
    _getNextPage();
  }

  List<Widget> _InvoiceList() {
    if (allInvoices.length == 0)
      return [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: SpinKitCircle(color: Colors.blue),
        )
      ];
    else return allInvoices.map((invoice) {
      return Container(
        width: 400,
        padding: EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0),
          ),
        ),
        child:Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            children: <Widget>[
              Text(invoice.amountWithDenomination(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF707070),
                  fontSize: 28,
                ),
              ),
              Container( 
                margin: EdgeInsets.only(bottom: 20),
                child: Text(invoice.inCurrency(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF707070),
                    fontSize: 28,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(timeago.format(invoice.completedAt),
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ]
              )
            ],
          ),
        ),
      );
    }).toList();
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
          alignment: Alignment(-0.85, -0.85),
          child: CircleBackButton(
            margin: EdgeInsets.only(right: 20.0),
            backPath: '/navigation',
          )
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _TitleBar(),
              ..._InvoiceList(),
              Visibility(
                visible: allInvoices.length > 0,
                child: Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: () {
                      _getNextPage();
                    },
                    child: Text('More',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}




