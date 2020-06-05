import 'package:email_validator/email_validator.dart';
import 'package:app/authentication.dart';
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

  var _errorMessage = '';
  var _successMessage = '';

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
      _errorMessage = "";
      _successMessage = "";
    });
    if (_formKey.currentState.validate()) {
      Authentication.updateAccount({
        'ambassador_email': email.text.toLowerCase(),
        'physical_address': address.text,
        'business_name': name.text,
      }).then((response) {
        setState(() {
          if (!allowBack)
            Navigator.pushNamedAndRemoveUntil(context, '/settings/addresses', (Route<dynamic> route) => false);
          else if (response['success'])
            _successMessage = "Saved!";
          else _errorMessage = response['message'];
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Text(_successMessage,
                        style: TextStyle(color: Colors.green),
                      ),
                      Text(_errorMessage,
                        style: TextStyle(color: Colors.red),
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
                        child: GestureDetector(
                          child: Text(allowBack ? 'SAVE' : 'Finish', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          )),
                          onTap: _submitForm,
                        ),
                      ),
                      !allowBack ? null : CircleBackButton(
                        margin: EdgeInsets.only(top: 20.0),
                        backPath: '/settings',
                      )
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


