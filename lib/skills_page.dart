import 'package:flutter/material.dart';

import 'data.dart';
import 'testdata.dart';
import 'misc.dart';
import 'widget_misc.dart';

class SkillsPage extends StatefulWidget {
  SkillsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  @override
  void dispose() {
    super.dispose();
  }

  CheckboxListTile getTile(int skillID) {
    return CheckboxListTile(
        title: Text(SKILLS[skillID].name),
        secondary: Icon(SKILLS[skillID].icon),
        value: Data.iHaveSkill(SKILLS[skillID]),
        onChanged: (val) {
          setState(() {
            Data.toggleSkill(skillID);
          });
        });
  }

  List<Widget> allTiles() {
    return SKILLS.map((s) => getTile(s.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: allTiles(),
      ),
      //bottomNavigationBar: bottomNavBar(context, SETTINGS_PAGE),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        backgroundColor: PRIMARY_COLOR,
        child: Icon(Icons.help),
      ),
    );
  }
}
