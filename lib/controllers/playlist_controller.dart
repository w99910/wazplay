import 'dart:developer';

import 'package:wazplay/support/eloquents/playlist.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';

class PlaylistController {
  final PlaylistEloquent playlistEloquent = PlaylistEloquent();

  Future<Playlist?> create({required String description}) async {
    int i = await playlistEloquent.create(values: {
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    if (i < 0) {
      return null;
    }
    var data = await playlistEloquent.where({'id': i});
    if (data.isEmpty) {
      return null;
    }
    return Playlist.fromDB(data.first);
  }

  Future<int?> deleteSongs(
      {required List<Song> songs, required Playlist playlist}) async {
    return await playlistEloquent.deleteSongs(songs: songs, playlist: playlist);
  }

  Future<int?> updateSongs(
      {required List<int> songs, required Playlist playlist}) async {
    return await playlistEloquent.saveSongs(songs: songs, playlist: playlist);
  }

  Future<List<Song>> getSongs({required Playlist playlist}) async {
    List<Song> songs = [];
    var data = await playlistEloquent.getSongs(playlist);
    if (data.isNotEmpty) {
      for (var song in data) {
        songs.add(Song.fromDB(song));
      }
    }
    return songs;
  }

  Future<List<Playlist>> getPlaylists() async {
    List<Playlist> playlists = [];
    var data = await playlistEloquent.all();
    for (var playlist in data) {
      playlists.add(Playlist.fromDB(playlist));
    }
    return playlists;
  }

  Future<int> deletePlaylist(Playlist playlist) async {
    return await playlistEloquent.deleteBy(playlist.id);
  }
}
