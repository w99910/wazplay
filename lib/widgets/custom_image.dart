import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:wazplay/support/extensions/string.dart';

class CustomImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? boxFit;
  const CustomImage(
      {Key? key, required this.url, this.width, this.boxFit, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return url.isUrl()
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: boxFit ?? BoxFit.contain,
          )
        : Image.file(
            File(url),
            width: width,
            height: height,
            fit: boxFit ?? BoxFit.contain,
          );
  }
}
