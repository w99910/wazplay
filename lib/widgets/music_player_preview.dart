import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/models/song.dart';
import 'package:wazplay/support/singletons/audio_handler.dart';
import 'package:wazplay/support/utils/control_buttons.dart';
import 'package:wazplay/support/utils/custom_rect_tween.dart';
import 'package:wazplay/widgets/custom_image.dart';
import 'package:wazplay/widgets/music_player.dart';

// ignore: must_be_immutable
class MusicPlayerPreview extends StatefulWidget {
  // ignore: prefer_final_fields
  final List<Playable> playables;
  final bool isConcatenated;
  // final String
  const MusicPlayerPreview(
      {Key? key, required this.playables, required this.isConcatenated})
      : super(key: key);

  @override
  State<MusicPlayerPreview> createState() => _MusicPlayerPreviewState();
}

class _MusicPlayerPreviewState extends State<MusicPlayerPreview>
    with AutomaticKeepAliveClientMixin {
  late CustomAudioHandler _audioHandler;
  late AudioPlayer _audioPlayer;
  late Playable _currentTrack;
  late List<Playable> _playables;
  late MusicController _musicController;
  late SongController _songController;
  late SharedPreferences _sharedPreferences;
  bool _loading = true;

  @override
  void initState() {
    _playables = widget.playables;
    _musicController = Get.find<MusicController>();
    _songController = Get.find<SongController>();
    _audioHandler = CustomAudioHandler.instance;
    _audioPlayer = _audioHandler.audioPlayer;
    _currentTrack = _playables.first;
    _musicController.currentTrack.value = _currentTrack;
    super.initState();
    setState(() {
      _loading = false;
    });
    init();
    _musicController.songs.listen((value) async {
      _audioPlayer.stop();
      setState(() {
        _playables = value;
      });

      if (value.isNotEmpty) {
        _musicController.currentTrack.value = _currentTrack;
        await _audioHandler.setAudioSource(value);
        _audioPlayer.play();
      } else {
        _musicController.currentTrack.value =
            Song(id: 1, title: "", author: "", path: "", thumbnail: null);
      }
    });
    _musicController.currentTrack.listen((track) {
      if (track != null) {
        setState(() {
          _currentTrack = track;
        });
      }
    });
  }

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    String? loopMode = _sharedPreferences.getString('loopMode');
    bool? isShuffle = _sharedPreferences.getBool('isShuffle');
    if (loopMode != null) {
      _audioPlayer.setLoopMode(
          LoopMode.values.firstWhere((element) => element.name == loopMode));
    }
    if (isShuffle != null) {
      _audioPlayer.setShuffleModeEnabled(isShuffle);
    }

    //Set Audio Source
    await _audioHandler.setAudioSource(_playables);
    //Set Audio Session
    await _audioHandler
        .setAudioSession(const AudioSessionConfiguration.music());
    _audioPlayer.play();
    _audioPlayer.sequenceStateStream.listen((event) async {
      if (event != null) {
        if (mounted) {
          MediaItem mediaItem = event.currentSource!.tag;
          setState(() {
            _currentTrack = _playables
                .where((element) => element.getTitle() == mediaItem.title)
                .first;
          });
          await _songController.updateItem(
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _loading
        ? const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              width: MediaQuery.of(context).size.width,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_playables.isNotEmpty) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext buildContext) =>
                                      MusicPlayer(
                                        currentTrack: _currentTrack,
                                        playables: _playables,
                                      )));
                        }
                      },
                      child: Row(
                        children: [
                          Hero(
                            tag: '_placeholder',
                            createRectTween: (begin, end) =>
                                CustomRectTween(begin: begin!, end: end!),
                            child: buildPlaceholder(context,
                                width: 46, height: 46, borderRadius: 8),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              _currentTrack.getTitle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ControlButton.buildPlayButton(_audioPlayer,
                        iconSize: 32, disable: _playables.isEmpty),
                    ControlButton.buildNextButton(
                        audioPlayer: _audioPlayer,
                        iconSize: 30,
                        disable: _playables.isEmpty),
                  ]),
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

  @override
  bool get wantKeepAlive => true;
}
