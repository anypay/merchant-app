import 'package:email_validator/email_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:app/app_controller.dart';
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

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
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
                  image: AssetImage(AppController.logoImagePath()),
                ),
                _buildTextFields(),
                _buildLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
        _errorMessage = "";
      });
      Client.authenticate(emailController.text, passwordController.text)
          .then((response) {
        setState(() {
          _submitting = false;
          if (response['success']) {
            AppController.closeUntilPath('/new-invoice');
          } else {
            _errorMessage = response['message'];
          }
        });
      });
    }
  }

  void setDefaultUrl() async {
    final storedUrl = await FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ).read(key: "backend_url");

    if (storedUrl != null) {
      Uri url = Uri.parse(storedUrl);
      Client.protocol = url.scheme;
      Client.host = url.host;
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Widget _buildTextFields() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 40.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              _errorMessage,
              style: TextStyle(color: AppController.red),
            ),
            TextFormField(
              autofillHints: [AutofillHints.username],
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                } else if (!EmailValidator.validate(value.trim())) {
                  return "That doesn't look like an email address";
                }
                return null;
              },
              onFieldSubmitted: (value) {
                _submitForm();
              },
            ),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
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

  Widget _buildLinks(context) {
    return Container(
      margin: EdgeInsets.only(top: _submitting ? 10.0 : 20.0),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: _submitting ? 20.0 : 40.0),
            child: _submitting
                ? SpinKitCircle(color: AppController.blue)
                : GestureDetector(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppController.blue,
                        fontSize: 18,
                      ),
                    ),
                    onTap: _submitForm,
                  ),
          ),
          Container(
            child: GestureDetector(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppController.blue,
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/registration');
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppController.blue,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/password-reset');
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
