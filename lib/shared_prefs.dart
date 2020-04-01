import 'package:pomuzemesi/misc.dart';

import 'db.dart';
import 'data.dart';

class SharedPrefs {

  // Returns null if not set.
  static Future<String> getToken() async {
    DbRecord r = await DbRecords.getRecord(Data.KEY_TOKEN);
    if (r == null) {
      return null;
    }
    return r.recString;
  }

  static Future<bool> setToken(String token) async {
    await DbRecords.saveString(key: Data.KEY_TOKEN, value: token, ts: millisNow());
    return true;
  }

  static Future<bool> removeToken() async {
    await DbRecords.saveString(key: Data.KEY_TOKEN, value: null, ts: millisNow());
    return true;
  }
}
