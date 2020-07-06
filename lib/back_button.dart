import 'package:app/app_controller.dart';
import 'package:flutter/material.dart';

class CircleBackButton extends StatelessWidget {
  CircleBackButton({this.backPath, this.onTap, this.margin, this.opaque});
  final backPath;
  final opaque;
  final margin;
  final onTap;

  @override
  Widget build(BuildContext context) {
    var imagePath = 'assets/images/close-button.png';
    if (AppController.enableDarkMode)
      imagePath = 'assets/images/close-button-light.png';
    return Container(
      margin: margin,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: (opaque ?? true) ? Theme.of(context).canvasColor : Color(0x00000000),
      ),
      child: GestureDetector(
        onTap: onTap ?? (() {
          if (Navigator.canPop(context))
            Navigator.pop(context, true);
          else
            Navigator.pushNamedAndRemoveUntil(context, backPath, (Route<dynamic> route) => false);
        }),
        child: Image(
          width: 50,
          image: AssetImage(imagePath),
        ),
      ),
    );
  }
}
