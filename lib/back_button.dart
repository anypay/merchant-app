import 'package:flutter/material.dart';

class CircleBackButton extends StatelessWidget {
  CircleBackButton({this.backPath, this.onTap, this.margin});
  final backPath;
  final margin;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
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
          image: AssetImage('assets/images/close-button.png')
        ),
      ),
    );
  }
}
