import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wazplay/support/models/artist.dart';

class LyricApi {
  static const String baseUrl = 'https://api.lyrics.ovh/v1';
  static Future<String> getLyrics(
      {required String artist, required String track}) async {
    var url = Uri.parse('$baseUrl/$artist/$track');
    var response = await http.get(url).timeout(const Duration(seconds: 10));
    Map data = json.decode(response.body);
    if (data.keys.contains('error')) {
      return 'Lyrics Not Found';
    }
    return data['lyrics']!;
  }

  static Map<Lyric, String> getArtistAndTrack(String title) {
    List<String> split = title.split('-');
    String artist = Artist.extractArtistName(split[0]);
    String track = split[1]
        .replaceAllMapped(RegExp(r'[\(].*'), (match) => '')
        .replaceAllMapped(RegExp(r'[\[]].*'), (match) => '')
        .replaceAllMapped(RegExp(r'(ft).*'), (match) => '');
    return {
      Lyric.artist: artist.trim(),
      Lyric.track: track.trim(),
    };
  }
}

enum Lyric { artist, track }
