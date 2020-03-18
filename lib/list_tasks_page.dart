import 'package:flutter/material.dart';
import 'package:pomuzemesi/misc.dart';
import 'package:pomuzemesi/task_detail_page.dart';

import 'model.dart';
import 'widget_misc.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title, this.getTasks}) : super(key: key);

  final String title;
  final Function getTasks;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  ListTile taskToTile(Task task) {
    return ListTile(
      title: Text(task.description),
      subtitle: Text(
          "${task.volunteersBooked}/${task.volunteersRequired} dobrovolníků. ${task.address}"),
      leading: Icon(task.skillRequired.icon), // FIXME
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              task: task,
              cameFrom: TASKS_PAGE,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
    );
  }

  List<Widget> buildTaskTiles(List<Task> tasks) {
    List<ListTile> l = List<ListTile>();
    for (int i = 0; i < tasks.length; i++) {
      l.add(taskToTile(tasks[i]));
    }
    return l;
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
      body: ListView(children: buildTaskTiles(widget.getTasks())),
      bottomNavigationBar: bottomNavBar(context, TASKS_PAGE),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help_outline),
      ),
    );
  }
}
