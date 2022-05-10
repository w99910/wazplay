import 'package:flutter/material.dart';

class Toast {
  static showErrorToast(BuildContext context, String message,
      {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration ?? const Duration(seconds: 4),
        content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'poppins')),
            ))));
  }

  static showInfoToast(BuildContext context, String message,
      {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration ?? const Duration(seconds: 4),
        content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'poppins')),
            ))));
  }

  static showWarningToast(BuildContext context, String message,
      {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        duration: duration ?? const Duration(seconds: 4),
        backgroundColor: Colors.transparent,
        content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffffb703),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ))));
  }
}
