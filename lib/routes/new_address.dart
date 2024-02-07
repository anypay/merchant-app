import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Address;
import 'package:app/authentication.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/models/address.dart';
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

  final String code;

  bool _scanning = false;
  bool _submittingScan = false;
  bool _savingNote = false;
  bool _disposed = false;
  bool _pasting = false;
  bool _saving = false;

  String _paymailAddress = '';
  String _messageType = '';
  String _noteError = '';
  String _message = '';
  String _note = '';
  Address _address;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeKeyboard,
      child: Scaffold(
        body: Center(
          child: _scanning ? Stack(children: [
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _scanning = false;
                  _submittingScan = true;
                  _setAddress(barcode.rawValue);
                }
              },
            ),
            CircleBackButton(
              margin: EdgeInsets.only(top: 20.0),
              backPath: '/settings',
            )
          ]) :
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _Title(),
                Container(
                  width: 330,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: new BoxConstraints(
                          minHeight: 5.0,
                          minWidth: 330,
                          maxHeight: 80.0,
                          maxWidth: 330,
                        ),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: SelectableText(_message ?? '',
                            toolbarOptions: ToolbarOptions(
                              copy: true,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _messageColor(),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      _PaymailField(),
                      _NoteField(),
                      _Paste(),
                      _Scan(),
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

  void _rebuild() {
    if (!_disposed)
      setState(() {
        _address = Authentication.currentAccount.addressFor(this.code);
        _note = _address?.note ?? "";
        _message = _address?.toString();
        _messageType = 'success';
      });
  }

  @override
  void initState() {
    super.initState();
    _rebuild();
    Authentication.fetchCoins().then((v) => _rebuild());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _pasteAddress() async {
    ClipboardData clipboard = await Clipboard.getData('text/plain');
    if (clipboard.text == null || clipboard.text == '') {
      _message = 'Nothing to paste';
      _messageType = 'error';
      return;
    }
    setState(() { _pasting = true; });
    var address = clipboard.text;
    _setAddress(address);
  }

  void _scanAddress() async {
    _scanning = true;
  }

  void _setNote() async {
    setState(() {
      _savingNote = true;
    });
    Client.setAddressNote(_address.id, _note).then((response) {
      if (!_disposed)
        setState(() {
          if (response['success']) {
            _savingNote = false;
            _address.note = _note;
          } else _noteError = response['message'];
        });
    });
  }

  void _setAddress(address) async {
    setState(() {
      _messageType = 'pending';
      _message = address;
    });

    var coinCode, coinChain;

    var coinCodename = code.split('_');

    coinCode = coinCodename[0];

    if (coinCodename.length == 1) {
      coinChain = coinCode;
    } else {
      coinChain = coinCodename[1];
    }

    Client.setAddress(coinCode, coinChain, address).then((response) {
      if (!_disposed)
        setState(() {
          _submittingScan = false;
          _pasting = false;
          _saving = false;
          if (response['success']) {
            Authentication.fetchCoins().then((v) => _rebuild());
            _address = Address.fromMap({ 'value': address });
            _messageType = 'success';
            _message = address;
            Timer(Duration(milliseconds: 800), _returnToNewInvoice);
          } else {
            _messageType = 'error';
            _message = response['body']['payload']['message'];
            if (_message != null &&
                _message.toLowerCase().contains('invalid bch address') &&
                address.length <= 36)
              _message += "\n(Legacy BCH addresses are not supported)";
          }
        });
    });
  }

  void _returnToNewInvoice() {
    AppController.closeUntilPath('/new-invoice');
  }

  Color _messageColor() {
    return {
      'pending': Theme.of(context).primaryColorDark,
      'success': AppController.green,
      'error': AppController.red,
    }[_messageType];
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }

  Widget _Title() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _Scan() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _scanAddress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20.0, top: 15.0),
            child: _submittingScan ?
            SpinKitCircle(
              color: AppController.green,
            ) : Icon(
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
    );
  }

  Widget _Paste() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _pasteAddress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 20.0),
            child: _pasting ?
            SpinKitCircle(
              color: AppController.green,
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
    );
  }

  Widget _NoteField() {
    return Visibility(
      visible: _address != null,
      child: Column(
        children: <Widget>[
          Container(
            width: 250,
            margin: EdgeInsets.only(bottom: _note.length > 0 ? 10 : 20),
            child: TextFormField(
              // controller: _address?.note,
              initialValue: _note,
              validator: (value) {
                if (_noteError.length > 0)
                  return _noteError;
              },
              decoration: InputDecoration(
                labelText: 'Add note...'
              ),
              onChanged: (text) {
                setState(() {
                  _note = text;
                });
              }
            ),
          ),
          Visibility(
            visible: _note.length > 0 && _note != _address?.note,
            child: Container(
              margin: EdgeInsets.only(bottom: _savingNote ? 0 : 20),
              child: _savingNote ?
                SpinKitCircle(
                  color: AppController.blue,
                ) : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _saving = true;
                    _closeKeyboard();
                    _setNote();
                  },
                  child: Text('Save Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppController.blue,
                      fontSize: 18,
                    )
                  )
                )
              )
            )
        ]
      ),
    );
  }

  Widget _PaymailField() {
    return Visibility(
      visible: code == 'BSV',
      child: Column(
        children: <Widget>[
          Container(
            width: 250,
            margin: EdgeInsets.only(bottom: 10),
              child: TextField(
              onSubmitted: (value) {
                _saving = true;
                _closeKeyboard();
                _setAddress(_paymailAddress);
              },
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
            visible: _paymailAddress.length > 0 && _paymailAddress != _address?.toString(),
            child: Container(
              margin: EdgeInsets.only(bottom: _address == null ? 20 : 0),
              child: _saving ?
                SpinKitCircle(
                  color: AppController.blue,
                ) : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _saving = true;
                    _closeKeyboard();
                    _setAddress(_paymailAddress);
                  },
                  child: Text('Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppController.blue,
                      fontSize: 18,
                    )
                  )
                )
            )
          ),
        ],
      ),
    );
  }
}

