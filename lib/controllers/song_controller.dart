import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/models/song.dart';

class SongController {
  // static SongController instance = SongController._();

  // late SongEloquent songEloquent;

  // SongController._() {
  //   songEloquent = SongEloquent();
  // }

  final SongEloquent songEloquent = SongEloquent();

  Future<List<Song>> all() async {
    var data = await songEloquent.all();
    List<Song> songs = [];
    for (var song in data) {
      songs.add(Song.fromDB(song));
    }
    return songs;
  }
}
