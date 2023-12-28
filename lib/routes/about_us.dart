import 'package:app/package_info_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/app_controller.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../coins.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "AnyPay",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text("support@anypayx.com"),
              SizedBox(
                height: 10,
              ),
              Text(
                "Build ${PackageInfoPlusHelper.build}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
                  SizedBox(
                    height: 10,
                  ),
              Text("2024",  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
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

  Widget _clickable({String title, String url}) {
    return GestureDetector(
        onTap: () async {
          await launchUrl(Uri.parse(url));
        },
        child: Text(title,  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),));
  }
}
