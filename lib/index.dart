import 'dart:io';

import 'package:flutter/cupertino.dart'
    show showCupertinoDialog, CupertinoAlertDialog;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/pages/add.dart';
import 'package:wazplay/pages/home.dart';
import 'package:wazplay/pages/library.dart';
import 'package:wazplay/pages/settings.dart';
import 'package:wazplay/pages/terms_and_conditions.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/widgets/logo.dart';
import 'package:wazplay/support/singletons/configuration.dart';
import 'package:wazplay/widgets/music_player_preview.dart';

final List<Widget> pages = [
  const Home(),
  const Library(),
  const AddNewSong(),
  const Settings(),
];

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _currentIndex = 0;
  late PageController _pageController;
  late MusicController _musicController;
  Configuration settings = App.instance.configuration;

  @override
  void initState() {
    _musicController = App.instance.musicController;
    _pageController = PageController();
    init();
    super.initState();
    App.instance.routeController.currentTabIndex.listen((index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  init() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    if (_pref.getBool('acceptedTermsAndConditions') == null) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(height: 1.5),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Before using app, you must agree to this ',
                    ),
                    TextSpan(
                      style: const TextStyle(color: Colors.blue),
                      text: 'Terms And Conditions',
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 20,
                                    ),
                                    child: TermsAndConditions(),
                                  );
                                },
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _pref.setBool('acceptedTermsAndConditions', true);
                  Navigator.pop(context);
                },
                child: Text(
                  'Yes, I agree to those.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green[400]),
                ),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: Text('No', style: TextStyle(color: Colors.red[400])),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LogoIcon(width: 45, height: 45),
              Text(
                'WazPlay',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () =>
                _musicController.isPlaying.value != -1
                    ? MusicPlayerPreview(
                      playables: _musicController.songs,
                      isConcatenated: true,
                    )
                    : const SizedBox(),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (settings.vibrateable) {
                HapticFeedback.lightImpact();
              }
              if (index != _currentIndex) {
                setState(() {
                  _currentIndex = index;
                });
                App.instance.routeController.currentTabIndex.value = index;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.my_library_add),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
