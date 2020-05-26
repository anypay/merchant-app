import 'package:flutter/material.dart';

class CreateAccount extends StatelessWidget {
  static const String route = '/registration';
  @override
  Widget build(BuildContext context) {
    return CreateAccountPage(title: 'Create Account');
  }
}

class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'please enter some text';
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'please enter some text';
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Re-type Password'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'please enter some text';
                      },
                    ),
                  ],
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

