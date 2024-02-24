import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/app_controller.dart';
import 'package:app/currencies.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../client.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsPage(title: 'Settings');
  }
}

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key, required this.title}) : super(key: key);

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
  bool? isUserLoggedIn;
  @override
  void initState() {
    _rebuild();
    super.initState();
    setBackendUrl();
    isUserLoggedIn = Authentication.currentAccount.email != null;
    if (isUserLoggedIn == true) {
      Authentication.getAccount().then((account) {
        _rebuild();
      });
    }
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
              Text(_successMessage,
                style: TextStyle(color: AppController.green),
              ),
              Container(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _EditUrlLink(),
                    if (isUserLoggedIn == true) _SelectCurrencyLink(context),
                    if (isUserLoggedIn == true) _BusinessInfoLink(context),
                    if (isUserLoggedIn == true) _AddressesLink(context),
                    CircleBackButton(
                      margin: EdgeInsets.only(top: 20.0),
                      backPath: 'navigation',
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _EditUrlLink() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(AppController.scale(20.0)),
                  child: Text("Edit backend URL",
                      style: TextStyle(
                        fontSize: 22,
                      ))),
              Icon(Icons.edit),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, 'settings/edit_url');
          }),
    );
  }

  void _rebuild() {
    setState(() {
      if (Authentication.currentAccount.denomination != null) {
        denomination = Authentication.currentAccount.denomination;
        symbol = Currencies.all[denomination]!['symbol'];
      } else {
        denomination = 'USD';
        symbol = '\$';
      }
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
              child: Text("Addresses", style: TextStyle(
                fontSize: 22,
              ))
            ),
            Icon(Icons.edit),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, 'settings/addresses').then((value) {
            _successMessage = '';
            _rebuild();
          });
        }
      ),
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
                  Text("Currency ", style: TextStyle(
                    fontSize: 22,
                  )),
                  Text("($symbol$denomination)", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  )),
                ],
              )
            ),
            Icon(Icons.edit),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, 'settings/currency').then((value) {
            _successMessage = 'Saved!';
            _rebuild();
          });
        }
      ),
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
              child: Text("Business Info", style: TextStyle(
                fontSize: 22,
              )),
            ),
            Icon(Icons.edit),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, 'settings/business-info');
        }
      ),
    );
  }

}
