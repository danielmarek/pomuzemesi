import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'model.dart';
import 'misc.dart';
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

class _DetailPageState extends State<DetailPage> {
  double screenWidth;

  void acceptTask() async {
    // TODO HTTP 409: REQUEST_CAPACITY_EXCEEDED
    await RestClient.respondToRequest(widget.request.id, true);
    Navigator.of(context).pop();
  }

  void declineTask() async {
    await RestClient.respondToRequest(widget.request.id, false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    CardBuilder.setScreenWidth(screenWidth);
    return Scaffold(
      //appBar: AppBar(title: Text(Data2.requests[widget.requestID].shortDescription),),
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
      /*bottomNavigationBar: bottomNavBar(context, widget.cameFrom),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help),
      ),*/
    );
  }
}
