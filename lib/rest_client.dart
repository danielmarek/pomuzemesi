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

  static String BASE_URL = "https://pomuzeme-si-mobile-api.herokuapp.com/";
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

  static Future<bool> sessionNew(String phone, String reCaptcha, String fcmToken) async {
    String url = BASE_URL +
        'api/v1/session/new?phone_number=$phone&recaptcha_token=$reCaptcha&fcm_token=$fcmToken';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.post(url);
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    if (response.statusCode == 200) {
      return true;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<String> sessionCreate(String phone, String code) async {
    String url = BASE_URL +
        'api/v1/session/create?phone_number=$phone&sms_verification_code=$code';
    debugPrint("calling $url ...");
    http.Response response = await httpClient.post(url);
    debugPrint("response code: ${response.statusCode}");
    debugPrint("response headers:\n${response.headers}");
    debugPrint("response body:\n${response.body}");
    if (response.statusCode == 200) {
      var r = json.decode(response.body);
      return r['token'];
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<VolunteerPreferences> getVolunteerPreferences() async {
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
      return VolunteerPreferences.fromRawJson(response.body);
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<Volunteer> getVolunteerProfile() async {
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
      return Volunteer.fromRawJson(response.body);
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  Future<bool> setNotificationsToApp(bool sendNotificationsToApp) async {
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
    if (response.statusCode == 200) {
      return true;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<List<Request>> getVolunteerRequests() async {
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
      List<Request> requests = Request.listFromRawJson(response.body);
      return requests;
    } else {
      throw APICallException(response.statusCode, response.body);
    }
  }

  static Future<bool> respondToRequest(int id, bool accept) async {
    String acceptStr = accept ? 'true' : 'false';
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