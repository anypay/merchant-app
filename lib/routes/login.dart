import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:app/app_builder.dart';
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

  String _errorMessage = '';
  bool _submitting = false;

  final email = TextEditingController();
  final password = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
        _errorMessage = "";
      });
      Client.authenticate(email.text, password.text).then((response) {
        _submitting = false;
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
                  image: AssetImage(AppBuilder.logoImagePath())
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(_errorMessage,
                          style: TextStyle(color: AppBuilder.red),
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
                  margin: EdgeInsets.only(top: _submitting ? 10.0 : 20.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: _submitting ? 20.0 : 40.0),
                        child: _submitting ?
                          SpinKitCircle(color: AppBuilder.blue) :
                          GestureDetector(
                            child: Text('Login', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppBuilder.blue,
                              fontSize: 18,
                            )),
                            onTap: _submitForm,
                          ),
                      ),
                      Container(
                        child: GestureDetector(
                          child: Text('Sign Up', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppBuilder.blue,
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
                              child: Text('Forgot Password?', style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppBuilder.blue,
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
