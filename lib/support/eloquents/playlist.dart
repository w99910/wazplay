import 'dart:developer';

import 'package:sqflite/sqlite_api.dart';
import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';

class PlaylistEloquent extends BaseEloquent {
  @override
  List<String> get columns => [
        PlaylistFields.id,
        PlaylistFields.description,
        PlaylistFields.createdAt,
        PlaylistFields.updatedAt,
      ];

  @override
  Map<String, dynamic> from(Map<String, dynamic> entry) {
    throw UnimplementedError();
  }

  Future<List<Map<String, Object?>>> getSongs(Playlist playlist) async {
    Database db = await DB.instance.getDB();
    return await db.rawQuery(
        'SELECT s.* from songs s JOIN playlist_songs ps ON ps.songId = s.id JOIN playlists pl ON pl.id = ps.playlistId WHERE pl.id = ${playlist.id}');
  }

  Future<int?> deleteSongs(
      {required List<Song> songs, required Playlist playlist}) async {
    if (songs.isEmpty) {
      return null;
    }
    Database db = await DB.instance.getDB();
    String songIds = '';
    for (var song in songs.asMap().entries) {
      songIds += song.value.id.toString();
      if (song.key != songs.length - 1) {
        songIds += ',';
      }
    }
    String query =
        'DELETE from playlist_songs where playlistId = ${playlist.id} AND songId In ( $songIds )';
    var status = await db.rawQuery(query);
    inspect(status);
    return 1;
  }

  Future<int?> saveSongs(
      {required List<Song> songs, required Playlist playlist}) async {
    if (songs.isEmpty) {
      return null;
    }
    Database db = await DB.instance.getDB();
    var checkSongs = await db.rawQuery(
        'SELECT playlist_songs.songId from playlist_songs WHERE playlistId = ${playlist.id}');
    for (var song in songs) {
      if (checkSongs.isNotEmpty &&
          checkSongs
              .asMap()
              .values
              .where((element) => element['songId'] == song.id.toString())
              .isNotEmpty) {
        continue;
      }
      print('added songId - ${song.id}');
      await db.rawInsert(
          'INSERT INTO playlist_songs (playlistId,songId) values (${playlist.id},${song.id})');
    }
    return 1;
  }

  @override
  String getPrimaryColumn() {
    return PlaylistFields.id;
  }

  @override
  String get tableName => 'playlists';

  static Future<Function(Database db, int version)> onCreate = Future(() {
    return (Database db, int version) async {
      await DB.createTable(db, tableName: 'playlists', columns: {
        PlaylistFields.id: DB.idType,
        PlaylistFields.description: DB.stringType,
        PlaylistFields.createdAt: DB.stringType,
        PlaylistFields.updatedAt: DB.stringType,
      });

      await DB.createTable(db, tableName: 'playlist_songs', columns: {
        'id': DB.idType,
        'playlistId': () => DB.foreign(
            foreignKey: 'playlistId',
            parentKey: PlaylistFields.id,
            parentTable: 'playlists',
            type: DB.integerType,
            onDelete: DBActions.cascade),
        'songId': () => DB.foreign(
            foreignKey: 'songId',
            parentKey: SongFields.id,
            parentTable: 'songs',
            type: DB.integerType,
            onDelete: DBActions.cascade),
      });
    };
  });

  static Future<Function(Database db)> onOpen = Future(() {
    return (Database db) async {
      await DB.createTable(db, tableName: 'playlists', columns: {
        PlaylistFields.id: DB.idType,
        PlaylistFields.description: DB.stringType,
        PlaylistFields.createdAt: DB.stringType,
        PlaylistFields.updatedAt: DB.stringType,
      });
      await DB.createTable(db, tableName: 'playlist_songs', columns: {
        'id': DB.idType,
        'playlistId': () => DB.foreign(
            foreignKey: 'playlistId',
            parentKey: PlaylistFields.id,
            parentTable: 'playlists',
            type: DB.integerType,
            onDelete: DBActions.cascade),
        'songId': () => DB.foreign(
            foreignKey: 'songId',
            parentKey: SongFields.id,
            parentTable: 'songs',
            type: DB.integerType,
            onDelete: DBActions.cascade),
      });
    };
  });
}
