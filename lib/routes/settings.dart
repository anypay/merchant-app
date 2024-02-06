import 'package:app/authentication.dart';
import 'package:app/client.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/app_controller.dart';
import 'package:app/currencies.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsPage(title: 'Settings');
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _successMessage = '';
  var denomination;
  var symbol;
  var urlController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _rebuild();
    super.initState();
    setBackendUrl();
    Authentication.getAccount().then((account) {
      _rebuild();
    });
  }

  void setBackendUrl() {
    urlController.text = Client.host;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _successMessage,
                style: TextStyle(color: AppController.green),
              ),
              Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _EditUrlLink(),
                      _SelectCurrencyLink(context),
                      _BusinessInfoLink(context),
                      _AddressesLink(context),
                      CircleBackButton(
                        margin: EdgeInsets.only(top: 20.0),
                        backPath: '/navigation',
                      )

                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _EditUrlLink() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                    labelText: 'Update Backend Url',
                    hintText: "http:// or https://"),
                validator: (value) {
                  if (Uri.parse(value).isAbsolute) {
                    return null;
                  } else {
                    return "Please provide valid url";
                  }
                }),
          ),
          TextButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (await confirm(context,
                      title: Text("Confirmation"),
                      content: Text(
                          "You will be logged out because you changed the API backend url"))) {
                    final uri = Uri.parse(urlController.text);
                    await FlutterSecureStorage(
                        aOptions: AndroidOptions(
                      encryptedSharedPreferences: true,
                    )).write(key: "backend_url", value: urlController.text);
                    Client.protocol = uri.scheme;
                    Client.domain = uri.host;
                    Authentication.logout();
                  }
                }
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  void _rebuild() {
    setState(() {
      denomination = Authentication.currentAccount.denomination ?? 'USD';
      symbol = Currencies.all[denomination]['symbol'];
    });
  }

  Widget _AddressesLink(context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(AppController.scale(20.0)),
                  child: Text("Addresses",
                      style: TextStyle(
                        fontSize: 22,
                      ))),
              Icon(Icons.edit),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/settings/addresses').then((value) {
              _successMessage = '';
              _rebuild();
            });
          }),
    );
  }
  Widget _SelectCurrencyLink(context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(AppController.scale(20.0)),
                  child: Row(
                    children: <Widget>[
                      Text("Currency ",
                          style: TextStyle(
                            fontSize: 22,
                          )),
                      Text("($symbol$denomination)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          )),
                    ],
                  )),
              Icon(Icons.edit),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/settings/currency').then((value) {
              _successMessage = 'Saved!';
              _rebuild();
            });
          }),
    );
  }

  Widget _BusinessInfoLink(context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(AppController.scale(20.0)),
                child: Text("Business Info",
                    style: TextStyle(
                      fontSize: 22,
                    )),
              ),
              Icon(Icons.edit),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/settings/business-info');
          }),
    );
  }
}
