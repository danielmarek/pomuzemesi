import 'dart:math';
import 'model2.dart';

//import 'testdata.dart';
import 'rest_client.dart';

class Data2 {
  static List<Request2> allRequests, myRequests, otherRequests;
  static Volunteer2 me;
  static Preferences2 preferences;

  static Function _onRequestsUpdate, _onMeUpdate, _onPreferencesUpdate;

  void setListeners(
      {Function onRequestsUpdate,
      Function onMeUpdate,
      Function onPreferencesUpdate}) {
    _onRequestsUpdate = onRequestsUpdate;
    _onMeUpdate = onMeUpdate;
    _onPreferencesUpdate = onPreferencesUpdate;
  }

  static Future<bool> updateRequests() async {
    List<Request2> all = await RestClient.getVolunteerRequests();
    List<Request2> my = List<Request2>();
    List<Request2> other = List<Request2>();
    for (Request2 r in all){
      if (r.myState == 'accepted') {
        my.add(r);
      } else {
        other.add(r);
      }
    }

    allRequests = all;
    myRequests = my;
    otherRequests = other;

    if (_onRequestsUpdate != null) {
      _onRequestsUpdate();
    }
    return true;
  }

  static Future<bool> updateMe() async {
    Volunteer2 r = await RestClient.getVolunteerProfile();
    me = r;
    if (_onMeUpdate != null) {
      _onMeUpdate();
    }
    return true;
  }

  static Future<bool> updatePreferences() async {
    Preferences2 r = await RestClient.getVolunteerPreferences();
    preferences = r;
    if (_onPreferencesUpdate != null) {
      _onPreferencesUpdate();
    }
    return true;
  }
}
