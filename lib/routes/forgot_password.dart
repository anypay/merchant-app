import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  static const String route = '/password-reset';
  @override
  Widget build(BuildContext context) {
    return ForgotPasswordPage(title: 'Forgot Password');
  }
}

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'please enter some text';
                      },
                    ),
                    RaisedButton(
                      onPressed: () {
                      },
                      child: Text('SEND EMAIL'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: Text('BACK'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

