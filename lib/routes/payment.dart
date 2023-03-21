import 'package:url_launcher/url_launcher.dart'
  if (dart.library.html) 'package:app/web_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
import 'package:app/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import "package:intl/intl.dart";
import "package:app/coins.dart";

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
  String _errorMessage = '';
  Invoice _payment;
  String _notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        child: Align(
          alignment: Alignment(-0.83, -1),
          child: CircleBackButton(
            margin: EdgeInsets.only(right: 20.0, top: 35 + AppController.topPadding()),
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

  @override
  void initState() {
    super.initState();
    Client.getInvoice(id).then((response) {
      setState(() {
        if (response['success']) {
          _payment = response['invoice'];
          _notes = _payment.orderNotes();
        } else _errorMessage = response['message'];
      });
    });
  }

  Widget _Payment() {
    if (_payment == null)
      return SpinKitCircle(color: AppController.blue);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_errorMessage, style: TextStyle(color: AppController.red)),
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Text(_payment.amountWithDenomination() ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
              fontSize: 44,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text((Coins.all[_payment.currency] ?? {})['name'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
              fontSize: 28,
            ),
          ),
        ),
        // TODO https://github.com/anypay/merchant-app/issues/21
        // Container(
        //   margin: EdgeInsets.only(bottom: 40),
        //   child: Text(_payment.inCurrency() ?? "",
        //     style: TextStyle(
        //       fontWeight: FontWeight.bold,
        //       color: Theme.of(context).primaryColorDark,
        //       fontSize: 28,
        //     ),
        //   ),
        // ),
        Container(
          child: Text(_payment.completedAtTimeAgo(),
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 40),
          child: Text(
            _payment.formatCompletedAt(),
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 20,
            ),
          ),
        ),
        Visibility(
          visible: _notes.length > 0,
          child: Container(
            margin: EdgeInsets.only(right: 10),
            child: Text(_notes,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Visibility(
          visible: _payment.getBlockchainUrl() != null,
          child: Container(
            child: GestureDetector(
              onTap: () async {
                await launch(_payment.getBlockchainUrl());
              },
              child: Text('View on blockchain',
                style: TextStyle(
                  color: AppController.blue,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

