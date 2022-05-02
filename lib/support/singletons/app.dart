import 'package:wazplay/support/singletons/configuration.dart';

class App {
  late Configuration configuration;
  static final App instance = App._();

  App._() {
    configuration = Configuration();
  }
}
