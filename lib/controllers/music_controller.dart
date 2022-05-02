import 'package:get/get.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/models/song.dart';

class MusicController extends GetxController {
  RxList<Song> songs = <Song>[].obs;
  RxInt isPlaying = (-1).obs;
  RxObjectMixin<Playable?> currentTrack = Song.dummyData.first.obs;
}
