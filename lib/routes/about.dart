import 'package:app/package_info_helper.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image(
                width: 300,
                image: AssetImage(AppController.logoImagePath())
              ),
              SizedBox(
                height: 10,
              ),
              Text("support@anypayx.com"),
              SizedBox(
                height: 10,
              ),
              _clickable(
                  url: "https://docs.anypayx.com/terms",
                  title: "Terms of Service"),
              SizedBox(
                height: 10,
              ),
              _clickable(
                  url: "https://docs.anypayx.com/privacy",
                  title: "Privacy Policy"),
              SizedBox(
                height: 10,
              ),
              _clickable(
                  url: "https://docs.anypayx.com/", title: "Documentation"),
              SizedBox(
                height: 10,
              ),
              Text(
                "${PackageInfoPlusHelper.version} [Build ${PackageInfoPlusHelper.build}]",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "2024",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 10,
              ),
              CircleBackButton(
                margin: EdgeInsets.only(top: 20.0),
                backPath: '/settings',
              ),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _clickable({required String title, required String url}) {
    return GestureDetector(
        onTap: () async {
          await launchUrl(Uri.parse(url));
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          ],
        ));
  }
}
