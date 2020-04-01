import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DbRecord {
  final String recName;
  final String recString;
  final int timestampMillis;

  DbRecord({this.recName, this.recString, this.timestampMillis});

  Map<String, dynamic> toMap() {
    return {
      "recName": recName,
      "recString": recString,
      "timestampMillis": timestampMillis,
    };
  }
}

class DbRecords {
  static FlutterSecureStorage storage = new FlutterSecureStorage();

  static Future<bool> saveString(
      {@required String key, @required String value, @required int ts}) async {
    await storage.write(key: "$key", value: value);
    await storage.write(key: "TS_$key", value: ts.toString());
    debugPrint("saved DbRecord: $key");
    return true;
  }

  static Future<DbRecord> getRecord(String key) async {
    String value = await storage.read(key: key);
    String ts = await storage.read(key: "TS_$key");
    if (value == null) {
      return null;
    }
    return DbRecord(
      recName: key,
      recString: value,
      timestampMillis: (ts != null && ts != '') ? int.parse(ts) : null,
    );
  }

  static Future<bool> deleteAll() async {
    await storage.deleteAll();
    return true;
  }
}
