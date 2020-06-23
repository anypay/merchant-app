import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';

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


  @override
  void initState() {
    // displayInfo();
    super.initState();
    _fetchPayment();
    Client.fetchPayment(id).then((response) {
      setState(() {
        if (response['success'])
          _payment = response['payment'];
        else _errorMessage = response['message'];
      });
    });
  }

  Widget _TitleBar() {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 10.0),
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Payment', style: TextStyle(
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
            backPath: '/payments',
          )
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Text(_payment.amountWithDenomination(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF707070),
                    fontSize: 28,
                  ),
                ),
              ),
              Container( 
                margin: EdgeInsets.only(bottom: 20),
                child: Text(_payment.inCurrency(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF707070),
                    fontSize: 28,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () async {
                    var hash = invoice.hash;
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
            ],
          ),
        ),
      ),
    );
  }
}





