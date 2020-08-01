import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'dart:async';

class ScanAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScanAddressPage(title: 'Scan Address');
  }
}

class ScanAddressPage extends StatefulWidget {
  ScanAddressPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScanAddressPageState createState() => _ScanAddressPageState();
}

class _ScanAddressPageState extends State<ScanAddressPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: AppController.scale(600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: AppController.randomizeColor(),
                  borderRadius: 10,
                  borderWidth: 10,
                )
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    color: Colors.blue,
                    child: Text('Flash'),
                    onPressed: () {
                      controller.toggleFlash();
                    },
                  ),
                  const SizedBox(width: 30),
                  FlatButton(
                    color: Colors.blue,
                    child: Text('Flip'),
                    onPressed: () {
                      controller.flipCamera();
                    },
                  ),
                ],
              ),
            ),
            CircleBackButton(
              margin: EdgeInsets.only(top: 20.0),
              backPath: '/settings',
            ),
          ]
        )
      )
    );
  }


  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedStringStream.listen((scannedString) async {
      Navigator.of(context).pop(scannedString);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
