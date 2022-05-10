import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Configuration {
  late bool vibrateable;
  late bool isDarkMode;
  late bool autoDownloadThumb;

  late SharedPreferences sharedPreferences;

  Configuration() {
    init();
  }

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isDarkMode = sharedPreferences.getBool('isDarkMode') ?? Get.isDarkMode;
    vibrateable = sharedPreferences.getBool('vibrateable') ?? true;

    autoDownloadThumb = sharedPreferences.getBool('autoDownloadThumb') ?? true;
  }

  toggleDarkMode() {
    isDarkMode = !isDarkMode;
    sharedPreferences.setBool('isDarkMode', isDarkMode);
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  toggleVibration() {
    vibrateable = !vibrateable;
    sharedPreferences.setBool('vibrateable', vibrateable);
  }

  toggleAutoDownloadThumbnail() {
    autoDownloadThumb = !autoDownloadThumb;
    sharedPreferences.setBool('autoDownloadThumb', autoDownloadThumb);
  }
}
