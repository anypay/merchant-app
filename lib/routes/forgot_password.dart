import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';

class ForgotPassword extends StatelessWidget {
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

  var _successMessage = '';
  var _submitting = false;
  var _errorMessage = '';

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void _submitForm() {
    _closeKeyboard();
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
        _errorMessage = "";
        _successMessage = "";
      });
      Client.resetPassword(email.text).then((response) {
        setState(() {
          _submitting = false;
          if (response['success'])
            _successMessage = "Email sent!";
          else {
            _errorMessage = response['message'];
          }
        });
      });
    }
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeKeyboard,
      child: Scaffold(
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
                          style: TextStyle(color: AppController.green),
                        ),
                        Text(_errorMessage,
                          style: TextStyle(color: AppController.red),
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
                          onFieldSubmitted: (value) {
                            _submitForm();
                          },
                        ),
                        Container(
                          margin: (_submitting ? 
                            EdgeInsets.only(top: 10, bottom: 5) :
                            EdgeInsets.only(top: 20, bottom: 20)),
                          child: _submitting ? SpinKitCircle(color: AppController.blue) :
                            GestureDetector(
                              child: Text('SEND EMAIL', style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppController.blue,
                                fontSize: 18,
                              )),
                              onTap: _submitForm,
                            ),
                        ),
                        CircleBackButton(
                          backPath: '/login',
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

