import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wazplay/pages/add_new.dart';
import 'package:wazplay/pages/home.dart';
import 'package:wazplay/pages/library.dart';
import 'package:wazplay/pages/settings.dart';
import 'package:wazplay/widgets/logo.dart';
import 'package:wazplay/support/singletons/settings.dart' as AppSettings;

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
  AppSettings.Settings _appSettings = AppSettings.Settings.instance;

  @override
  void initState() {
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
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_appSettings.vibrateable) {
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
    );
  }
}
