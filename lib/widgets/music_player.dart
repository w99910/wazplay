import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/singletons/audio_handler.dart';
import 'package:wazplay/support/utils/control_buttons.dart';
import 'package:wazplay/support/utils/custom_rect_tween.dart';
import 'package:wazplay/support/utils/lyrics_api.dart';
import 'package:wazplay/widgets/custom_image.dart';

class MusicPlayer extends StatefulWidget {
  final List<Playable> playables;
  final Playable currentTrack;
  const MusicPlayer(
      {Key? key, required this.playables, required this.currentTrack})
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
  @override
  void initState() {
    _playables = widget.playables;
    _musicController = Get.find<MusicController>();
    _songController = Get.find<SongController>();
    _audioHandler = CustomAudioHandler.instance;
    _audioPlayer = _audioHandler.audioPlayer;
    _currentTrack = widget.currentTrack;
    super.initState();
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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
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
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
              ))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: size.height,
        width: size.width,
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
                  ControlButton.buildPreviousButton(audioPlayer: _audioPlayer),
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
                  buildLyricsButton(size),
                  ControlButton.buildLoopButton(_audioPlayer,
                      enableColor: Colors.black),
                  ControlButton.buildShuffleButton(_audioPlayer,
                      enableColor: Colors.black)
                ],
              )
            ],
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
                                    var payload =
                                        LyricApi.getArtistAndTrack(title);
                                    inspect(payload);
                                    var response = await LyricApi.getLyrics(
                                        artist: payload[Lyric.artist]!,
                                        track: payload[Lyric.track]!);

                                    await prefs.setString(
                                        _currentTrack.getTitle(), response);
                                    return response;
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
