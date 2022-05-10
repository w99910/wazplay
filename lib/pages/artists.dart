import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/models/artist.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/widgets/music_player.dart';
import 'package:wazplay/widgets/placeholder.dart';
import 'package:wazplay/widgets/preview.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;
  const ArtistPage({Key? key, required this.artist}) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late SongController songController;
  late ScrollController _bodyScrollController;
  late ScrollController _itemsScrollController;
  late MusicController _musicController;
  List<Song> songs = [];
  late Artist artist;
  bool loading = true;

  @override
  void initState() {
    songController = App.instance.songController;
    _bodyScrollController = ScrollController();
    _itemsScrollController = ScrollController();
    _musicController = App.instance.musicController;
    artist = widget.artist;
    super.initState();
    load();
    _itemsScrollController.addListener(() {
      if (_bodyScrollController.hasClients) {
        _bodyScrollController.animateTo(_itemsScrollController.offset,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    });
    _musicController.shouldReloadSongs.listen((p0) {
      load();
      // print('load');
    });
  }

  load() async {
    songs = [];
    songs.addAll(await songController.getSongsByArtist(artist));
    setState(() {
      songs = songs;
      loading = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // init();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SizedBox(
              height: size.height,
              width: size.width,
              child: CustomScrollView(
                controller: _bodyScrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    iconTheme: const IconThemeData(color: Colors.white),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    expandedHeight: size.height * 0.4,
                    stretchTriggerOffset: 150,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      title: Text(
                        artist.name,
                        textScaleFactor: 1,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      stretchModes: const [
                        StretchMode.blurBackground,
                        StretchMode.zoomBackground,
                      ],
                      background: artist.thumbnail != null
                          ? Image.network(
                              artist.thumbnail!,
                              fit: BoxFit.fill,
                            )
                          : Container(
                              color: Colors.black,
                            ),
                    ),
                  ),
                  if (artist.bio != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxHeight: size.height * 0.8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 30),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SelectableText(artist.bio!),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              artist.bio!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline),
                            )),
                      ),
                    ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                        padding: EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: index == 0 ? 16 : 12,
                            bottom: index == songs.length - 1 ? 32 : 8),
                        child: GestureDetector(
                          onTap: () {
                            List<Song> currentSongs = [];
                            currentSongs.addAll(songs);
                            currentSongs.insert(
                                0, currentSongs.removeAt(index));
                            _musicController.songs.value = currentSongs;
                            if (_musicController.isPlaying.value == -1) {
                              _musicController.isPlaying.value = 1;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => MusicPlayer(
                                          playables: songs,
                                          currentTrack: songs[index],
                                          // shouldUpdateAudioSource: true,
                                        )));
                          },
                          child: Preview(
                              axis: Axis.horizontal,
                              previewAble: songs[index],
                              width: size.width,
                              height: size.height * 0.1),
                        ));
                  }, childCount: songs.length)),
                ],
              ),
            ),
    );
  }
}
