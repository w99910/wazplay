import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/playlist_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/singletons/audio_handler.dart';
import 'package:wazplay/support/utils/control_buttons.dart';
import 'package:wazplay/support/utils/custom_rect_tween.dart';
import 'package:wazplay/support/utils/lyrics_api.dart';
import 'package:wazplay/widgets/custom_image.dart';

class MusicPlayer extends StatefulWidget {
  final List<Playable> playables;
  final Playable currentTrack;
  final bool shouldUpdateAudioSource;
  const MusicPlayer(
      {Key? key,
      required this.playables,
      required this.currentTrack,
      this.shouldUpdateAudioSource = false})
      : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late CustomAudioHandler _audioHandler;
  late AudioPlayer _audioPlayer;
  late Playable _currentTrack;
  late List<Playable> _playables;
  late MusicController _musicController;
  late SongController _songController;
  late PlaylistController _playlistController;
  @override
  void initState() {
    _playables = widget.playables;
    _musicController = Get.find<MusicController>();
    _songController = Get.find<SongController>();
    _playlistController = Get.find<PlaylistController>();
    _audioHandler = CustomAudioHandler.instance;
    _audioPlayer = _audioHandler.audioPlayer;
    _currentTrack = widget.currentTrack;
    super.initState();
    if (widget.shouldUpdateAudioSource) {
      init();
    }
    _audioPlayer.sequenceStateStream.listen((event) {
      if (event != null) {
        if (mounted) {
          MediaItem mediaItem = event.currentSource!.tag;
          setState(() {
            _currentTrack = _playables
                .where((element) => element.getTitle() == mediaItem.title)
                .first;
          });
          _songController.updateItem(
              id: _currentTrack.getId(),
              update: {'updatedAt': DateTime.now().toIso8601String()});
        }
      }
    });
  }

