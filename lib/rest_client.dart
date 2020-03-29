import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'model2.dart';

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

  static String BASE_URL = "https://pomuzeme-si-mobile-api.herokuapp.com/";
  static String token;  //= "eyJhbGciOiJIUzI1NiJ9.eyJ2b2x1bnRlZXJfaWQiOjIsImV4cCI6MTU4NzgyODAyOX0.5BswxsB-Ef4i-krQMkt3mBrXg6TcZb4SiF3LHAlWXFY";
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

  static Future<bool> sessionNew(String phone, String reCaptcha, String fcmToken) async {
    String url = BASE_URL +
        'api/v1/session/new?phone_number=$phone&recaptcha_token=$reCaptcha&fcm_token=$fcmToken';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.post(url);
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    return true;
  }

  static Future<String> sessionCreate(String phone, String code) async {
    String url = BASE_URL +
        'api/v1/session/create?phone_number=$phone&sms_verification_code=$code';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.post(url);
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    var r = json.decode(response.body);
    return r['token'];
  }

  static Future<Preferences2> getVolunteerPreferences() async {
    String url = BASE_URL + '/api/v1/volunteer/preferences';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    if (response.statusCode == 200) {
      return Preferences2.fromRawJson(response.body);
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<Volunteer2> getVolunteerProfile() async {
    String url = BASE_URL + '/api/v1/volunteer/profile';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    if (response.statusCode == 200) {
      return Volunteer2.fromRawJson(response.body);
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static void setNotificationsToApp(bool sendNotificationsToApp) async {
    String value = sendNotificationsToApp ? 'true' : 'false';
    String url = BASE_URL + '/api/v1/volunteer/preferences?notifications_to_app=$value';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.put(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
  }

  static Future<List<Request2>> getVolunteerRequests() async {
    String url = BASE_URL + '/api/v1/volunteer/requests';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");

    if (response.statusCode == 200) {
      List<Request2> requests = Request2.listFromRawJson(response.body);
      return requests;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<bool> respondToRequest(int id, bool accept) async {
    String acceptStr = accept ? 'true' : 'false';
    //http.Client httpClient = new http.Client();
    String url = BASE_URL + '/api/v1/volunteer/requests/$id/respond?accept=$acceptStr';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }
}