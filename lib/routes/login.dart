import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';

class Login extends StatelessWidget {
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
  var _errorMessage = '';

  final email = TextEditingController();
  final password = TextEditingController();

  void _submitForm() {
    setState(() { _errorMessage = ""; });
    if (_formKey.currentState.validate()) {
      Client.authenticate(email.text, password.text).then((response) {
        if (response['success'])
          Navigator.pushNamedAndRemoveUntil(context, '/new-invoice', (Route<dynamic> route) => false);
        else {
          setState(() {
            _errorMessage = response['message'];
          });
        }
      });
    }
  }

  @override
  void dispose() {
    password.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus)
          currentFocus.unfocus();
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image(
                  width: 300,
                  image: AssetImage('assets/images/anypay-full-logo.png')
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: 'Email'
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter some text';
                            else if (!EmailValidator.validate(value.trim()))
                              return "That doesn't look like an email address";
                          },
                        ),
                        TextFormField(
                          obscureText: true,
                          controller: password,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter some text';
                          },
                        ),
                      ],
                    ),
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: GestureDetector(
                          child: Text('Login', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          )),
                          onTap: _submitForm,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40.0),
                        child: GestureDetector(
                          child: Text('Sign Up', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          )),
                          onTap: () {
                            Navigator.pushNamed(context, '/registration');
                          }
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Text('Quick Start', style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 18,
                              )),
                              onTap: () {
                                Navigator.pushNamed(context, '/quick-start');
                              }
                            ),
                            Text(" | "),
                            GestureDetector(
                              child: Text('Forgot Password?', style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 18,
                              )),
                              onTap: () {
                                Navigator.pushNamed(context, '/password-reset');
                              }
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
