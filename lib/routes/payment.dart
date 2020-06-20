import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";
import "package:app/coins.dart";

import 'package:timeago/timeago.dart' as timeago;

class Payment extends StatelessWidget {
  Payment(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return PaymentPage(id: id);
  }
}

class PaymentPage extends StatefulWidget {
  PaymentPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _PaymentPageState createState() => _PaymentPageState(id);
}

class _PaymentPageState extends State<PaymentPage> {
  _PaymentPageState(this.id);

  final String id;
  var _errorMessage = '';
  var _payment;
  var _notes;

  @override
  void initState() {
    super.initState();
    Client.getInvoice(id).then((response) {
      setState(() {
        if (response['success']) {
          _payment = response['invoice'];
          _notes = _payment.notes?.join(", ");
        } else _errorMessage = response['message'];
      });
    });
  }

  Widget _Payment() {
    if (_payment == null)
      return SpinKitCircle(color: Colors.blue);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_errorMessage, style: TextStyle(color: Colors.red)),
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Text(_payment.amountWithDenomination() ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF404040),
              fontSize: 44,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(Coins.all[_payment.currency]['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF707070),
              fontSize: 28,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Text(_payment.inCurrency() ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF707070),
              fontSize: 28,
            ),
          ),
        ),
        Container(
          child: Text(timeago.format(_payment.completedAt),
            style: TextStyle(
              color: Color(0xFF707070),
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Text(
            DateFormat('E, MMMM d, h:m').format(_payment.completedAt),
            style: TextStyle(
              color: Color(0xFF707070),
              fontSize: 20,
            ),
          ),
        ),
        Container(
          child: GestureDetector(
            onTap: () async {
              var hash = _payment.hash;
              await launch("https://whatsonchain.com/tx/$hash");
            },
            child: Text('View on blockchain',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Visibility(
          visible: _notes != null,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            child: Text("Order notes: $_notes",
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
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
            backPath: '/payments',
          )
        )
      ),
      body: Center(
        child: SingleChildScrollView(
          child: _Payment(),
        ),
      ),
    );
  }
}





