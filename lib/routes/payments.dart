import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';

class Payments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaymentsPage(title: 'Payments');
  }
}

class PaymentsPage extends StatefulWidget {
  PaymentsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  var page = 0;
  var payments = [];

  void getNextPage() {
  }

  @override
  void initState() {
    // displayInfo();
    super.initState();
    // Authentication.getPayments().then((payments) {
    //   allPayments = [
    //     ...allPayments,
    //     ...payments,
    //   ];
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (Navigator.canPop(context))
                          Navigator.pop(context, true);
                        else
                          Navigator.pushNamedAndRemoveUntil(context, '/settings', (Route<dynamic> route) => false);
                      },
                      child: Text('BACK'),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}




