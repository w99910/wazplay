import 'package:get/get.dart';
import 'package:wazplay/support/interfaces/playable.dart';
import 'package:wazplay/support/models/song.dart';

class MusicController extends GetxController {
  RxList<Song> songs = <Song>[].obs;
  RxInt isPlaying = (-1).obs;
  RxBool shouldReloadSongs = true.obs;
  RxObjectMixin<Playable?> currentTrack = Song(
          id: 0,
          title: 'Mantra',
          author: 'Bring Me The Horizon',
          path: 'Path',
          thumbnail:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTz-uN2qM2DH70_IdrOqnRDW3yR5vn_LlpGRnU8Oevso0rrtGTfI5rzxSwiLfB72HRy52w&usqp=CAU')
      .obs;

  reload() {
    shouldReloadSongs.value = !shouldReloadSongs.value;
  }
}
