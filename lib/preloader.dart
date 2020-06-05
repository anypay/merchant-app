import 'package:flutter/material.dart';
import 'package:app/coins.dart';


class Preloader {

  static bool downloadStarted = false;

  static void downloadImages(context) async {
    if (downloadStarted) return;
    downloadStarted = true;

    Coins.all.forEach((code, details) {
      var configuration = createLocalImageConfiguration(context);
      NetworkImage(details['icon'])..resolve(configuration);
    });
  }

}

