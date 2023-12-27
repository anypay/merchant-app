import 'package:app/package_info_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/app_controller.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import '../coins.dart';



class AboutUs extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("AnyPay",style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500

                  ),),
                  SizedBox(height: 10,),

                  Text("support@anypayx.com"),
                  SizedBox(height: 10,),
                  Text("Build ${PackageInfoPlusHelper.build}",style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500

                  ),),

                  CircleBackButton(
                    margin: EdgeInsets.only(top: 20.0),
                    backPath: '/settings',
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }
}


