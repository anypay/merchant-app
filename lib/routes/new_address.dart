import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:app/authentication.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:app/app_builder.dart';
import 'package:app/back_button.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';

class NewAddress extends StatelessWidget {
  NewAddress(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return NewAddressPage(code: code);
  }
}

class NewAddressPage extends StatefulWidget {
  NewAddressPage({Key key, this.code}) : super(key: key);

  final String code;

  @override
  _NewAddressPageState createState() => _NewAddressPageState(code);
}

class _NewAddressPageState extends State<NewAddressPage> {
  _NewAddressPageState(this.code);

  final _formKey = GlobalKey<FormState>();
  final String code;

  var _successMessage = '';
  var _paymailAddress = '';
  var _errorMessage = '';
  var _pasting = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    Authentication.fetchCoins().then((v) {
      setState(() {
        _successMessage = Authentication.currentAccount.addressFor(this.code) ?? "";
      });
    });
  }

  void _pasteAddress() async {
    ClipboardData clipboard = await Clipboard.getData('text/plain');
    setState(() { _pasting = true; });
    var address = clipboard.text;
    _setAddress(address);
  }

  void _scanAddress() async {
    var result = await BarcodeScanner.scan();

    if (result.rawContent != null)
      _setAddress(result.rawContent);
  }

  void _setAddress(address) async {
    setState(() {
      _successMessage = '';
      _errorMessage = '';
    });
    Client.setAddress(code, address).then((response) {
      setState(() {
        _pasting = false;
        _saving = false;
        if (response['success']) {
          _successMessage = address;
          _errorMessage = "";
          Authentication.fetchCoins();
        } else _errorMessage = response['message'];
      });
    });
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
                  child: Row(
                    children: [
                      Container(
                        width: 75,
                        margin: EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          bottom: 10.0,
                        ),
                        child: Image.network(
                          Coins.all[code]['icon']
                        ),
                      ),
                      Text(
                        Coins.all[code]['name'],
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      )
                    ]
                  ),
                ),
                Container(
                  width: 320,
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 320,
                        child: Text(_successMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppBuilder.green,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 320,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(_errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppBuilder.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: code == 'BSV',
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 250,
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'paymail address'
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    _paymailAddress = text;
                                  });
                                }
                              ),
                            ),
                            Visibility(
                              visible: _paymailAddress.length > 0,
                              maintainAnimation: true,
                              maintainState: true,
                              maintainSize: true,
                              child: Container(
                                margin: EdgeInsets.only(bottom: _saving ? 0 : 30),
                                child: _saving ? 
                                  SpinKitCircle(
                                    color: AppBuilder.blue,
                                  ) : GestureDetector(
                                    onTap: () {
                                      _saving = true;
                                      _closeKeyboard();
                                      _setAddress(_paymailAddress);
                                    },
                                    child: Text('Save',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppBuilder.blue,
                                        fontSize: 18,
                                      )
                                    )
                                  )
                              )
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _pasteAddress,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 20.0),
                              child: _pasting ? 
                              SpinKitCircle(
                                color: AppBuilder.green,
                              ) : Icon(
                                Icons.content_paste,
                                size: 50,
                              ),
                            ),
                            Text('Paste',
                              style: TextStyle(
                                fontSize: 50,
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _scanAddress,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 20.0, top: 15.0),
                              child: Icon(
                                Icons.camera_alt,
                                size: 50,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20.0, top: 15.0),
                              child: Text('Scan',
                                style: TextStyle(
                                  fontSize: 50,
                                ),
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CircleBackButton(
                  margin: EdgeInsets.only(top: 20.0),
                  backPath: '/settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

