import 'package:flutter/material.dart';
import 'package:app/coins.dart';


class Preloader {

  static void downloadImages(context) {
    Coins.all.forEach((code, details) {
      var configuration = createLocalImageConfiguration(context);
      new NetworkImage(details['icon'])..resolve(configuration);
    });
  }

}

