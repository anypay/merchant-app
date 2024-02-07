import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/coins.dart';


class Preloader {

  static bool downloadStarted = false;

  static void downloadImages() async {
    if (downloadStarted) return;
    downloadStarted = true;

    var context = AppController.getCurrentContext();
    Coins.all.forEach((code, details) {
      var configuration = createLocalImageConfiguration(context);
      NetworkImage(details['icon'])..resolve(configuration);
    });
  }

}

