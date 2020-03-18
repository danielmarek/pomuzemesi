import 'package:flutter/material.dart';

import 'data.dart';
import 'model.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Privacy policy will be here.",
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
