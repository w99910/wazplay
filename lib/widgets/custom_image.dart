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
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? chunkEvent) {
              if (chunkEvent == null) {
                return child;
              }
              return fallbackWidget(context);
            },
            errorBuilder: (_, __, ___) => fallbackWidget(context),
          )
        : Image.file(
            File(url),
            width: width,
            height: height,
            fit: boxFit ?? BoxFit.contain,
            errorBuilder: (_, __, ___) => fallbackWidget(context),
          );
  }

  Widget fallbackWidget(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).cardColor,
      child: Center(
          child:
              Icon(Icons.music_note, size: width != null ? width! * 0.25 : 24)),
    );
  }
}
