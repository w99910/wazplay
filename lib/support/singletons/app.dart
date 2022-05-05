import 'package:get/instance_manager.dart';
import 'package:wazplay/controllers/music_controller.dart';
import 'package:wazplay/controllers/route_controller.dart';
import 'package:wazplay/controllers/song_controller.dart';
import 'package:wazplay/support/singletons/configuration.dart';

class App {
  late Configuration configuration;
  static final App instance = App._();
  late MusicController musicController;
  late SongController songController;
  late RouteController routeController;

  App._() {
    configuration = Configuration();
    musicController = Get.find<MusicController>();
    songController = Get.find<SongController>();
    routeController = Get.find<RouteController>();
  }
}
