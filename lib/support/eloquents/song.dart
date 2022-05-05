import 'package:sqflite_common/sqlite_api.dart';
import 'package:wazeloquent/wazeloquent.dart';
import 'package:wazplay/support/models/song.dart';

class SongEloquent extends BaseEloquent {
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
  String getPrimaryColumn() {
    return SongFields.id;
  }

  static Future<Function(Database db, int version)> onCreate = Future(() {
    return (Database db, int version) async {
      await DB.createTable(db, tableName: 'songs', columns: {
        SongFields.id: DB.idType,
        SongFields.title: DB.stringType,
        SongFields.author: DB.stringType,
        SongFields.path: DB.stringType,
        SongFields.description: DB.stringType,
        SongFields.thumbnail: DB.stringType,
        SongFields.createdAt: DB.stringType,
        SongFields.updatedAt: DB.stringType,
        SongFields.currentDuration: DB.stringType
      });
    };
  });

  static Future<Function(Database db)> onOpen = Future(() {
    return (Database db) async {
      await DB.createTable(db, tableName: 'songs', columns: {
        SongFields.id: DB.idType,
        SongFields.title: DB.stringType,
        SongFields.author: DB.stringType,
        SongFields.path: DB.stringType,
        SongFields.description: DB.stringType,
        SongFields.thumbnail: DB.stringType,
        SongFields.createdAt: DB.stringType,
        SongFields.updatedAt: DB.stringType,
        SongFields.currentDuration: DB.stringType
      });
    };
  });
}
