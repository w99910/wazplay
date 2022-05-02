import 'package:just_audio/just_audio.dart';

abstract class Playable {
  String getTitle();
  String getAuthor();
  String? getDescription();
  String getAudioPath();
  Duration getInitialDuration();
  AudioSource getAudioSource();
  String? getThumbnailPath();
}
