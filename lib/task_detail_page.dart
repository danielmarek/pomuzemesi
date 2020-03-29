import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

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
    RestClient.respondToRequest(widget.request.id, true);
  }

  void declineTask() async {
    RestClient.respondToRequest(widget.request.id, false);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      //appBar: AppBar(title: Text(Data2.requests[widget.requestID].shortDescription),),
      body: cardBuilder(
          context: context,
          request: widget.request,
          cameFrom: widget.cameFrom,
          screenWidth: screenWidth,
          isDetail: true,
          onAccept: acceptTask,
          onDecline: declineTask,
      ),
      /*bottomNavigationBar: bottomNavBar(context, widget.cameFrom),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help),
      ),*/
    );
  }
}
