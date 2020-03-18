import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';

import 'testdata.dart';
import 'data.dart';
import 'skills_page.dart';
import 'profile_page.dart';
import 'widget_misc.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    String skillsStr =
        Data.me.skillIDs.map((sid) => SKILLS[sid].name).toList().join(", ");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: <Widget>[
        ListTile(
          title: Text('Můj profil'),
          subtitle: Text("${Data.me.firstName} ${Data.me.lastName}"),
          leading: Icon(Icons.person), //onTap
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  title: "Můj profil",
                ),
              ),
            );
          }, //o
        ),
        ListTile(
          title: Text('Dovednosti, co mohu nabídnout'),
          subtitle: Text(skillsStr),
          leading: Icon(Icons.person), //onTap
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SkillsPage(
                  title: "Moje dovednosti",
                ),
              ),
            );
          }, //o
        ),
      ]),
      bottomNavigationBar: bottomNavBar(context, SETTINGS_PAGE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        tooltip: 'Help',
        child: Icon(Icons.help_outline),
      ),
    );
  }
}
