import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app/authentication.dart';
import 'package:app/models/invoice.dart';
import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';
import 'package:app/events.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart'
if (dart.library.html) 'package:app/web_launcher.dart';

class PushNotificationsManager {
  bool _initialized = false;

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
  PushNotificationsManager._();

  Future<void> init() async {
    if (_initialized) return;

    await _initializeSocket();
    if (!kIsWeb) await _initializeFireBase();

    _initialized = true;
  }

  void _triggerSocketMessage(message) {
    Events.trigger(message['event'], message['payload']);
  }

  void _triggerGrabAndGoPayment(data) {
    var invoice = Invoice.fromMap({
      'denomination_amount_paid': data['amount'],
      'item_name': data['item_name'],
      'uid': data['invoice_uid'],
    });
    AppController.openDialog("${invoice.paidAmountWithDenomination()} PAID",
        "Grab n Go ${invoice.itemName ?? "item"}",
        buttons: [
          {
            'text': 'Open Invoice',
            'onPressed': () {
              AppController.openPath(
                  data['path'] ?? "/payments/${invoice.uid}");
            },
          }
        ]);
  }

  void _initializeSocket() async {
    var url = "https://ws.anypayinc.com?token=${Authentication.token}";
    IO.Socket socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket']
    });
    Events.on('grab_and_go.payment', _triggerGrabAndGoPayment);
    socket.on('connect', (_) => print("SOCKET CONNECTED!"));
    socket.on('error', (_) => print("SOCKET ERROR! $_"));
    socket.on('message', _triggerSocketMessage);
  }

  Future<void> _handleMessage(
      RemoteMessage message) async {
    if (message != null) {
      AppController.openPath(message.data['path']);
    }
  }

  void _initializeFireBase() async {
    print("INIT FIREBASE");
    // For iOS request permission first.
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onBackgroundMessage(_handleMessage);

    String token = await FirebaseMessaging.instance.getToken();
    print("FirebaseMessaging token: $token");
    await Client.setFireBaseToken(token);
  }
}
