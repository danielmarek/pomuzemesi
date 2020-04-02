import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

// TODO create an actual mailbox
String FEEDBACK_MAILBOX = 'test@example.com';

//Color PRIMARY_COLOR = Color(0xff64cde3);
Color PRIMARY_COLOR = Color(0xff6ecee1);
Color PRIMARY_COLOR2 = Color(0xff52bbd2);
Color SECONDARY_COLOR = Color(0xffd48d22);
Color SECONDARY_COLOR2 = Color(0xffcf832d);

// Page keys in BottomNavigationBar.
const int HOME_PAGE = 0;
const int TASKS_PAGE = 1;
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

void firebaseCloudMessagingSetUpListeners(FirebaseMessaging firebaseMessaging) {
  if (Platform.isIOS) iosPermission(firebaseMessaging);

  firebaseMessaging.getToken().then((token) {
    print("Firebase token: $token");
  });

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print('firebase: onMessage(): $message');
    },
    onResume: (Map<String, dynamic> message) async {
      print('firebase: onResume(): $message');
    },
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
