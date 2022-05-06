import 'dart:developer';

import 'package:wazplay/support/eloquents/playlist.dart';
import 'package:wazplay/support/interfaces/previewable.dart';
import 'package:wazplay/support/models/song.dart';

class Playlist implements PreviewAble {
  int id;
  String description;
  List<Song>? songs;
  DateTime? createdAt;
  DateTime? updatedAt;
  Playlist(
      {required this.id,
      this.songs,
      this.description = '',
      this.createdAt,
      this.updatedAt});

  factory Playlist.fromDB(Map<String, dynamic> data) {
    return Playlist(
        songs: data[PlaylistFields.songs],
        id: data[PlaylistFields.id],
        description: data[PlaylistFields.description],
        createdAt: DateTime.tryParse(data[PlaylistFields.createdAt]),
        updatedAt: DateTime.tryParse(data[PlaylistFields.updatedAt]));
  }

  static Future<Playlist> temp(String description) async {
    var playlistEloquent = PlaylistEloquent();
    var latestPlaylist = await playlistEloquent.latest();
    int tempId = 1;
    if (latestPlaylist != null) {
      tempId = int.parse(latestPlaylist['id'].toString());
    }
    return Playlist(description: description, id: tempId);
  }

  Map<String, Object?> toJson() {
    return {
      PlaylistFields.description: description,
      PlaylistFields.createdAt:
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      PlaylistFields.updatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Future<void> save() async {
    var playlistEloquent = PlaylistEloquent();
    await playlistEloquent.createIfNotExists(
        check: {PlaylistFields.description: description}, create: toJson());
  }

  @override
  String? getDescription() {
    return null;
  }

  @override
  String? getImagePlaceholder() {
    return null;
  }

  @override
  String getSubtitle() {
    return '';
  }

  @override
  String getTitle() {
    return description;
  }

  @override
  void onClick(PreviewAble item) {
    // TODO: implement onClick
  }
}

class PlaylistFields {
  static const id = 'id';
  static const description = 'description';
  static const songs = 'songs';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}
