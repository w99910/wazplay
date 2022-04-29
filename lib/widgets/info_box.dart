import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final Color? bgColor;
  final TextStyle? messageTextStyle;
  final String message;
  final double width, height;
  const InfoBox(
      {Key? key,
      this.bgColor = Colors.blue,
      this.messageTextStyle,
      required this.width,
      required this.height,
      required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / 20),
        color: bgColor,
      ),
      height: height,
      child: Center(
          child: Text(
        message,
        style: messageTextStyle,
      )),
    );
  }
}
