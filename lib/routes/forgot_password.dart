import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';

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
  final email = TextEditingController();

  var _errorMessage = '';
  var _successMessage = '';

  void _submitForm() {
    setState(() {
      _errorMessage = "";
      _successMessage = "";
    });
    if (_formKey.currentState.validate()) {
      Client.resetPassword(email.text).then((response) {
        setState(() {
          if (response['success'])
            _successMessage = "Email sent!";
          else {
            _errorMessage = response['message'];
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
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
                      Text(_successMessage,
                        style: TextStyle(color: Colors.green),
                      ),
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
                      RaisedButton(
                        onPressed: _submitForm,
                        child: Text('SEND EMAIL'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (Navigator.canPop(context))
                            Navigator.pop(context, true);
                          else
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
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
      ),
    );
  }
}

