import 'model.dart';
import 'rest_client.dart';

class Data {
  static List<Request> allRequests, myRequests, otherRequests;
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
/*
  void updateAllAndThen(Function fn) async {
    Future.wait([updateRequests(), updatePreferences(), updateMe()]).then((_){
      if (fn != null) {
        fn();
      }
    });
  }
*/
  static Future<bool> updateRequests() async {
    List<Request> all = await RestClient.getVolunteerRequests();
    List<Request> my = List<Request>();
    List<Request> other = List<Request>();
    for (Request r in all){
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
