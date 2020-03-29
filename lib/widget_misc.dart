import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomuzemesi/task_detail_page2.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';

//import 'data.dart';
import 'data2.dart';
//import 'list_tasks_page.dart';
import 'misc.dart';
import 'model2.dart';
//import 'privacy_policy_page.dart';

BottomNavigationBar bottomNavBar(BuildContext context, int pageId, Function(int) switchToTab) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_ind),
        title: Text('Úkoly'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        title: Text('Poptávky'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        title: Text('Profil'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info),
        title: Text('O aplikaci'),
      ),
    ],
    currentIndex: pageId,
    backgroundColor: PRIMARY_COLOR2,
    selectedItemColor: Colors.white,
    unselectedItemColor: Color.fromARGB(189, 255, 255, 255),
    onTap: (index) {
      switchToTab(index);
    },
  );
}

ListTile buttonListTile(String text, double screenWidth, Function onPressed) {
  return ListTile(
      title: SizedBox(
          height: screenWidth * 0.1,
          child: MaterialButton(
            color: SECONDARY_COLOR,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: screenWidth * FONT_SIZE_NORMAL,
                  color: Colors.white),
            ),
            onPressed: onPressed,
          )));
}

Widget centeredTextOnlyScaffold(String title, String text) {
  return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
          child: Center(
        child: new Text(
          text,
          textAlign: TextAlign.center,
        ),
      )));
}

void showDialogWithText(BuildContext context, String title, Function fn) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }).then((val) {
    fn();
  });
}
/*
SmartRefresher refresher({
  @required RefreshController controller,
  @required Function onRefresh,
  @required Function onLoading,
  @required int itemCount,
  @required Function(BuildContext, int) cardBuilder,
}) {
  return SmartRefresher(
    enablePullDown: true,
    enablePullUp: true,
    header: WaterDropHeader(),
    footer: CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("pull up load");
        } else if (mode == LoadStatus.loading) {
          body = Text('loading ...'); //CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed!Click retry!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("release to load more");
        } else {
          body = Text("No more Data");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    ),
    controller: controller,
    onRefresh: onRefresh,
    onLoading: onLoading,
    child: ListView.builder(
      itemBuilder: cardBuilder, //requestToCard,
      //itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
      itemExtent: 100.0,
      //itemCount: items.length,
      itemCount:
          itemCount, //Data2.requests != null ? Data2.requests.length : 0,
    ),
  );
}*/

Widget cardBuilder({
  @required BuildContext context,
  @required Request2 request,
  @required int cameFrom,
  @required double screenWidth,
  @required bool isDetail,
  Function onAccept,
  Function onDecline,
}) {
  double tenpx = screenWidth * 0.025;
  // TODO relative font spacing size

  TextStyle tsCardTop = TextStyle(
    color: Color.fromARGB(154, 0, 0, 0),
    letterSpacing: 1.5,
    fontSize: tenpx,
    fontWeight: FontWeight.w500,
  );
  TextStyle tsTitle = TextStyle(
    color: Colors.black87, //Color.fromARGB(223, 0, 0, 0),
    letterSpacing: 0.15,
    fontSize: tenpx * 2,
    fontWeight: FontWeight.w500,
  );
  TextStyle tsDesc = TextStyle(
    color: Colors.black87, //Color.fromARGB(223, 0, 0, 0),
    letterSpacing: 0.5,
    fontSize: tenpx * 1.6,
    fontWeight: FontWeight.normal,
  );

  int requestID = request.id;
  String city = request.city == null ? "Město" : request.city;
  String cityPart = request.cityPart == null ? "Čtvrť" : request.cityPart;
  String date = 'Datum/Čas';
  if (request.fulfillmentDate != null) {
    var dateFormatter = new DateFormat('dd. MM. kk:mm');
    date = dateFormatter.format(request.fulfillmentDate.toLocal());
  }
  String title = request.shortDescription;
  if (title.length > 25) {
    title = title.substring(0, 25) + ' ...';
  }
  String cityAndPart = "${city.toUpperCase()}, ${cityPart.toUpperCase()}";
  if (cityAndPart.length > 22) {
    cityAndPart = cityAndPart.substring(0, 18) + ' ...';
  }

  List<Widget> widgets = List<Widget>();

  if (isDetail) {
    widgets
        .add(Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      SizedBox(
          height: screenWidth * 0.2,
          width: screenWidth * 0.2,
          child: InkWell(
            child: Icon(Icons.clear),
            onTap: () {
              Navigator.of(context).pop();
            },
          ))
    ]));
  }

  widgets.addAll(<Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(cityAndPart, style: tsCardTop),
        Text("$date", style: tsCardTop),
      ],
    ),
    Padding(
        padding: EdgeInsets.only(top: screenWidth * 0.025),
        child: Row(
          children: <Widget>[
            Flexible(
                child: Text(
              "$title",
              style: tsTitle,
            ))
          ],
        ))
  ]);

  if (isDetail) {
    widgets.addAll([
      Divider(),
      Row(
        children: <Widget>[
          Flexible(
              child: Text(
            "${request.shortDescription}",
            style: tsDesc,
          ))
        ],
      ),
      Divider(),
      MaterialButton(
        child: Text('Přijmout'),
        onPressed: onAccept,
      ),
      MaterialButton(
        child: Text('Odmítnout'),
        onPressed: onDecline,
      ),
    ]);
  }

  Widget content = Padding(
    padding: EdgeInsets.all(screenWidth * 0.05),
    child: Column(children: widgets),
  );

  if (isDetail) {
    return Hero(tag: 'request_$requestID', child: Card(child: content));
  } else {
    return Hero(
        tag: 'request_$requestID',
        child: Card(
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage2(
                        title: "Detail úkolu",
                        request: request,
                        cameFrom: cameFrom,
                      ),
                    ),
                  );
                },
                child: content)));
  }
}
