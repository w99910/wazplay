import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/widgets/info_box.dart';
import 'package:wazplay/widgets/preview.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> songs = [];
  List<Song> recentlyAdded = [];
  List<Song> recentlyPlayed = [];
  late SongController songController;
  late MusicController musicController;
  bool loading = true;
  @override
  void initState() {
    songController = SongController();
    musicController = Get.find<MusicController>();
    init();
    super.initState();
  }

  init() async {
    songs.addAll(await songController.all());
    recentlyAdded.addAll(songs);
    recentlyPlayed.addAll(songs);
    setState(() {
      recentlyAdded.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      recentlyPlayed.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? const Center(child: CircularProgressIndicator.adaptive())
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi Zaw,',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),
                  Text('Recently Played',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  recentlyPlayed.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.22,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder:
                                  (BuildContext buildcontext, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    List<Song> currentSongs = [];
                                    currentSongs.addAll(recentlyPlayed);
                                    currentSongs.insert(
                                        0, currentSongs.removeAt(index));
                                    musicController.songs.value = currentSongs;
                                    if (musicController.isPlaying.value == -1) {
                                      musicController.isPlaying.value = 1;
                                    }
                                  },
                                  child: Preview(
                                      previewAble: recentlyPlayed[index],
                                      width: size.width * 0.45,
                                      height: size.height * 0.3),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    width: 20,
                                  ),
                              itemCount: recentlyPlayed.length),
                        )
                      : InfoBox(
                          width: size.width * 0.45,
                          height: size.height * 0.22,
                          messageTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          bgColor: Colors.black,
                          message: 'Add New Song'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Recently Added',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  recentlyAdded.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.22,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder:
                                  (BuildContext buildcontext, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    List<Song> currentSongs = [];
                                    currentSongs.addAll(recentlyAdded);
                                    currentSongs.insert(
                                        0, currentSongs.removeAt(index));
                                    musicController.songs.value = currentSongs;
                                    if (musicController.isPlaying.value == -1) {
                                      musicController.isPlaying.value = 1;
                                    }
                                  },
                                  child: Preview(
                                      previewAble: recentlyAdded[index],
                                      width: size.width * 0.45,
                                      height: size.height * 0.3),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    width: 20,
                                  ),
                              itemCount: recentlyAdded.length),
                        )
                      : InfoBox(
                          width: size.width * 0.45,
                          height: size.height * 0.22,
                          messageTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          bgColor: Colors.black,
                          message: 'Add New Song'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Playlists',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.22,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext buildcontext, int index) {
                          return InfoBox(
                            height: size.height * 0.15,
                            width: size.width * 0.45,
                            bgColor: Colors.black,
                            message: 'Create Playlist',
                            messageTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(
                              width: 20,
                            ),
                        itemCount: 1),
                  )
                ],
              ),
            ));
  }
}
