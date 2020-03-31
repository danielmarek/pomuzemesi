import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String DB_FILENAME = "pomuzemesi.db";

final Future<Database> _database = DbRecords.openDb();

final initialScript = '''
  CREATE TABLE DbRecord (
    recName INTEGER PRIMARY KEY,
    recInt INTEGER,
    recString TEXT,
    timestampMillis INTEGER
    )
    ''';

class DbRecord {
  final int recName;
  final int recInt;
  final String recString;
  final int timestampMillis;

  DbRecord({this.recName, this.recInt, this.recString, this.timestampMillis});

  Map<String, dynamic> toMap() {
    return {
      "recName": recName,
      "recInt": recInt,
      "recString": recString,
      "timestampMillis": timestampMillis,
    };
  }
}

class DbRecords {
  static Future<Database> openDb() async {
    debugPrint("DB: Will open the database.");
    String dbPath = await getDatabasesPath();
    String actualPath = join(dbPath, DB_FILENAME);
    Database d = await openDatabase(actualPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(initialScript);
    });
    int version = await d.getVersion();
    debugPrint("DB: database opened with version $version");
    return d;
  }

  static Future<bool> saveInt(
      {@required int key, @required int value, @required int ts}) async {
    Database db = await _database;
    DbRecord r = DbRecord(recName: key, recInt: value, timestampMillis: ts);
    db.insert('DbRecord', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint("saved DbRecord: ${r.toMap().toString()}");
    return true;
  }

  static Future<bool> saveString(
      {@required int key, @required String value, @required int ts}) async {
    DbRecord r = DbRecord(recName: key, recString: value, timestampMillis: ts);
    Database db = await _database;
    db.insert('DbRecord', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint("saved DbRecord: ${r.toMap().toString()}");
    return true;
  }

  static Future<DbRecord> getRecord(int key) async {
    Database db = await _database;
    List<Map> data = await db.rawQuery(
        "SELECT DbRecord.recInt AS intv, DbRecord.recString AS strv, DbRecord.timestampMillis AS ts"
        " FROM DbRecord WHERE DbRecord.recName='$key'");
    if (data.length > 0) {
      return DbRecord(
        recName: key,
        recInt: data[0]['intv'],
        recString: data[0]['strv'],
        timestampMillis: data[0]['ts'],
      );
    } else {
      return null;
    }
  }

  /*
  static Future<int> getInt(String key) async {
    Database db = await _database;
    List<Map> data = await db.rawQuery(
        "SELECT DbRecord.recInt AS v FROM DbRecord WHERE DbRecord.recName='$key'");
    if (data.length > 0) {
      return data[0]['v'];
    } else {
      return null;
    }
  }

  static Future<String> getString(String key) async {
    Database db = await _database;
    List<Map> data = await db.rawQuery(
        "SELECT DbRecord.recString AS v FROM DbRecord WHERE DbRecord.recName='$key'");
    if (data.length > 0) {
      return data[0]['v'];
    } else {
      return null;
    }
  }*/

  // Just a debug function to see the DbRecords in the database.
  // Won't print more than 5 results to not spam the log.
  static void debugPrintAllResults() async {
    Database db = await _database;
    final List<Map<String, dynamic>> m = await db.query('DbRecord');
    debugPrint("DB: # DbRecords: ${m.length}");
    for (int i = m.length - 1; i >= 0 && i >= m.length - 5; i--) {
      debugPrint("DB: DbRecord #$i: ${m[i].toString()}");
    }
  }

  static Future<bool> deleteAll() async {
    Database db = await _database;
    await db.rawQuery("DELETE FROM DbRecord");
    return true;
  }
}
