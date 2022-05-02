import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/pages/add_new.dart';
import 'package:wazplay/pages/home.dart';
import 'package:wazplay/pages/library.dart';
import 'package:wazplay/pages/settings.dart';
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/widgets/logo.dart';
import 'package:wazplay/support/singletons/configuration.dart';
import 'package:wazplay/widgets/music_player_preview.dart';

final List<Widget> pages = [
  const Home(),
  const Library(),
  const AddNewSong(),
  const Settings()
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
    _musicController = Get.find<MusicController>();
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                style: Theme.of(context).textTheme.headline3!.copyWith(
                    fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                width: 40,
              )
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
          Obx(() => _musicController.isPlaying.value != -1
              ? MusicPlayerPreview(
                  playables: _musicController.songs, isConcatenated: true)
              : const SizedBox()),
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
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut);
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_music), label: 'Library'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.my_library_add), label: 'Add'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings')
              ]),
        ],
      ),
    );
  }
}
