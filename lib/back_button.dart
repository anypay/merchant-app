import 'package:flutter/material.dart';
import 'package:app/app_builder.dart';

class CircleBackButton extends StatelessWidget {
  CircleBackButton({this.backPath, this.onTap, this.margin});
  final backPath;
  final margin;
  final onTap;

  @override
  Widget build(BuildContext context) {
    var imagePath = 'assets/images/close-button.png';
    if (AppBuilder.enableDarkMode)
      imagePath = 'assets/images/close-button-light.png';
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).canvasColor,
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
