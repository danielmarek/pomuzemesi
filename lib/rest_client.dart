import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'model.dart';

// TODO distinguish between different non-200s

class APICallException implements Exception {
  final String cause;
  final int errorCode;

  APICallException(this.errorCode, this.cause);

  String errorMessage() {
    return 'API call failed: $errorCode: $cause';
  }
}

class RestClient {
  static String BASE_URL = "https://pomuzeme-si-mobile-api.herokuapp.com";
  static String token;
  static http.Client httpClient = new http.Client();

/*
  static void getRecaptchaCode() async {
    http.Client httpClient = new http.Client();
    String url = BASE_URL + '/api/v1/recaptcha_code';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.get(url);
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
  }*/

  static Future<String> _call({@required Function fn, @required String url, Map<String, String> headers}) async {
    http.Response response;
    try {
      debugPrint("calling $url ...");
      response = await fn("$BASE_URL/$url", headers: headers);
      debugPrint("response code: ${response.statusCode}");
      debugPrint("response headers:\n${response.headers}");
      debugPrint("response body:\n${response.body}");
    } catch (e) {

    }

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<bool> sessionNew(
      String phone, String reCaptcha, String fcmToken) async {
    String body = await _call(
      fn: httpClient.post,
      url: 'api/v1/session/new?phone_number=$phone&recaptcha_token=$reCaptcha&fcm_token=$fcmToken',
    );
    return true;
  }

  static Future<String> sessionCreate(String phone, String code) async {
    String body = await _call(
      fn: httpClient.post,
      url: 'api/v1/session/create?phone_number=$phone&sms_verification_code=$code',
    );
    var r = json.decode(body);
    return r['token'];
  }

  static Future<String> getVolunteerPreferences() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/volunteer/preferences',
        headers: {'Authorization': 'Bearer $token'},
    );
    return body;
  }

  static Future<String> getVolunteerProfile() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/volunteer/profile',
        headers: {'Authorization': 'Bearer $token'},
    );
    return body;
  }

  static Future<bool> setNotificationsToApp(bool sendNotificationsToApp) async {
    String value = sendNotificationsToApp ? 'true' : 'false';
    String body = await _call(
        fn: httpClient.put,
        url: 'api/v1/volunteer/preferences?notifications_to_app=$value',
        headers: {'Authorization': 'Bearer $token'},
    );
    return true;
  }

  static Future<String> getVolunteerRequests() async {
    // FIXME
    /*
    E/flutter (13827): [ERROR:flutter/lib/ui/ui_dart_state.cc(157)] Unhandled Exception: Connection closed before full header was received
     */

    String body = await _call(
        fn: httpClient.get,
        url: 'api/v1/volunteer/requests',
      headers: {'Authorization': 'Bearer $token'},
    );
    return body;
  }

  static Future<bool> respondToRequest(int id, bool accept) async {
    String acceptStr = accept ? 'true' : 'false';
    String body = await _call(
      fn: httpClient.post,
      url: 'api/v1/volunteer/requests/$id/respond?accept=$acceptStr',
      headers: {'Authorization': 'Bearer $token'},
    );
    return true;
  }

  static Future<List<Organisation>> getMyOrganisations() async {
    String body = await _call(
        fn: httpClient.get,
        url: 'api/v1/volunteer/organisations',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Organisation.listFromRawJson(body);
  }

  static Future<List<Organisation>> getAllOrganisations() async {
    String body = await _call(
        fn: httpClient.get,
        url: 'api/v1/organisations',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Organisation.listFromRawJson(body);
  }
}
