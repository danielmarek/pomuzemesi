import 'package:flutter/cupertino.dart';
import 'package:pomuzemesi/db.dart';
import 'package:pomuzemesi/misc.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'model.dart';
import 'rest_client.dart';

class Data {
  static String KEY_PREFERENCES = 'PREFERENCES';
  static String KEY_REQUESTS = 'REQUESTS';
  static String KEY_PROFILE = 'PROFILE';
  static String KEY_TOKEN = 'TOKEN';

  static List<Request> allRequests,
      acceptedRequests,
      rejectedRequests,
      pendingRequests;
  static Volunteer me;
  static VolunteerPreferences preferences;
  static int requestsTs, profileTs, preferencesTs;

  static Function _onRequestsUpdate, _onMeUpdate, _onPreferencesUpdate;

  static void setListeners(
      {Function onRequestsUpdate,
      Function onMeUpdate,
      Function onPreferencesUpdate}) {
    _onRequestsUpdate = onRequestsUpdate;
    _onMeUpdate = onMeUpdate;
    _onPreferencesUpdate = onPreferencesUpdate;
  }

  static Future<bool> maybeInitFromDb() async {
    if (allRequests != null && me != null && preferences != null) {
      debugPrint("Got data already, skipping load from DB.");
      return false;
    }
    debugPrint("Will try to initialize records from DB.");
    DbRecord requests = await DbRecords.getRecord(KEY_REQUESTS);
    DbRecord profile = await DbRecords.getRecord(KEY_PROFILE);
    DbRecord prefs = await DbRecords.getRecord(KEY_PREFERENCES);
    if (requests != null) {
      List<Request> all = Request.listFromRawJson(requests.recString);
      allRequests = all;
      partitionRequests();
      requestsTs = requests.timestampMillis;
      debugPrint("Initialized requests from DB.");
    } else {
      // FIXME inform the user.
      allRequests = List<Request>();
    }
    if (profile != null) {
      Volunteer v = Volunteer.fromRawJson(profile.recString);
      me = v;
      profileTs = profile.timestampMillis;
      debugPrint("Initialized profile from DB.");
    } else {
      // FIXME inform the user.
      me = Volunteer();
    }
    if (prefs != null) {
      VolunteerPreferences p =
          VolunteerPreferences.fromRawJson(prefs.recString);
      preferences = p;
      preferencesTs = prefs.timestampMillis;
      debugPrint("Initialized preferences from DB.");
    } else {
      // FIXME inform the user.
      preferences = VolunteerPreferences();
    }
    return true;
  }

  static void toggleNotificationsAndThen(
      {bool setValue, Function(String) then}) async {
    bool newSetting;
    if (setValue == null) {
      bool current = preferences.notificationsToApp;
      newSetting = !current;
    } else {
      newSetting = setValue;
    }
    String err;
    try {
      await RestClient.setNotificationsToApp(newSetting);
      await _fetchPreferences();
    } on APICallException catch (e) {
      if (e.errorKey == APICallException.CONNECTION_FAILED) {
        err = "Nepodařilo se změnit nastavení. Nejste offline?";
      } else {
        err = e.cause;
      }
    }
    if (then != null) {
      then(err);
    }
  }

  static int dataAge() {
    int minTs = min(preferencesTs, min(requestsTs, profileTs));
    return millisNow() - minTs;
  }

  static void maybePollAndThen(double backoff, Function(APICallException) fn) {
    int staleness = dataAge();
    if (staleness > backoff) {
      debugPrint(
          'Polling (staleness=${staleness / 1000.0}s, backoff=${backoff / 1000.0}s)...');
      updateAllAndThen(fn);
    } else {
      debugPrint(
          'Skipping a poll (staleness=${staleness / 1000.0}s, backoff=${backoff / 1000.0}s), too early ...');
    }
  }

  static void updateAllAndThen(Function(APICallException) fn) async {
    APICallException ex;
    try {
      await _fetchRequests();
      await _fetchPreferences();
      await _fetchMe();
    } on APICallException catch (e) {
      debugPrint("updateAllAndThen: ${e.str()}");
      ex = e;
    }
    if (fn != null) {
      fn(ex);
    }
  }

  static void partitionRequests() {
    List<Request> accepted = List<Request>();
    List<Request> rejected = List<Request>();
    List<Request> pending = List<Request>();
    for (Request r in allRequests.reversed) {
      //debugPrint('myState: ${r.myState}');
      if (r.myState == 'accepted') {
        accepted.add(r);
      } else if (r.myState == 'rejected') {
        rejected.add(r);
      } else {
        pending.add(r);
      }
    }

    acceptedRequests = accepted;
    pendingRequests = pending;
    rejectedRequests = rejected;
  }

