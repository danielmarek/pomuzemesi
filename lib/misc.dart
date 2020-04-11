import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pomuzemesi/widget_misc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';

import 'analytics.dart';

// TODO this may want its own mailbox?
String FEEDBACK_MAILBOX = 'info@pomuzeme.si';

//Color PRIMARY_COLOR = Color(0xff64cde3);
Color PRIMARY_COLOR = Color(0xff6ecee1);
Color PRIMARY_COLOR2 = Color(0xff52bbd2);
Color SECONDARY_COLOR = Color(0xffd48d22);
Color SECONDARY_COLOR2 = Color(0xffcf832d);

// Page keys in BottomNavigationBar.
const int HOME_PAGE = 0;
const int REQUESTS_PAGE = 1;
const int PROFILE_PAGE = 2;
const int ABOUT_PAGE = 3;

// Sizes relative to screen width.
double FONT_SIZE_NORMAL = 0.04;
double FONT_SIZE_SMALLER = 0.03;
double LEFT_OF_BUTTON = 0.1;
double LEFT_OF_TEXT_BLOCK = 0.04;

// 10s. Basic time between polls, will exponentially increase on failures.
double STALENESS_LIMIT_MS = 10.0 * 1000;
// If the authToken is expiring in less than 3 days, refresh it.
int REFRESH_TOKEN_BEFORE = 3600 * 24 * 3;

int millisNow() {
  return DateTime.now().toUtc().millisecondsSinceEpoch;
}

void firebaseCloudMessagingSetUpListeners(
    FirebaseMessaging firebaseMessaging,
    {Function (Map<String, dynamic> message) onResume}
    ) {
  if (Platform.isIOS) iosPermission(firebaseMessaging);

  firebaseMessaging.getToken().then((token) {
    print("Firebase token: $token");
  });

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('firebase: onMessage(): $message');
    },
    onResume: onResume,
    onLaunch: (Map<String, dynamic> message) async {
      print('firebase: onLaunch() $message');
    },
  );
}

void iosPermission(FirebaseMessaging firebaseMessaging) {
  firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true));
  firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });
}

int daysFromNow(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
}

void sendEmailTo(BuildContext context, String recipient, String recipientKind) async {
  String url = "mailto:$recipient";
  debugPrint("sendEmailTo, $url");
  bool success = false;
  if (await canLaunch(url)) {
    await launch(url);
    success = true;
  } else {
    showDialogWithText(
        context,
        "Nepodařilo se otevřít e-mailovou aplikaci. Máte ji nainstalovanou a nastavenou?",
        null);
  }
  OurAnalytics.logEvent(
      name: OurAnalytics.OPEN_EMAIL,
      parameters: {
        'success': success,
        'recipient': recipientKind,
      },
  );
}

void sendSmsTo(BuildContext context, String phone, String recipientKind) async {
  String url = "sms:$phone";
  debugPrint("sendSmsTo, $url");
  bool success = false;
  if (await canLaunch(url)) {
    await launch(url);
    success = true;
  } else {
    showDialogWithText(context, "Nepodařilo se otevřít SMS aplikaci.", null);
  }
  OurAnalytics.logEvent(
      name: OurAnalytics.OPEN_SMS,
      parameters: {
        'success': success,
        'recipient': recipientKind,
      }
  );
}

void openPhoneCallTo(BuildContext context, String phone, String recipientKind) async {
  String url = "tel:$phone";
  debugPrint("openPhoneCallTo, $url");
  bool success = false;
  if (await canLaunch(url)) {
    await launch(url);
    success = true;
  } else {
    showDialogWithText(
        context, "Nepodařilo se otevřít telefonní aplikaci.", null);
  }
  OurAnalytics.logEvent(
      name: OurAnalytics.OPEN_PHONECALL,
      parameters: {
        'success': success,
        'recipient': recipientKind,
      }
  );
}
