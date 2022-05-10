import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wazeloquent/wazeloquent.dart' show DB;
import 'package:wazplay/configurations/app_theme.dart';
import 'package:wazplay/index.dart';
import 'package:wazplay/support/bindings/controllers_bindings.dart';
import 'package:wazplay/support/eloquents/playlist.dart';
import 'package:wazplay/support/eloquents/song.dart';

Future<void> main() async {
  DB db = DB.instance;
  db.setDbVersion(1);
  db.setFileName('wazplay-1.0.1.db');
  db.onCreate([SongEloquent.onCreate, PlaylistEloquent.onCreate]);
  db.onOpen([SongEloquent.onOpen, PlaylistEloquent.onOpen]);
  db.onConfigure([
    Future(() {
      return (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      };
    })
  ]);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  var _pref = await SharedPreferences.getInstance();

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: false // optional: set false to disable printing logs to console
      );
  // await _pref.clear();
  ThemeMode mode = !_pref.containsKey('isDarkMode')
      ? ThemeMode.system
      : _pref.getBool('isDarkMode')!
          ? ThemeMode.dark
          : ThemeMode.light;
  runApp(MyApp(
    themeMode: mode,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({Key? key, required this.themeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter VideoDownload Demo',
      theme: AppTheme.lightTheme,
      initialBinding: ControllersBinding(),
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const Index(),
    );
  }
}