  static Future<bool> _fetchRequests() async {
    // States: accepted, rejected, pending_notification

    try {
      String body = await RestClient.getVolunteerRequests();
      List<Request> all = Request.listFromRawJson(body);
      requestsTs = millisNow();
      DbRecords.saveString(key: KEY_REQUESTS, value: body, ts: requestsTs);
      allRequests = all;
      partitionRequests();
    } on APICallException catch (e) {
      debugPrint("ERROR _fetchRequests: ${e.str()}");
      throw e;
    }

    if (_onRequestsUpdate != null) {
      _onRequestsUpdate();
    }
    return true;
  }

  static Future<bool> _fetchMe() async {
    try {
      String body = await RestClient.getVolunteerProfile();
      Volunteer r = Volunteer.fromRawJson(body);
      profileTs = millisNow();
      DbRecords.saveString(key: KEY_PROFILE, value: body, ts: profileTs);
      me = r;
    } on APICallException catch (e) {
      debugPrint("ERROR _fetchMe: ${e.str()}");
      throw e;
    }
    if (_onMeUpdate != null) {
      _onMeUpdate();
    }
    return true;
  }

  static Future<bool> _fetchPreferences() async {
    try {
      String body = await RestClient.getVolunteerPreferences();
      VolunteerPreferences r = VolunteerPreferences.fromRawJson(body);
      preferencesTs = millisNow();
      DbRecords.saveString(
          key: KEY_PREFERENCES, value: body, ts: preferencesTs);
      preferences = r;
    } on APICallException catch (e) {
      debugPrint("ERROR _fetchPreferences: ${e.str()}");
      throw e;
    }
    if (_onPreferencesUpdate != null) {
      _onPreferencesUpdate();
    }
    return true;
  }

  static String lastUpdatePretty() {
    if (requestsTs == null || profileTs == null || preferencesTs == null) {
      return 'neznámá';
    }
    int minTs = min(requestsTs, min(profileTs, preferencesTs));
    var lastFullUpdate = DateTime.fromMillisecondsSinceEpoch(minTs);
    if (daysFromNow(lastFullUpdate) == 0) {
      return DateFormat('HH:mm:ss').format(lastFullUpdate.toLocal());
    } else {
      return DateFormat('M.d.').format(lastFullUpdate.toLocal());
    }
  }
}

class TokenWrapper {
  static String token;
  static int BACKOFF_SECONDS = 3600;
  static int tsLastTimeTriedToRefresh = 0;

  // Returns null if not set.
  static Future<String> getToken() async {
    DbRecord r = await DbRecords.getRecord(Data.KEY_TOKEN);
    if (r == null) {
      return null;
    }
    return r.recString;
  }

  static void saveToken(String t) {
    token = t;
    setToken(t);
  }

  static Future<bool> load() async {
    token = await getToken();
    return true;
  }

  static Future<bool> setToken(String t) async {
    token = t;
    await DbRecords.saveString(key: Data.KEY_TOKEN, value: t, ts: millisNow());
    return true;
  }

  static int tokenValidSeconds(String token) {
    // {"volunteer_id":2,"exp":1588332040}
    try {
      final parts = token.split('.');
      final payload = parts[1];
      final String decodedToken = B64urlEncRfc7515.decodeUtf8(payload);
      debugPrint("TOKEN: $decodedToken");
      var r = json.decode(decodedToken);
      int expiration = r['exp'];
      int secondsNow = (millisNow() / 1000.0).toInt();
      return expiration - secondsNow;
    } catch (e) {
      debugPrint("Failed to parse token: ${e.toString()}");
    }
    return null;
  }

  static void maybeTryToRefresh() async {
    int secondsNow = (millisNow() / 1000.0).toInt();
    int secondsSinceLastAttempt = secondsNow - tsLastTimeTriedToRefresh;
    debugPrint(
        "secondsSinceLastAttempt: $secondsSinceLastAttempt, BACKOFF_SECONDS: $BACKOFF_SECONDS");
    if (secondsSinceLastAttempt < BACKOFF_SECONDS) {
      debugPrint(
          "Will not try to refresh now, too early, will try in ${BACKOFF_SECONDS - secondsSinceLastAttempt} seconds.");
      return;
    }
    debugPrint("WILL TRY TO REFRESH TOKEN");
    tsLastTimeTriedToRefresh = secondsNow;
    String t = await RestClient.refreshToken();
    saveToken(t);
  }
}
