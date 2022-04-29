import 'package:flutter/material.dart';

class LogoIcon extends StatelessWidget {
  final double? width;
  final double? height;
  const LogoIcon({ Key? key,this.width,this.height }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Image.asset('assets/images/logo.png',
      fit: BoxFit.cover,
      width: width,
      height:height));
  }
}