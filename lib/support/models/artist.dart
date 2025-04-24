import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:wazplay/support/interfaces/previewable.dart';

class Artist implements PreviewAble {
  String name;
  String? thumbnail;
  String? bio;
  Artist({required this.name, required this.thumbnail, required this.bio});

  static Future<Map<String, dynamic>?> getDetails(String authorName) async {
    var url = Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=query&titles=$authorName&prop=extracts|pageimages&exintro=true&explaintext=true&pithumbsize=600&format=json&formatversion=2',
    );
    var response = await http.get(url).timeout(const Duration(seconds: 10));
    Map<String, dynamic> data = await json.decode(response.body);
    // inspect(data);

    if (data['query'] == null) {
      return null;
    }

    if (data['query']['pages'] is List && data['query']['pages'][0] == null) {
      return null;
    }

    var page = data['query']['pages'][0];
    Map<String, dynamic> d = {
      "strBiographyEN": page["extract"],
      "strArtistThumb":
          page["thumbnail"] != null && page["thumbnail"] is Map
              ? page["thumbnail"]["source"]
              : null,
    };
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

    artist =
        artist
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
