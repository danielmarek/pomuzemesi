import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

String ROUTE_HOME = '';
String ROUTE_NEW_REQUESTS = 'requests';
String ROUTE_PROFILE = 'profile';
String ROUTE_ABOUT = 'about';

List<String> ROUTES = [ROUTE_HOME, ROUTE_NEW_REQUESTS, ROUTE_PROFILE, ROUTE_ABOUT];

String EVENT_ACCEPT_REQUEST = 'accept_request';
String EVENT_DECLINE_REQUEST = 'decline_request';


class OurAnalytics {
  static FirebaseAnalytics instance;

  // Event types.
  static String ACCEPT_REQUEST = 'accept_request';
  static String DECLINE_REQUEST = 'decline_request';
  static String OPEN_MAPS = 'open_maps';
  static String OPEN_SMS = 'open_sms';
  static String OPEN_PHONECALL = 'open_phonecall';
  static String OPEN_EMAIL = 'open_email';
  static String MANUAL_REFRESH = 'manual_refresh';
  static String SUBMIT_PHONE_NUMBER = 'submit_phone_number';
  static String SUBMIT_SMS_CODE = 'submit_sms_code';
  static String RESEND_SMS_CODE = 'resend_sms_code';
  static String TOGGLE_NOTIFICATIONS = 'toggle_notifications';
  static String TOKEN_REFRESH = 'token_refresh';
  static String I_HAVE_REGISTRATION = 'i_have_registration';

  // Recipient types for OPEN_* events (for sms, phonecalls and emails).
  static String RECIPIENT_SUBSCRIBER = 'subscriber';
  static String RECIPIENT_DEVELOPER = 'developer';
  static String RECIPIENT_COORDINATOR = 'coordinator';


  static Future<void> logEvent(
      {@required String name, Map<String, dynamic> parameters}) async {
    debugPrint("Analytics: event: name='$name' parameters=$parameters");
    await instance.logEvent(name: name, parameters: parameters);
  }
}