import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';

class ControllersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MusicController());
    Get.lazyPut(() => SongController());
  }
}
