import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebviewPage extends StatefulWidget {
  WebviewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {

  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    /*return WebviewScaffold(
        url: "https://www.google.com",
        //javascriptChannels: ,
        appBar: new AppBar(
          title: new Text("Widget webview"),
        ));*/
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
              child: Text("launch webview"),
              onPressed: () {
                flutterWebviewPlugin.launch(
                  'https://www.google.com',


                  //fullScreen: false,
                  rect: new Rect.fromLTWH(
                    0.0,
                    300.0,
                    MediaQuery.of(context).size.width,
                    300.0,
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text("close webview"),
              onPressed: () {
                flutterWebviewPlugin.close();
              },
            ),
            /*SizedBox(
              height: 400,
              child: WebView(
              initialUrl: "https://www.google.com",
              javascriptMode: JavascriptMode.unrestricted,

            )),*/


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
