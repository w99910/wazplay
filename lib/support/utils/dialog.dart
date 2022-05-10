import 'package:flutter/cupertino.dart';

class CustomDialog {
  static Future showSimpleDialog(BuildContext context,
      {required String text,
      TextStyle? textStyle,
      bool? barrierDismissible}) async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible ?? true,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        );
      },
    );
  }
}
