import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';

class CreateAccount extends StatelessWidget {
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
  var _errorMessage = '';

  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void _loadNextPage() {
    Client.authenticate(email.text, password.text).then((response) {
      if (response['success'])
        Navigator.pushNamedAndRemoveUntil(context, '/register-business', (Route<dynamic> route) => false);
      else
        setState(() { _errorMessage = response['message']; });
    });
  }

  void _submitForm() {
    setState(() { _errorMessage = ""; });
    if (_formKey.currentState.validate()) {
      Client.createAccount(email.text, password.text).then((response) {
        if (response['success'])
          _loadNextPage();
        else
          setState(() { _errorMessage = response['message']; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              width: 300,
              image: AssetImage('assets/images/anypay-full-logo.png')
            ),
            Container(
              width: 300,
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
                        labelText: 'Password'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter some text';
                        else if (confirmPassword.text != value)
                          return 'Passwords do not match.';
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: confirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Re-type Password'
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter some text';
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: GestureDetector(
                child: Text('Register', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18,
                )),
                onTap: _submitForm,
              ),
            ),
            CircleBackButton(
              margin: EdgeInsets.only(top: 20.0),
              backPath: '/login',
            ),
          ],
        ),
      ),
    );
  }
}

