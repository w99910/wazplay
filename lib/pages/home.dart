import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/playlist_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/pages/playlist.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/support/utils/greeting.dart';
import 'package:wazplay/support/utils/path.dart';
import 'package:wazplay/widgets/add_playlist.dart';
import 'package:wazplay/widgets/info_box.dart';
import 'package:wazplay/widgets/preview.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  List<Song> recentlyAdded = [];
  List<Song> recentlyPlayed = [];
  List<Playlist> recentlyPlaylists = [];
  late SongController songController;
  late MusicController musicController;
  late PlaylistController playlistController;
  bool loading = true;
  @override
  void initState() {
    songController = SongController();
    playlistController = PlaylistController();
    musicController = Get.find<MusicController>();
    super.initState();
    load();
    musicController.shouldReloadSongs.listen((p0) {
      load();
      // print('load');
    });
  }

  load() async {
    recentlyAdded = [];
    recentlyPlayed = [];
    recentlyPlaylists = [];
    // songs.addAll(await songController.all());
    recentlyAdded.addAll(await songController.all(
        orderBy: 'createdAt', descending: true, limit: 5));
    recentlyPlayed.addAll(await songController.all(
        orderBy: 'updatedAt', descending: true, limit: 5));
    recentlyPlaylists.addAll(await playlistController.all(
        orderBy: 'updatedAt', descending: true, limit: 5));
    setState(() {
      recentlyAdded = recentlyAdded;
      recentlyPlayed = recentlyPlayed;
      loading = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return loading
        ? const Center(child: CircularProgressIndicator.adaptive())
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Greeting.getMessage(),
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  Text('Recently Played',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  recentlyPlayed.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.24,
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
                                      width: size.width * 0.35,
                                      height: size.height * 0.25),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    width: 20,
                                  ),
                              itemCount: recentlyPlayed.length),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: InfoBox(
                              width: size.width * 0.9,
                              height: size.height * 0.22,
                              onPressed: () {
                                App.instance.routeController.currentTabIndex
                                    .value = 2;
                              },
                              bgColor: Theme.of(context).cardColor,
                              message: 'Add New Song +'),
                        ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Recently Added',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  recentlyAdded.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.24,
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
                                      width: size.width * 0.35,
                                      height: size.height * 0.25),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    width: 20,
                                  ),
                              itemCount: recentlyAdded.length),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: InfoBox(
                              width: size.width * 0.9,
                              height: size.height * 0.22,
                              onPressed: () {
                                App.instance.routeController.currentTabIndex
                                    .value = 2;
                              },
                              bgColor: Theme.of(context).cardColor,
                              message: 'Add New Song +'),
                        ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text('Recent Played Playlists',
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.22,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext buildcontext, int index) {
                          if (index != recentlyPlaylists.length &&
                              recentlyPlaylists.isNotEmpty) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PlaylistWidget(
                                            playlist:
                                                recentlyPlaylists[index])));
                              },
                              child: Preview(
                                width: size.width * 0.35,
                                height: size.height * 0.3,
                                previewAble: recentlyPlaylists[index],
                                fallbackIcon: Icons.music_note,
                              ),
                            );
                          }
                          return AddPlaylist(
                              playlistController: playlistController,
                              musicController: musicController,
                              width: recentlyPlaylists.isEmpty
                                  ? null
                                  : size.width * 0.35,
                              height: recentlyPlaylists.isEmpty
                                  ? null
                                  : size.width * 0.35,
                              alignment: recentlyPlaylists.isEmpty
                                  ? null
                                  : Alignment.topLeft);
                        },
                        separatorBuilder: (_, __) => const SizedBox(
                              width: 20,
                            ),
                        itemCount: recentlyPlaylists.length + 1),
                  )
                ],
              ),
            ));
  }

  @override
  bool get wantKeepAlive => true;
}
