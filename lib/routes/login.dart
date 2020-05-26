import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  static const String route = '/login';
  @override
  Widget build(BuildContext context) {
    return LoginPage(title: 'Login');
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            Image(
              width: 300,
              image: AssetImage('images/anypay-full-logo.png')
            ),

            Container(
              width: 300,
              margin: const EdgeInsets.only(top: 40.0),
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
                  ],
                ),
              )
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                    },
                    child: Text('Login'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registration');
                    },
                    child: Text('Sign Up'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/quick-start');
                    },
                    child: Text('Quick Start'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/password-reset');
                    },
                    child: Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
