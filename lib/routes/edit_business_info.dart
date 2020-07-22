import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';

class EditBusinessInfo extends StatelessWidget {
  EditBusinessInfo({this.allowBack = true});

  final bool allowBack;

  @override
  Widget build(BuildContext context) {
    return EditBusinessInfoPage(allowBack: allowBack);
  }
}

class EditBusinessInfoPage extends StatefulWidget {
  EditBusinessInfoPage({Key key, this.allowBack}) : super(key: key);

  final bool allowBack;

  @override
  _EditBusinessInfoPageState createState() => _EditBusinessInfoPageState(allowBack);
}

class _EditBusinessInfoPageState extends State<EditBusinessInfoPage> {
  _EditBusinessInfoPageState(this.allowBack);
  final allowBack;

  final _formKey = GlobalKey<FormState>();
  final address = TextEditingController();
  final email = TextEditingController();
  final name = TextEditingController();

  bool _submitting = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeKeyboard,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  child: _Form(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    address.dispose();
    email.dispose();
    name.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {
      address.text = Authentication.currentAccount.physicalAddress;
      email.text = Authentication.currentAccount.ambassadorEmail;
      name.text = Authentication.currentAccount.businessName;
    });
  }

  @override
  void initState() {
    _rebuild();
    super.initState();
    Authentication.getAccount().then((account) {
      _rebuild();
    });
  }

  void _submitForm() {
    setState(() {
      _submitting = true;
      _errorMessage = "";
      _successMessage = "";
    });
    _closeKeyboard();
    if (_formKey.currentState.validate()) {
      Authentication.updateAccount({
        'ambassador_email': email.text.toLowerCase(),
        'physical_address': address.text,
        'business_name': name.text,
      }).then((response) {
        setState(() {
          _submitting = false;
          if (!allowBack)
            Navigator.pushNamedAndRemoveUntil(context, '/settings/addresses', (Route<dynamic> route) => false);
          else if (response['success'])
            _successMessage = "Saved!";
          else _errorMessage = response['message'];
        });
      });
    }
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }

  Widget _Form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(_successMessage,
            style: TextStyle(color: AppController.green),
          ),
          Text(_errorMessage,
            style: TextStyle(color: AppController.red),
          ),
          TextFormField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Business Name (Optional)'
            ),
          ),
          TextFormField(
            controller: address,
            decoration: InputDecoration(
              labelText: 'Business Street Address (Optional)'
            ),
          ),
          TextFormField(
            controller: email,
            decoration: InputDecoration(
              labelText: 'Ambassador Email (Optional)'
            ),
            validator: (value) {
              if (!value.isEmpty && !EmailValidator.validate(value.trim()))
                return "That doesn't look like an email address";
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            child: _submitting ? SpinKitCircle(color: AppController.randomColor) : GestureDetector(
              child: Text(allowBack ? 'SAVE' : 'Finish', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppController.blue,
                fontSize: 18,
              )),
              onTap: _submitForm,
            ),
          ),
          !allowBack ? Container() : CircleBackButton(
            margin: EdgeInsets.only(top: 20.0),
            backPath: '/settings',
          )
        ],
      ),
    );
  }
}


