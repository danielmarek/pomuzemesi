import 'package:flutter/cupertino.dart';
import 'package:pomuzemesi/db.dart';
import 'package:pomuzemesi/misc.dart';

import 'dart:io';

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
      // Unauthorized resource.
      if (e.errorCode == 401) {
        // TODO deal with this plus upgrade required.
        debugPrint("blockingFetchAll: 401");
        err = "Nemáte autorizaci.";
      } else {
        // TODO other errors.
        err = "Other error.";
      }
    } on SocketException catch (_) {
      // TODO deal with this in the UI.
      debugPrint("Failed to connect to server");
      err = "Nepodařilo se změnit nastavení. Nejste offline?";
    } catch (e) {
      err = 'Chyba při odesílání požadavku: ${e.toString()}';
    }
    if (fn != null) {
      fn(err);
    }
  }

  static void maybePoll(Function fn) {
    int STALENESS_LIMIT = 10 * 1000;
    int now = millisNow();
    if (now - preferencesTs > STALENESS_LIMIT || now - requestsTs > STALENESS_LIMIT || now - profileTs > STALENESS_LIMIT) {
      debugPrint('Polling ...');
      updateAllAndThen(fn);
    } else {
      debugPrint('Skipping a poll, too early ...');
    }
  }

  static void updateAllAndThen(Function fn) async {
    try {
      await _fetchRequests();
      await _fetchPreferences();
      await _fetchMe();
    } on APICallException catch (e) {
      // Unauthorized resource.
      if (e.errorCode == 401) {
        // TODO deal with this plus upgrade required.
        debugPrint("blockingFetchAll: 401");
        /*homePageState = HomePageState.enterPhone;
        controllerSMS.text = '';
        await SharedPrefs.removeToken();
        setState(() {});
        return true;*/
      } else {
        // TODO other errors.
      }
    } on SocketException catch (_) {
      // TODO deal with this in the UI.
      debugPrint("Failed to connect to server");
      // This will preload data from the DB instead.
      //setStateReady();
    }
    if (fn != null) {
      fn();
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
    } catch (e) {
      debugPrint("ERROR _fetchRequests: ${e.toString()}");
      return false;
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
    } catch (e) {
      debugPrint("ERROR _fetchMe: ${e.toString()}");
      return false;
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
    } catch (e) {
      debugPrint("ERROR _fetchPreferences: ${e.toString()}");
      return false;
    }
    if (_onPreferencesUpdate != null) {
      _onPreferencesUpdate();
    }
    return true;
  }
}
