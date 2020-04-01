import 'package:flutter/cupertino.dart';
import 'package:pomuzemesi/db.dart';
import 'package:pomuzemesi/misc.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'dart:math';

import 'model.dart';
import 'rest_client.dart';

class Data {
  static int KEY_PREFERENCES = 0;
  static int KEY_REQUESTS = 1;
  static int KEY_PROFILE = 2;

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

  static void toggleNotificationsAndThen(Function(String) fn) async {
    bool current = preferences.notificationsToApp;
    bool newSetting = !current;
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
    if (fn != null) {
      fn(err);
    }
  }

  static int dataAge() {
    int minTs = min(preferencesTs, min(requestsTs, profileTs));
    return millisNow() - minTs;
  }

  static void maybePollAndThen(double backoff, Function(APICallException) fn) {
    int staleness = dataAge();
    if (staleness > backoff) {
      debugPrint('Polling (staleness=${staleness / 1000.0}s, backoff=${backoff/1000.0}s)...');
      updateAllAndThen(fn);
    } else {
      debugPrint('Skipping a poll (staleness=${staleness / 1000.0}s, backoff=${backoff/1000.0}s), too early ...');
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
    for (Request r in allRequests) {
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
