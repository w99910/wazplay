import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/pages/artists.dart';
import 'package:wazplay/support/models/artist.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/app.dart';
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
  List<Song> songs = [];
  List<Artist> artists = [];
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    songController = Get.find<SongController>();
    musicController = Get.find<MusicController>();
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
    songs.addAll(
        await songController.search(keyword: _textEditingController.text));
    artists.addAll(
        await songController.getArtists(keyword: _textEditingController.text));
    setState(() {
      songs = songs;
      artists = artists;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return loading
        ? const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontWeight: FontWeight.w400),
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
                              spreadRadius: 0.4)
                        ]),
                    child: TextField(
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Colors.black, fontWeight: FontWeight.normal),
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        suffixIcon: const Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Search Artist or Track',
                        hintStyle: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Artists',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  artists.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: size.height * 0.22,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder:
                                  (BuildContext buildcontext, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ArtistPage(
                                                  artist: artists[index],
                                                )));
                                  },
                                  child: Preview(
                                      previewAble: artists[index],
                                      width: size.width * 0.32,
                                      showSubtitle: false,
                                      height: size.height * 0.30),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    width: 24,
                                  ),
                              itemCount: artists.length),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: InfoBox(
                              width: size.width * 0.9,
                              height: size.height * 0.2,
                              bgColor: Theme.of(context).cardColor,
                              message: 'Unable to load artists.'),
                        ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Songs',
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  songs.isNotEmpty
                      ? SizedBox(
                          width: size.width,
                          height: songs.isNotEmpty
                              ? size.height * 0.1 * songs.length +
                                  (20 * (songs.length - 1))
                              : 40,
                          child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder:
                                  (BuildContext buildcontext, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    List<Song> currentSongs = [];
                                    currentSongs.addAll(songs);
                                    currentSongs.insert(
                                        0, currentSongs.removeAt(index));
                                    musicController.songs.value = currentSongs;
                                    if (musicController.isPlaying.value == -1) {
                                      musicController.isPlaying.value = 1;
                                    }
                                  },
                                  child: Preview(
                                      axis: Axis.horizontal,
                                      previewAble: songs[index],
                                      width: size.width,
                                      height: size.height * 0.1),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                    height: 20,
                                  ),
                              itemCount: songs.length),
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
                              message: 'Unable to load songs. Add new song +'),
                        ),
                ],
              ),
            ));
  }

  @override
  bool get wantKeepAlive => true;
}