  init() async {
    await _audioHandler.setAudioSource(_playables);
    //Set Audio Session
    await _audioHandler
        .setAudioSession(const AudioSessionConfiguration.music());
    _audioPlayer.play();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  delete(Playable playable) async {
    await _songController.deleteSong(playable);
    bool? isSuccess = await _audioHandler.remove(_audioPlayer.currentIndex!);
    _musicController.reload();
    if (!isSuccess) {
      _musicController.songs.value = [];
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pop(context);
      });
    }
  }

  Stream<PositionData> get _positionDataStream =>
      RxDart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _audioPlayer.positionStream,
          _audioPlayer.bufferedPositionStream,
          _audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () async {
              Navigator.pop(context);
            }),
        actions: [
          PopupMenuButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            itemBuilder: (BuildContext context) => <PopupMenuItem>[
              PopupMenuItem(
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 50), () async {
                      await showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14))),
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: size.height * 0.6,
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 12),
                              child: FutureBuilder(
                                  future: _playlistController.getPlaylists(),
                                  builder: (_,
                                      AsyncSnapshot<List<Playlist>> snapshot) {
                                    if (!snapshot.hasData) {
                                      return const CircularProgressIndicator
                                          .adaptive();
                                    }
                                    List<Playlist> playlists = snapshot.data!;
                                    return ListView.separated(
                                        itemBuilder: (_, int index) {
                                          return SizedBox();
                                        },
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12),
                                        itemCount: playlists.length);
                                  }),
                            );
                          });
                      // bool confirm = false;
                      // await showDialog(
                      //     context: context,
                      //     builder: (builder) {
                      //       return CupertinoAlertDialog(
                      //         title: const Text(
                      //             'Are you sure to delete the song?'),
                      //         actions: [
                      //           TextButton(
                      //               onPressed: () {
                      //                 Navigator.pop(context);
                      //                 confirm = true;
                      //               },
                      //               child: Text('Yes',
                      //                   style:
                      //                       TextStyle(color: Colors.red[400]))),
                      //           TextButton(
                      //               onPressed: () {
                      //                 Navigator.pop(context);
                      //               },
                      //               child: Text('No',
                      //                   style:
                      //                       TextStyle(color: Colors.red[400]))),
                      //         ],
                      //       );
                      //     });

                      // if (confirm) {
                      //   delete(_currentTrack);
                      // }
                    });
                  },
                  child: const ListTile(
                    leading: Icon(Icons.delete),
                    dense: true,
                    title: Text('Add to playlist'),
                  )),
              PopupMenuItem(
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 50), () async {
                      bool confirm = false;
                      await showDialog(
                          context: context,
                          builder: (builder) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                  'Are you sure to delete the song?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      confirm = true;
                                    },
                                    child: Text('Yes',
                                        style:
                                            TextStyle(color: Colors.red[400]))),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No',
                                        style:
                                            TextStyle(color: Colors.red[400]))),
                              ],
                            );
                          });

                      if (confirm) {
                        delete(_currentTrack);
                      }
                    });
                  },
                  child: const ListTile(
                    leading: Icon(Icons.delete),
                    dense: true,
                    title: Text('Delete'),
                  )),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          )
          // DropdownButton(items: [], onChanged: onChanged)
          // IconButton(onPressed: () {
          // }, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          height: size.height,
          width: size.width * 0.95,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: '_placeholder',
                  createRectTween: (begin, end) =>
                      CustomRectTween(begin: begin!, end: end!),
                  child: buildPlaceholder(context, height: size.height * 0.3),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrack.getTitle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentTrack.getAuthor(),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      const SizedBox(height: 10),
                      _currentTrack.getDescription() != null
                          ? GestureDetector(
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
                                                  SelectableText(_currentTrack
                                                      .getDescription()!),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Text(_currentTrack.getDescription()!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline)))
                          : const SizedBox(height: 10),
                    ],
                  ),
                ),
                StreamBuilder<PositionData>(
                  stream: _positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition:
                          positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: (newPosition) {
                        _audioPlayer.seek(newPosition);
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ControlButton.buildPreviousButton(
                        audioPlayer: _audioPlayer),
                    const SizedBox(width: 14),
                    ControlButton.buildPlayButton(_audioPlayer),
                    const SizedBox(width: 14),
                    ControlButton.buildNextButton(audioPlayer: _audioPlayer),
                  ],
                ),
                ControlButton.buildVolumeSlider(
                    audioPlayer: _audioPlayer, context: context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Tooltip(
                        message: 'Show Lyrics', child: buildLyricsButton(size)),
                    Tooltip(
                      message: 'Switch Loop Mode',
                      child: ControlButton.buildLoopButton(_audioPlayer,
                          onClick: (LoopMode loopMode) async {
                        (await SharedPreferences.getInstance())
                            .setString('loopMode', loopMode.name);
                      }, enableColor: Theme.of(context).iconTheme.color),
                    ),
                    Tooltip(
                      message: 'Toggle Shuffle',
                      child: ControlButton.buildShuffleButton(_audioPlayer,
                          onClick: (isShuffle) async {
                        (await SharedPreferences.getInstance())
                            .setBool('isShuffle', isShuffle);
                      }, enableColor: Theme.of(context).iconTheme.color),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlaceholder(BuildContext context,
      {double? width, double? height, double borderRadius = 10}) {
    return _currentTrack.getThumbnailPath() != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CustomImage(
              url: _currentTrack.getThumbnailPath()!,
              height: height,
              width: width,
              boxFit: BoxFit.fill,
            ))
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).primaryColor,
            ),
            width: width,
            height: height,
            child: Icon(
              Icons.image,
              size: width != null ? width * 0.5 : 32,
              color: Theme.of(context).primaryColorDark,
            ),
          );
  }

  IconButton buildLyricsButton(Size size) {
    return IconButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              context: context,
              builder: (BuildContext context) {
                String? lyrics;
                if (prefs.containsKey(_currentTrack.getTitle())) {
                  // prefs.remove(_currentTrack.getTitle());
                  lyrics = prefs.getString(_currentTrack.getTitle())!;
                }
                return SafeArea(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: size.height * 0.8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            lyrics == null
                                ? FutureBuilder(
                                    future: Future<String>(() async {
                                    var title = _currentTrack.getTitle();
                                    if (!RegExp(r'\-').hasMatch(title)) {
                                      return 'Lyrics Not Found';
                                    }
                                    try {
                                      var payload =
                                          LyricApi.getArtistAndTrack(title);
                                      var response = await LyricApi.getLyrics(
                                          artist: payload[Lyric.artist]!,
                                          track: payload[Lyric.track]!);
                                      await prefs.setString(
                                          _currentTrack.getTitle(), response);
                                      return response;
                                    } catch (e) {
                                      return 'Lyrics Not Found';
                                    }
                                  }), builder:
                                        (context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    }
                                    return SelectableText(snapshot.data);
                                  })
                                : SelectableText(lyrics),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
        icon: const Icon(Icons.text_snippet));
  }
}
