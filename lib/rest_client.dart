import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pomuzemesi/data.dart';
import 'dart:convert';
import 'dart:io';

import 'model.dart';

// TODO distinguish between different non-200s

class APICallException implements Exception {
  static String UNAUTHORIZED = 'UNAUTHORIZED';
  static String UNKNOWN = 'UNKNOWN';
  static String CONNECTION_FAILED = 'CONNECTION_FAILED';
  static String PARSING_ERROR = 'PARSING_ERROR';
  static String UPGRADE_REQUIRED = 'UPGRADE_REQUIRED';

  // HTTP code, e.g. 409.
  final int errorCode;

  // Human-readable description.
  final String cause;

  // e.g. REQUEST_CAPACITY_EXCEEDED
  final String errorKey;

  // 409 {"error_key":"REQUEST_CAPACITY_EXCEEDED","message":null}

  APICallException({this.errorCode, this.cause, this.errorKey});

  String str() {
    return "$errorKey($errorCode): $cause";
  }
}

class RestClient {
  //static String BASE_URL = "https://pomuzeme-si-mobile-api.herokuapp.com";
  static String BASE_URL = "https://staging.pomuzeme.si";

  //static String token;
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

  static Map<String, String> authHeaders() {
    return {'Authorization': 'Bearer ${TokenWrapper.token}'};
  }

  static Future<String> _call(
      {@required Function fn,
      @required String url,
      Map<String, String> headers}) async {
    http.Response response;
    try {
      debugPrint("calling $url ...");
      response = await fn("$BASE_URL/$url", headers: headers);
      debugPrint("response code: ${response.statusCode}");
      debugPrint("response headers:\n${response.headers}");
      debugPrint("response body:\n${response.body}");
    } on SocketException catch (_) {
      throw APICallException(
          errorCode: -1,
          errorKey: APICallException.CONNECTION_FAILED,
          cause: 'Nepodařilo se připojit k serveru, nejste offline?');
    } catch (e) {
      throw APICallException(
          errorCode: -2,
          errorKey: APICallException.UNKNOWN,
          cause: 'Neznámá chyba při komunikaci se serverem.');
    }

    if (response.statusCode == 200) {
      return response.body;
    } else {
      if (response.statusCode == 401) {
        throw APICallException(
            errorCode: response.statusCode,
            errorKey: APICallException.UNAUTHORIZED,
            cause: 'Nemáte oprávnění.');
      } else if (response.statusCode == 426) {
        throw APICallException(
            errorCode: response.statusCode,
            errorKey: APICallException.UPGRADE_REQUIRED,
            cause: 'Je třeba aktualizovat aplikaci.');
      }

      String errorKey, msg;
      try {
        var r = json.decode(response.body);
        errorKey = r.containsKey('error_key') ? r['error_key'] : null;
        msg = r.containsKey('message') ? r['message'] : null;
      } catch (_) {
        debugPrint("Failed to parse error: ${response.body}");
      }

      throw APICallException(
          errorCode: response.statusCode,
          errorKey: (errorKey != null && errorKey != '')
              ? errorKey
              : APICallException.UNKNOWN,
          cause: (msg != null && msg != '')
              ? msg
              : 'Neznámá chyba při komunikaci se serverem (${response.statusCode}).');
    }
  }

  static Future<bool> sessionNew(
      String phone, String reCaptcha, String fcmToken) async {
    String body = await _call(
      fn: httpClient.post,
      url:
          'api/v1/session/new?phone_number=$phone&recaptcha_token=$reCaptcha&fcm_token=$fcmToken',
    );
    return true;
  }

  static Future<String> sessionCreate(String phone, String code) async {
    String body = await _call(
      fn: httpClient.post,
      url:
          'api/v1/session/create?phone_number=$phone&sms_verification_code=$code',
    );
    try {
      var r = json.decode(body);
      return r['token'];
    } catch (_) {
      throw APICallException(
        errorCode: -3,
        errorKey: APICallException.PARSING_ERROR,
        cause: 'Nepodařilo se zpracovat odpověď od serveru.',
      );
    }
  }

  static Future<String> refreshToken() async {
    String body = await _call(
      fn: httpClient.post,
      url: 'api/v1/session/refresh',
      headers: authHeaders(),
    );
    try {
      var r = json.decode(body);
      return r['token'];
    } catch (_) {
      throw APICallException(
        errorCode: -3,
        errorKey: APICallException.PARSING_ERROR,
        cause: 'Nepodařilo se zpracovat odpověď od serveru.',
      );
    }
  }

  static Future<String> getVolunteerPreferences() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/volunteer/preferences',
      headers: authHeaders(),
    );
    return body;
  }

  static Future<String> getVolunteerProfile() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/volunteer/profile',
      headers: authHeaders(),
    );
    return body;
  }

  static Future<bool> setNotificationsToApp(bool sendNotificationsToApp) async {
    String value = sendNotificationsToApp ? 'true' : 'false';
    String body = await _call(
      fn: httpClient.put,
      url: 'api/v1/volunteer/preferences?notifications_to_app=$value',
      headers: authHeaders(),
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
      headers: authHeaders(),
    );
    return body;
  }

  static Future<bool> respondToRequest(int id, bool accept) async {
    String acceptStr = accept ? 'true' : 'false';
    String body = await _call(
      fn: httpClient.post,
      url: 'api/v1/volunteer/requests/$id/respond?accept=$acceptStr',
      headers: authHeaders(),
    );
    return true;
  }

  static Future<List<Organisation>> getMyOrganisations() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/volunteer/organisations',
      headers: authHeaders(),
    );
    try {
      return Organisation.listFromRawJson(body);
    } catch (_) {
      throw APICallException(
        errorCode: -4,
        errorKey: APICallException.PARSING_ERROR,
        cause: 'Nepodařilo se zpracovat odpověď od serveru.',
      );
    }
  }

  static Future<List<Organisation>> getAllOrganisations() async {
    String body = await _call(
      fn: httpClient.get,
      url: 'api/v1/organisations',
      headers: authHeaders(),
    );
    try {
      return Organisation.listFromRawJson(body);
    } catch (_) {
      throw APICallException(
        errorCode: -5,
        errorKey: APICallException.PARSING_ERROR,
        cause: 'Nepodařilo se zpracovat odpověď od serveru.',
      );
    }
  }
}
