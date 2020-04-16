import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pomuzemesi/misc.dart';

import 'dart:io';

import 'analytics.dart';
import 'model.dart';
import 'poller.dart';
import 'rest_client.dart';
import 'widget_misc.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.title, this.request, @required this.cameFrom})
      : super(key: key);

  final String title;

  //final Task task;
  final int cameFrom;
  final Request request;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with WidgetsBindingObserver {
  double screenWidth;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Poller.appLifecycleState = state;
  }

  Future<String> respondToTask(bool accept) async {
    // TODO HTTP 409: REQUEST_CAPACITY_EXCEEDED
    String err;
    try {
      await RestClient.respondToRequest(widget.request.id, accept);
    } on APICallException catch (e) {
      // Unauthorized resource.
      if (e.errorCode == 409) {
        err = 'Tento úkol je již plně obsazen.';
      } else {
        err = e.cause;
      }
    }
    return err;
  }

  void acceptTask() async {
    String err = await respondToTask(true);
    if (err == null) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Poptávka byla přesunuta do úkolů",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: SECONDARY_COLOR,
          textColor: Colors.white,
          fontSize: screenWidth * 0.04);
    } else {
      showDialogWithText(context, err, () {});
    }

    OurAnalytics.logEvent(
        name: OurAnalytics.ACCEPT_REQUEST,
        parameters: {'success': err == null});
  }

  void declineTask() async {
    String err = await respondToTask(false);
    if (err == null) {
      Navigator.of(context).pop();
    } else {
      showDialogWithText(context, err, () {});
    }

    OurAnalytics.logEvent(
        name: OurAnalytics.DECLINE_REQUEST,
        parameters: {'success': err == null});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    CardBuilder.setScreenWidth(screenWidth);
    return Scaffold(
      body: ListView(children: <Widget>[
        CardBuilder.buildCard(
          context: context,
          request: widget.request,
          cameFrom: widget.cameFrom,
          isDetail: true,
          onAccept: acceptTask,
          onDecline: declineTask,
        )
      ]),
    );
  }
}
