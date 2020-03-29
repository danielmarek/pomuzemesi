import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';

import 'package:http/http.dart' as http;

//import 'package:recaptchav2_plugin/recaptchav2_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'rest_client.dart';

// https://pomuzeme-si-mobile-api.herokuapp.com/

// TODO profile model
// TODO request model

class ApiPage extends StatefulWidget {
  ApiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  @override
  Widget build(BuildContext context) {
    //String verifyResult = "res";
    String phone = '723914553';
    String reCaptcha = 'test1234';
    String fcmToken = "eo7gDuJwEs0:APA91bFN9-bWIrN9nyGxI-SzTzU2Mf2nEIJUayvPqPxY4tHFSI8Zwd2Cle-3NJ-ctqYNv4sRDa9fBch25FyY07fHbVmD9tcBn7afPKyJA_deAcn_PLTpwPcIZYhS64qM2qmsO9IXhLy3";
    String token = "eyJhbGciOiJIUzI1NiJ9.eyJ2b2x1bnRlZXJfaWQiOjIsImV4cCI6MTU4NzgyODAyOX0.5BswxsB-Ef4i-krQMkt3mBrXg6TcZb4SiF3LHAlWXFY";
    String code = '8380';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("ask for sms"),
              onPressed: () {
                RestClient.sessionNew(phone, reCaptcha, fcmToken);
              },
            ),
            RaisedButton(
              child: Text("ask for token"),
              onPressed: () {
                RestClient.sessionCreate(phone, code);
              },
            ),
            RaisedButton(
              child: Text("take request"),
              onPressed: () {
                RestClient.respondToRequest(1, true);
              },
            ),
            RaisedButton(
              child: Text("reject request"),
              onPressed: () {
                RestClient.respondToRequest(1, false);
              },
            ),
            RaisedButton(
              child: Text("receive notifications to app"),
              onPressed: () {
                RestClient.setNotificationsToApp(true);
              },
            ),
            RaisedButton(
              child: Text("receive notifications by sms"),
              onPressed: () {
                RestClient.setNotificationsToApp(false);
              },
            ),
            RaisedButton(
              child: Text("get preferences"),
              onPressed: () {
                RestClient.getVolunteerPreferences();
              },
            ),
            RaisedButton(
              child: Text("get profile"),
              onPressed: () {
                RestClient.getVolunteerProfile();
              },
            ),
            RaisedButton(
              child: Text("get requests"),
              onPressed: () {
                RestClient.getVolunteerRequests();
              },
            ),
          ])
      ),
      //bottomNavigationBar: bottomNavBar(context, SETTINGS_PAGE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        tooltip: 'Help',
        child: Icon(Icons.help_outline),
      ),
    );
  }
}
