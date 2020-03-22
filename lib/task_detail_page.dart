import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'data.dart';
import 'model.dart';
import 'misc.dart';
import 'widget_misc.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.title, this.task, @required this.cameFrom})
      : super(key: key);

  final String title;
  final Task task;
  final int cameFrom;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double screenWidth;

  Widget isMineSection() {
    if (!widget.task.isMine) {
      if (widget.task.volunteersBooked < widget.task.volunteersRequired) {
        return ListTile(
            title: MaterialButton(
          color: SECONDARY_COLOR,
          child: Text(
            "Pomoci s tímto úkolem.",
            style: TextStyle(
                fontSize: screenWidth * FONT_SIZE_NORMAL, color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              Data.assignTask(widget.task.id, true);
            });
          },
        ));
      } else {
        return ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Tento úkol je již plně obsazen.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * FONT_SIZE_NORMAL,
                  ),
                ),
              ],
            ));
      }
    } else {
      return ListTile(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(Icons.info, color: PRIMARY_COLOR),
          Text('Toto je můj úkol.',
              style: TextStyle(
                  color: PRIMARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * FONT_SIZE_NORMAL)),
          MaterialButton(
            color: SECONDARY_COLOR,
            child: Text(
              "Odebrat tento úkol.",
              style: TextStyle(
                  fontSize: screenWidth * FONT_SIZE_NORMAL,
                  color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                Data.assignTask(widget.task.id, false);
              });
            },
          )
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.description),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                    "Pomoc potřebuje: ${widget.task.firstName} ${widget.task.lastName}"),
                Text("tel: ${widget.task.phone}"),
              ],
            ),
            subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${widget.task.address}"),
                  Text("${widget.task.whenToDo}"),
                ]),
          ),
          Container(
            padding: EdgeInsets.only(left: screenWidth * LEFT_OF_TEXT_BLOCK, right: screenWidth * LEFT_OF_TEXT_BLOCK),
            height: 100, // FIXME
            //width: 200,
            child: Text(
              "Je potřeba pomoci s lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
              style: TextStyle(fontSize: screenWidth * FONT_SIZE_NORMAL),
              softWrap: true,
            ),
          ),
          ListTile(
            title: Text(
                "Přiřazených dobrovolníků: ${widget.task.volunteersBooked} z ${widget.task.volunteersRequired}"),
            subtitle:
                Text("Potřebná dovednost: ${widget.task.skillRequired.name}"),
          ),
          isMineSection(),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Koordinátor: ${widget.task.coordinator}"),
                Text("tel: ${widget.task.organization.contactPhone}"),
              ],
            ),
            subtitle: Text("${widget.task.organization.name}"),
          ),
          ListTile(
              title: MaterialButton(
            color: SECONDARY_COLOR,
            child: Text(
              "Otevřít mapu",
              style: TextStyle(fontSize: screenWidth * FONT_SIZE_NORMAL, color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                MapsLauncher.launchQuery(widget.task.address);
              });
            },
          ))
        ],
      ),
      bottomNavigationBar: bottomNavBar(context, widget.cameFrom),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help),
      ),
    );
  }
}
