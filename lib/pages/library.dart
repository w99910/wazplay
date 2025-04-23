import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/playlist_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/pages/artists.dart';
import 'package:wazplay/pages/playlist.dart';
import 'package:wazplay/support/models/artist.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/widgets/add_playlist.dart';
import 'package:wazplay/widgets/custom_text_field.dart';
import 'package:wazplay/widgets/info_box.dart';
import 'package:wazplay/widgets/preview.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with AutomaticKeepAliveClientMixin {
  late TextEditingController _textEditingController;
  late SongController songController;
  late MusicController musicController;
  late PlaylistController playlistController;
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Playlist> playlists = [];
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    songController = Get.find<SongController>();
    musicController = Get.find<MusicController>();
    playlistController = PlaylistController();
    super.initState();
    load();
    musicController.shouldReloadSongs.listen((p0) {
      load();
      // print('load');
    });

    _textEditingController.addListener(() {
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(const Duration(milliseconds: 300), () {
        load();
      });
    });
  }

  load() async {
    songs = [];
    artists = [];
    playlists = [];
    songs.addAll(
      await songController.search(keyword: _textEditingController.text),
    );
    artists.addAll(
      await songController.getArtists(keyword: _textEditingController.text),
    );
    playlists.addAll(
      await playlistController.search(keyword: _textEditingController.text),
    );
    setState(() {
      songs = songs;
      artists = artists;
      playlists = playlists;
      loading = false;
    });
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
                  'Library',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(41, 184, 184, 184),
                        blurRadius: 4.0,
                        offset: Offset(0, 6),
                        spreadRadius: 0.4,
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    hintText: 'Search artist,song or playlists',
                    textEditingController: _textEditingController,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Artists',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                artists.isNotEmpty
                    ? SizedBox(
                      width: size.width,
                      height: size.height * 0.22,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext buildcontext, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (BuildContext context) =>
                                          ArtistPage(artist: artists[index]),
                                ),
                              );
                            },
                            child: Preview(
                              previewAble: artists[index],
                              width: size.width * 0.32,
                              showSubtitle: false,
                              height: size.height * 0.30,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 24),
                        itemCount: artists.length,
                      ),
                    )
                    : Align(
                      alignment: Alignment.center,
                      child: InfoBox(
                        width: size.width * 0.9,
                        height: size.height * 0.2,
                        bgColor: Theme.of(context).cardColor,
                        message: 'Unable to load artists.',
                      ),
                    ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Playlists',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                playlists.isNotEmpty
                    ? SizedBox(
                      width: size.width,
                      height: size.height * 0.22,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext buildcontext, int index) {
                          if (index == 0) {
                            return AddPlaylist(
                              playlistController: playlistController,
                              musicController: musicController,
                              width: size.width * 0.35,
                              height: size.width * 0.35,
                              alignment: Alignment.topLeft,
                            );
                          }
                          index = index - 1;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (BuildContext context) => PlaylistWidget(
                                        playlist: playlists[index],
                                      ),
                                ),
                              );
                            },
                            child: Preview(
                              fallbackIcon: Icons.music_note,
                              previewAble: playlists[index],
                              width: size.width * 0.32,
                              showSubtitle: false,
                              height: size.height * 0.30,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 24),
                        itemCount: playlists.length + 1,
                      ),
                    )
                    : Align(
                      alignment: Alignment.center,
                      child: InfoBox(
                        width: size.width * 0.9,
                        height: size.height * 0.2,
                        bgColor: Theme.of(context).cardColor,
                        message: 'Empty playlists',
                      ),
                    ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Songs',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                songs.isNotEmpty
                    ? SizedBox(
                      width: size.width,
                      height:
                          songs.isNotEmpty
                              ? size.height * 0.1 * songs.length +
                                  (20 * (songs.length - 1))
                              : 40,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext buildcontext, int index) {
                          return GestureDetector(
                            onTap: () {
                              List<Song> currentSongs = [];
                              currentSongs.addAll(songs);
                              currentSongs.insert(
                                0,
                                currentSongs.removeAt(index),
                              );
                              musicController.songs.value = currentSongs;
                              if (musicController.isPlaying.value == -1) {
                                musicController.isPlaying.value = 1;
                              }
                            },
                            child: Preview(
                              axis: Axis.horizontal,
                              previewAble: songs[index],
                              width: size.width,
                              height: size.height * 0.1,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemCount: songs.length,
                      ),
                    )
                    : Align(
                      alignment: Alignment.center,
                      child: InfoBox(
                        width: size.width * 0.9,
                        height: size.height * 0.22,
                        onPressed: () {
                          App.instance.routeController.currentTabIndex.value =
                              2;
                        },
                        bgColor: Theme.of(context).cardColor,
                        message: 'Unable to load songs. Add new song +',
                      ),
                    ),
              ],
            ),
          ),
        );
  }

  @override
  bool get wantKeepAlive => true;
}
