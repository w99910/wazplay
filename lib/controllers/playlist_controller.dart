import 'dart:developer';

import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/eloquents/playlist.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';

class PlaylistController {
  final PlaylistEloquent playlistEloquent = PlaylistEloquent();

  Future<Playlist?> create({required String description}) async {
    int i = await playlistEloquent.create({
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    if (i < 0) {
      return null;
    }
    var data = await playlistEloquent.where('id', i.toString()).get();
    if (data == null || data.isEmpty) {
      return null;
    }
    return Playlist.fromDB(data.first);
  }

  Future<int?> deleteSongs({
    required List<Song> songs,
    required Playlist playlist,
  }) async {
    return await playlistEloquent.deleteSongs(songs: songs, playlist: playlist);
  }

  Future updateItem({
    required String id,
    required Map<String, Object?> update,
  }) async {
    return playlistEloquent.where('id', id.toString()).update(update);
  }

  Future<int?> updateSongs({
    required List<int> songs,
    required Playlist playlist,
  }) async {
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

  Future<List<Playlist>> all({
    int? limit,
    String? orderBy,
    String? groupBy,
    bool? distinct,
    bool descending = false,
    int? offset,
  }) async {
    var el = await playlistEloquent
        .orderBy(orderBy, sort: descending ? Sort.descending : Sort.ascending)
        .skip(offset)
        .take(limit);
    if (distinct != null && distinct) {
      el = el.distinct([]);
    }
    var data = await el.get();
    return fromDB(data!);
  }

  List<Playlist> fromDB(List<Map<String, Object?>> rows) {
    List<Playlist> playlists = [];
    for (var playlist in rows) {
      playlists.add(Playlist.fromDB(playlist));
    }
    return playlists;
  }

  Future<List<Playlist>> search({
    String? keyword,
    int? offset,
    int limit = 10,
  }) async {
    if (keyword == null) return all(limit: limit, offset: offset);
    var data = await playlistEloquent.search(
      keyword,
      searchableColumns: ['description'],
    );
    return fromDB(data);
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
