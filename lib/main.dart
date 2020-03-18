import 'package:flutter/material.dart';

import 'data.dart';
import 'task_detail_page.dart';
import 'model.dart';
import 'misc.dart';
import 'widget_misc.dart';

void main() {
  Data.initWithRandomData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomuzeme.si',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ListTile taskToTile(Task task, BuildContext context) {
    return ListTile(
      title: Text(task.description),
      subtitle: Text(
          "${task.volunteersBooked}/${task.volunteersRequired} dobrovolníků. ${task.address}"),
      leading: Icon(task.skillRequired.icon),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              task: task,
              cameFrom: HOME_PAGE,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
    );
  }

  List<Widget> allTaskTiles(List<Task> tasks, BuildContext context) {
    List<ListTile> l = List<ListTile>();
    for (int i = 0; i < tasks.length; i++) {
      l.add(taskToTile(tasks[i], context));
    }
    return l;
  }

  List<Widget> buildCenterContentWithNoTasks() {
    return [
      ListTile(
        title: SizedBox(height: 30),
      ),
      ListTile(
        title: Image.asset('pomuzemesi-drawing.png'),
      ),
      ListTile(
        title: Text(
            "Zatím jste se neujali žádného úkolu. Nějaký si vyberte, pak ho uvidíte tady."),
      ),
      ListTile(
          leading: SizedBox(width: 30),
          trailing: SizedBox(width: 30),
          title: MaterialButton(
            color: SECONDARY_COLOR,
            child: Text(
              "Přidat úkol",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            onPressed: () {
              launchTaskSearch(context);
            },
          )),
    ];
  }

  List<Widget> buildCenterContentWithTasks() {
    return [
          ListTile(
            title: Image.asset('pomuzemesi-logo.png'),
          ),
        ] +
        allTaskTiles(Data.myTasks(), context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> centerContent;
    if (Data.myTasks().length > 0) {
      centerContent = buildCenterContentWithTasks();
    } else {
      centerContent = buildCenterContentWithNoTasks();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pomůžeme.si - moje úkoly",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: ListView(children: <Widget>[] + centerContent + []),
      bottomNavigationBar: bottomNavBar(context, 0),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Refresh',
        backgroundColor: PRIMARY_COLOR,
        child: Icon(Icons.refresh),
        onPressed: () {
          setState(() {
            Data.initWithRandomData();
          });
        },
      ),
    );
  }
}
