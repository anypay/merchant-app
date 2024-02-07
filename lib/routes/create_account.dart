import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/app_controller.dart';
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

  String _errorMessage = '';
  bool _submitting = false;

  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

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
                Image(
                  width: 300,
                  image: AssetImage(AppController.logoImagePath())
                ),
                _textFields(),
                Container(
                  margin: (_submitting ? 
                    EdgeInsets.only(top: 5, bottom: 10) :
                    EdgeInsets.only(top: 20, bottom: 20)),
                  child: _submitting ? SpinKitCircle(color: AppController.blue) :
                    GestureDetector(
                      child: Text('Register', style: TextStyle(
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
        ),
      ),
    );
  }

  void _loadNextPage() {
    Client.authenticate(email.text, password.text).then((response) {
      if (response['success'])
        AppController.closeUntilPath('/register-business');
      else
        setState(() { _errorMessage = response['message']; });
    });
  }

  void _submitForm() {
    _closeKeyboard();
    if (_formKey.currentState.validate()) {
      setState(() {
        _errorMessage = "";
        _submitting = true;
      });
      Client.createAccount(email.text, password.text).then((response) {
        _submitting = false;
        if (response['success'])
          _loadNextPage();
        else
          setState(() { _errorMessage = response['message']; });
      });
    }
  }

  @override
  void dispose() {
    confirmPassword.dispose();
    password.dispose();
    email.dispose();
    super.dispose();
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }

  Widget _textFields() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(_errorMessage,
              style: TextStyle(color: AppController.red),
              textAlign: TextAlign.center,
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
              onFieldSubmitted: (value) {
                _submitForm();
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
              onFieldSubmitted: (value) {
                _submitForm();
              },
            ),
          ],
        ),
      ),
    );
  }
}

