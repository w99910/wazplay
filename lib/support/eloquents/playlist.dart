import 'package:sqflite/sqlite_api.dart';
import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/models/playlist.dart';
import 'package:wazplay/support/models/song.dart';

class PlaylistEloquent extends BaseEloquent {
  @override
  List<String> get columns => [
        PlaylistFields.id,
        PlaylistFields.songs,
        PlaylistFields.description,
        PlaylistFields.createdAt,
        PlaylistFields.updatedAt,
      ];

  @override
  Map<String, dynamic> from(Map<String, dynamic> entry) {
    throw UnimplementedError();
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
            parentTable: 'playlists',
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
            type: DB.integerType),
        'songId': () => DB.foreign(
            foreignKey: 'songId',
            parentKey: SongFields.id,
            parentTable: 'playlists',
            type: DB.integerType),
      });
    };
  });
}
