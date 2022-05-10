import 'package:sqflite_common/sqlite_api.dart';
import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/models/song.dart';

class SongEloquent extends Eloquent {
  @override
  List<String> get columns => [
        SongFields.id,
        SongFields.title,
        SongFields.author,
        SongFields.path,
        SongFields.description,
        SongFields.thumbnail,
        SongFields.createdAt,
        SongFields.updatedAt,
        SongFields.currentDuration,
      ];

  @override
  Map<String, dynamic> from(Map<String, dynamic> entry) {
    throw UnimplementedError();
  }

  @override
  String get tableName => 'songs';

  @override
  String get getPrimaryColumn => SongFields.id;

  static Future<Function(Database db, int version)> onCreate = Future(() {
    return (Database db, int version) async {
      await DB.createTable(db, tableName: 'songs', columns: {
        SongFields.id: ColumnType.idType,
        SongFields.title: ColumnType.stringType,
        SongFields.author: ColumnType.stringType,
        SongFields.path: ColumnType.stringType,
        SongFields.description: ColumnType.stringType,
        SongFields.thumbnail: ColumnType.stringType,
        SongFields.createdAt: ColumnType.stringType,
        SongFields.updatedAt: ColumnType.stringType,
        SongFields.currentDuration: ColumnType.stringType
      });
    };
  });

  static Future<Function(Database db)> onOpen = Future(() {
    return (Database db) async {
      await DB.createTable(db, tableName: 'songs', columns: {
        SongFields.id: ColumnType.idType,
        SongFields.title: ColumnType.stringType,
        SongFields.author: ColumnType.stringType,
        SongFields.path: ColumnType.stringType,
        SongFields.description: ColumnType.stringType,
        SongFields.thumbnail: ColumnType.stringType,
        SongFields.createdAt: ColumnType.stringType,
        SongFields.updatedAt: ColumnType.stringType,
        SongFields.currentDuration: ColumnType.stringType
      });
    };
  });
}
