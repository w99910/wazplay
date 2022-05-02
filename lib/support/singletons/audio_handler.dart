import 'dart:developer';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/utils/control_buttons.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;

class CustomAudioHandler {
  static final CustomAudioHandler instance = CustomAudioHandler._init();

  CustomAudioHandler._init() {
    _audioPlayer = AudioPlayer();
  }

  double? defaultIconSize;

  late AudioPlayer _audioPlayer;

  AudioSession? _audioSession;

  ConcatenatingAudioSource? _audioSource;

  static Widget? _playButton;
  static Widget? _nextButton;
  static Widget? _previousButton;

  AudioPlayer get audioPlayer => _audioPlayer;

  Future setAudioSession(AudioSessionConfiguration configuration,
      {bool force = false}) async {
    if (_audioSession == null) {
      _audioSession = await AudioSession.instance;
      force = true;
    }

    if (force) {
      await _audioSession!.configure(configuration);
    }
  }

  Future<Duration?> setAudioSource(List<Playable> playables) {
    return audioPlayer.setAudioSource(toAudioSource(playables));
  }

  Widget get playButton {
    if (_playButton != null) return _playButton!;
    return ControlButton.buildPlayButton(audioPlayer);
  }

  Widget get nextButton {
    if (_nextButton != null) return _nextButton!;
    return ControlButton.buildNextButton(
        audioPlayer: audioPlayer, iconSize: defaultIconSize);
  }

  Widget get previousButton {
    if (_previousButton != null) return _previousButton!;
    return ControlButton.buildPreviousButton(
        audioPlayer: audioPlayer, iconSize: defaultIconSize);
  }

  static ConcatenatingAudioSource toAudioSource(List<Playable> playables) {
    List<AudioSource> _audioSources = [];
    for (var playable in playables) {
      _audioSources.add(playable.getAudioSource());
    }
    inspect(_audioSources);
    return ConcatenatingAudioSource(children: _audioSources);
  }
}
