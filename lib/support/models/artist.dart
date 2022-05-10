import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wazplay/support/interfaces/previewable.dart';

class Artist implements PreviewAble {
  String name;
  String? thumbnail;
  String? bio;
  Artist({required this.name, required this.thumbnail, required this.bio});

  static Future<Map<String, dynamic>?> getDetails(String authorName) async {
    var url = Uri.parse(
        'https://www.theaudiodb.com/api/v1/json/2/search.php?s=$authorName');
    var response = await http.get(url).timeout(const Duration(seconds: 10));
    Map<String, dynamic> data = await json.decode(response.body);
    if (data['artists'] == null) {
      return null;
    }
    Map<String, dynamic> d = data['artists'][0];
    return d;
  }

  @override
  String? getDescription() {
    return null;
  }

  @override
  String? getImagePlaceholder() {
    return thumbnail;
  }

  @override
  String getSubtitle() {
    return '';
  }

  static extractArtistName(String string) {
    String artist = string;
    if (artist.contains('-')) {
      artist = artist.split('-')[0];
    }

    artist = artist
        .splitMapJoin(RegExp(r'([^a-zA-Z\s].*)'), onMatch: (match) => '')
        .trim();
    return artist;
  }

  @override
  String getTitle() {
    return name;
  }

  @override
  void onClick(PreviewAble item) {
    // TODO: implement onClick
  }
}
