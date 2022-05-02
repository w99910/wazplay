import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wazplay/support/eloquents/song.dart';
import 'package:wazplay/support/models/song.dart';

class DB {
  static const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const boolType = 'BOOLEAN NOT NULL';
  static const integerType = 'INTEGER NOT NULL';
  static const stringType = 'TEXT NOT NULL';

  final String fileName = 'wazplay-0.0.3.db';

  static final DB instance = DB._init();

  DB._init();

  static Database? _database;

  Future<Database> get database async => await getDB();

  Future<Database> getDB() async {
    if (_database != null) return _database!;
    _database = await _initDB(fileName: fileName);
    return _database!;
  }

  Future<void> reinitialiseDB() async {
    _database = await _initDB(fileName: fileName);
  }

  static Future createTable(Database db,
      {required String tableName, required Map<String, String> columns}) async {
    var string = '';
    columns.forEach((key, value) {
      string += '$key $value';
      if (key != columns.entries.last.key) {
        string += ',';
      }
    });
    await db.execute('CREATE TABLE IF NOT EXISTS $tableName (' + string + ' )');
  }

  Future<Database> _initDB({required String fileName}) async {
    final dbPath = Platform.isAndroid
        ? await getDatabasesPath()
        : (await getApplicationDocumentsDirectory()).toString();
    final path = join(dbPath + fileName);
    if (!await Directory(dirname(path)).exists()) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        // print(e);
      }
    }
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await SongEloquent.onCreate(db, version);
    }, onOpen: (Database db) async {
      await SongEloquent.onOpen(db);
    });
  }
}
