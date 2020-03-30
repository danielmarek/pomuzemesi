import 'package:flutter/cupertino.dart';

import 'model.dart';
import 'rest_client.dart';

class Data {
  static List<Request> allRequests, acceptedRequests, rejectedRequests, pendingRequests;
  static Volunteer me;
  static VolunteerPreferences preferences;

  static Function _onRequestsUpdate, _onMeUpdate, _onPreferencesUpdate;

  void setListeners(
      {Function onRequestsUpdate,
      Function onMeUpdate,
      Function onPreferencesUpdate}) {
    _onRequestsUpdate = onRequestsUpdate;
    _onMeUpdate = onMeUpdate;
    _onPreferencesUpdate = onPreferencesUpdate;
  }

  static Future<bool> toggleNotifications() async {
    bool current = preferences.notificationsToApp;
    bool newSetting = !current;
    await RestClient.setNotificationsToApp(newSetting);
    await updatePreferences();
    return newSetting;
  }

  static void updateAllAndThen(Function fn) async {
    Future.wait([updateRequests(), updatePreferences(), updateMe()]).then((_){
      if (fn != null) {
        fn();
      }
    });
  }

  static Future<bool> updateRequests() async {
    // States: accepted, rejected, pending_notification

    List<Request> all = await RestClient.getVolunteerRequests();
    List<Request> accepted = List<Request>();
    List<Request> rejected = List<Request>();
    List<Request> pending = List<Request>();
    for (Request r in all){
      //debugPrint('myState: ${r.myState}');
      if (r.myState == 'accepted') {
        accepted.add(r);
      } else if (r.myState == 'rejected') {
        rejected.add(r);
      } else {
        pending.add(r);
      }
    }

    allRequests = all;
    acceptedRequests = accepted;
    pendingRequests = pending;
    rejectedRequests = rejected;

    if (_onRequestsUpdate != null) {
      _onRequestsUpdate();
    }
    return true;
  }

  static Future<bool> updateMe() async {
    Volunteer r = await RestClient.getVolunteerProfile();
    me = r;
    if (_onMeUpdate != null) {
      _onMeUpdate();
    }
    return true;
  }

  static Future<bool> updatePreferences() async {
    VolunteerPreferences r = await RestClient.getVolunteerPreferences();
    preferences = r;
    if (_onPreferencesUpdate != null) {
      _onPreferencesUpdate();
    }
    return true;
  }
}
