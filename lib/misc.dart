import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';


Color PRIMARY_COLOR = Color(0xff64cde3);
Color SECONDARY_COLOR = Color(0xffd48d22);

// Page keys in BottomNavigationBar.
final int HOME_PAGE = 0;
int TASKS_PAGE = 1;
int SETTINGS_PAGE = 2;
int PRIVACY_POLICY_PAGE = 3;

void firebaseCloudMessagingSetUpListeners(FirebaseMessaging firebaseMessaging) {
  if (Platform.isIOS) iosPermission(firebaseMessaging);

  firebaseMessaging.getToken().then((token){
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
      IosNotificationSettings(sound: true, badge: true, alert: true)
  );
  firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings)
  {
    print("Settings registered: $settings");
  });
}