import 'package:flutter/material.dart';
import '../coins.dart';

class NewAddress extends StatelessWidget {
  NewAddress(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return NewAddressPage(code: code);
  }
}

class NewAddressPage extends StatefulWidget {
  NewAddressPage({Key key, this.code}) : super(key: key);

  final String code;

  @override
  _NewAddressPageState createState() => _NewAddressPageState(code);
}

class _NewAddressPageState extends State<NewAddressPage> {
  _NewAddressPageState(this.code);

  final _formKey = GlobalKey<FormState>();
  final String code;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(Coins.all[code]['name']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'paste $code address'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'please enter some text';
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

