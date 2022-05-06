import 'dart:developer';

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
import 'package:wazplay/widgets/info_box.dart';
import 'package:wazplay/widgets/preview.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    recentlyPlaylists.addAll(await playlistController.getPlaylists());
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
                              ),
                            );
                          }
                          return buildAddPlaylistWidget(context,
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

  Widget buildAddPlaylistWidget(BuildContext context,
      {double? width, double? height, Alignment? alignment}) {
    Size size = MediaQuery.of(context).size;
    return Align(
      alignment: alignment ?? Alignment.center,
      child: InfoBox(
          onPressed: () async {
            String? description;
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                      title: const Text('Create new playlist.'),
                      content: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 8),
                          child: TextField(
                            onChanged: (value) => description = value,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Name your playlist',
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Create',
                                style: TextStyle(color: Colors.green[400]))),
                        TextButton(
                            onPressed: () {
                              description = null;
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red[400]),
                            ))
                      ]);
                });
            if (description != null) {
              Playlist? playlist =
                  await playlistController.create(description: description!);
              if (playlist != null) {
                musicController.reload();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PlaylistWidget(playlist: playlist)));
              }
            }
          },
          width: width ?? size.width * 0.9,
          height: height ?? size.height * 0.22,
          bgColor: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(8),
          textAlign: TextAlign.center,
          message: 'Create New Playlist +'),
    );
  }
}
