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
    var size = AppController.scale(50, minValue: 40, maxValue: 50);
    return Container(
      margin: margin,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color: (opaque ?? true) ? Theme.of(context).canvasColor : Color(0x00000000),
      ),
      child: GestureDetector(
        onTap: onTap ?? (() {
          if (Navigator.canPop(context))
            Navigator.pop(context, true);
          else AppController.closeUntilPath(backPath);
        }),
        child: Image(
          width: size,
          image: AssetImage(imagePath),
        ),
      ),
    );
  }
}
