import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';
//import 'package:recaptchav2_plugin/recaptchav2_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'recaptchav2_plugin.dart';


class CaptchaPage extends StatefulWidget {
  CaptchaPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CaptchaPageState createState() => _CaptchaPageState();
}

class _CaptchaPageState extends State<CaptchaPage> {
  @override
  Widget build(BuildContext context) {
    String verifyResult = "res";

    RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();
    //String skillsStr =
     //   Data.me.skillIDs.map((sid) => SKILLS[sid].name).toList().join(", ");
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
            Text('asdf'),
            RaisedButton(
              child: Text("SHOW ReCAPTCHA"),
              onPressed: () {
                recaptchaV2Controller.show();
              },
            ),
            Text(verifyResult),
            SizedBox(
              height: 500,
            child: RecaptchaV2(
              apiKey: "6LfwNuQUAAAAAJotXunpFX3i5VIgTsOOz-MuwQmM",
              //apiKey: "6LfwNuQUAAAAAEgz-u8dDPqdO9mvhEOnSKW9Pv4G",
              controller: recaptchaV2Controller,
              response: (token) {
                setState(() {
                  debugPrint("recaptcha onresponse");
                  verifyResult = token;
                });
              },
            )),

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
