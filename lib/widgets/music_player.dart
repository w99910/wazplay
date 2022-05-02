import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/singletons/audio_handler.dart';
import 'package:wazplay/support/utils/control_buttons.dart';
import 'package:wazplay/widgets/custom_image.dart';

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {
  // ignore: prefer_final_fields
  final List<Playable> playables;
  late bool _isPreview;
  final bool isConcatenated;
  // final String
  MusicPlayer({Key? key, required this.playables, required this.isConcatenated})
      : _isPreview = false,
        super(key: key);

  MusicPlayer.preview(
      {Key? key, required this.playables, required this.isConcatenated})
      : _isPreview = true,
        super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late CustomAudioHandler _audioHandler;
  late AudioPlayer _audioPlayer;
  late Playable _currentTrack;
  late List<Playable> _playables;

  @override
  void initState() {
    _playables = widget.playables;
    _audioHandler = CustomAudioHandler.instance;
    _audioPlayer = _audioHandler.audioPlayer;
    super.initState();
    init();
  }

  init() async {
    //Set Audio Source
    await _audioHandler.setAudioSource(_playables);
    //Set Audio Session
    await _audioHandler
        .setAudioSession(const AudioSessionConfiguration.music());
    _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._isPreview) {
      return buildPreview();
    }
    return Container();
  }

  Widget buildPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: [
        buildPlaceholder(context, width: 40, height: 40),
        const SizedBox(
          width: 10,
        ),
        Text(
          _currentTrack.getTitle(),
          overflow: TextOverflow.ellipsis,
        ),
        ControlButton.buildPlayButton(_audioPlayer, iconSize: 32)
      ]),
    );
  }

  Widget buildPlaceholder(BuildContext context,
      {required double width, required double height}) {
    return _currentTrack.getThumbnailPath() != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
              size: width * 0.5,
              color: Theme.of(context).primaryColorDark,
            ),
          );
  }
}
