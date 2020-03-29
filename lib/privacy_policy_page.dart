import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';

import 'widget_misc.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
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
            style: TextStyle(fontSize: screenWidth * FONT_SIZE_SMALLER),
          ),
        ],
      ),
      //bottomNavigationBar: bottomNavBar(context, PRIVACY_POLICY_PAGE),
    );
  }
}
