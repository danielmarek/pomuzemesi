import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomuzemesi/task_detail_page.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'analytics.dart';
import 'data.dart';
import 'main.dart';
import 'misc.dart';
import 'model.dart';

BottomNavigationBarItem bottomNAvBarItemWithBadge({
  @required int number,
  @required IconData icon,
  @required String text,
  @required screenWidth,
}) {
  return BottomNavigationBarItem(
    icon: new Stack(
      children: <Widget>[
        new Icon(icon),
        new Positioned(
          right: 0,
          top: 0,
          child: new Container(
            padding: EdgeInsets.all(screenWidth / 400.0),
            decoration: new BoxDecoration(
              color: Color(0xffb56320),
              borderRadius: BorderRadius.circular(screenWidth / 40.0),
            ),
            constraints: BoxConstraints(
              minWidth: screenWidth / 30.0,
              minHeight: screenWidth / 40.0,
            ),
            child: new Text(
              '$number',
              style: new TextStyle(
                color: Colors.white,
                fontSize: screenWidth / 40.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    ),
    title: Text(text),
  );
}

BottomNavigationBar bottomNavBar(BuildContext context, int pageId,
    double screenWidth, Function(int) switchToTab) {
  int otherRequestCount = Data.pendingRequests.length;
  //otherRequestCount = 0;
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_ind),
        title: Text('Úkoly'),
      ),
      otherRequestCount > 0
          ? bottomNAvBarItemWithBadge(
              number: otherRequestCount,
              //number: 10,
              icon: Icons.notifications,
              text: 'Poptávky',
              screenWidth: screenWidth,
            )
          : BottomNavigationBarItem(
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
      if (index != pageId) {
        switchToTab(index);
      }
    },
  );
}

enum MyButtonStyle {
  normal,
  light,
  blue,
}

Widget myButton(
  String text,
  double screenWidth,
  Function onPressed, {
  MyButtonStyle style = MyButtonStyle.normal,
  double widthFraction = 1.0,
}) {
  Color buttonColor, textColor;
  switch (style) {
    case MyButtonStyle.normal:
      buttonColor = SECONDARY_COLOR;
      textColor = Colors.white;
      break;
    case MyButtonStyle.light:
      buttonColor = Colors.white;
      textColor = SECONDARY_COLOR;
      break;
    case MyButtonStyle.blue:
      buttonColor = Colors.white;
      textColor = PRIMARY_COLOR2;
      break;
  }
  return SizedBox(
      height: screenWidth * 0.1,
      width: widthFraction * screenWidth,
      child: MaterialButton(
        color: buttonColor,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
              fontSize: screenWidth * FONT_SIZE_NORMAL, color: textColor),
        ),
        onPressed: onPressed,
      ));
}

Widget buttonListTile(String text, double screenWidth, Function onPressed,
    {MyButtonStyle myButtonStyle = MyButtonStyle.normal}) {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
    myButton(text, screenWidth, onPressed,
        style: myButtonStyle, widthFraction: 0.7)
  ]);
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
    if (fn != null) {
      fn();
    }
  });
}

Widget myDivider(double screenWidth) {
  return Padding(
      padding:
          EdgeInsets.only(top: screenWidth * 0.04, bottom: screenWidth * 0.04),
      child: Divider());
}

class CardBuilder {
  static double screenWidth;
  static TextStyle tsCardTop, tsCardTopBrown, tsTitle, tsDesc, tsDescSmaller;

  static void setScreenWidth(double width) {
    screenWidth = width;
    double tenpx = screenWidth * 0.025;
    // TODO relative font spacing size
    tsCardTop = TextStyle(
      color: Color.fromARGB(154, 0, 0, 0),
      letterSpacing: 1.5,
      fontSize: tenpx,
      fontWeight: FontWeight.w500,
    );
    tsCardTopBrown = TextStyle(
      color: SECONDARY_COLOR2,
      letterSpacing: 1.5,
      fontSize: tenpx,
      fontWeight: FontWeight.w500,
    );
    tsTitle = TextStyle(
      color: Colors.black87, //Color.fromARGB(223, 0, 0, 0),
      letterSpacing: 0.15,
      fontSize: tenpx * 2,
      fontWeight: FontWeight.w500,
    );
    tsDesc = TextStyle(
      color: Colors.black87, //Color.fromARGB(223, 0, 0, 0),
      letterSpacing: 0.5,
      fontSize: tenpx * 1.6,
      fontWeight: FontWeight.normal,
    );
    tsDescSmaller = TextStyle(
      color: Colors.black54, //Color.fromARGB(223, 0, 0, 0),
      letterSpacing: 0.5,
      fontSize: tenpx * 1.3,
      fontWeight: FontWeight.normal,
    );
  }

  static List<Widget> descriptionWidgets({@required Request request}) {
    // TODO also upravena
    String text = 'Poptávka vytvořena: ${request.formatCreatedAt()}.';

    String desc = 'Poptávka nemá popis.';
    if (request.shortDescription != null && request.longDescription != null) {
      desc = "${request.shortDescription}\n\n${request.longDescription}";
    } else if (request.shortDescription != null) {
      desc = request.shortDescription;
    } else if (request.longDescription != null) {
      desc = request.longDescription;
    }

    return [
          myDivider(screenWidth),
          Row(children: <Widget>[Text(text, style: tsDescSmaller)]),
          SizedBox(height: screenWidth / 32.0),
          Row(
            children: <Widget>[
              Flexible(
                  child: Text(
                desc,
                style: tsDesc,
              ))
            ],
          ),
        ] +
        (request.allDetailsGranted
            ? []
            : [
                SizedBox(height: screenWidth / 32.0),
                ListTile(
                  leading: Icon(Icons.info, color: PRIMARY_COLOR2),
                  title: Text(
                    'Neúplná data - poptávka bude koordinátorem upřesněna po přijetí.',
                    style: TextStyle(color: PRIMARY_COLOR2),
                  ),
                )
              ]);
  }

  static List<Widget> searchingVolunteersWidgets({@required Request request}) {
    List<Widget> l = List<Widget>();
    int vols = request.requiredVolunteerCount;
    if (vols > 1) {
      String text;
      if (vols >= 5) {
        text = 'Hledáme $vols dobrovolníků.';
      } else if (vols > 1) {
        text = 'Hledáme $vols dobrovolníky.';
      } else {
        text = 'Hledáme 1 dobrovolníka.';
      }
      l.addAll(<Widget>[
        myDivider(screenWidth),
        Row(children: <Widget>[Text(text, style: tsDescSmaller)]),
      ]);
    }
    return l;
  }

  static List<Widget> contactButtons(BuildContext context, String email,
      String phone, String address, String recipientKind) {
    debugPrint("contactButtons: $email, $phone, $address");
    if (email == null && phone == null && address == null) {
      return <Widget>[];
    }
    List<Widget> l = List<Widget>();
    if (phone != null) {
      l.add(myButton('Volat', screenWidth, () {
        openPhoneCallTo(context, phone, recipientKind);
      }, style: MyButtonStyle.blue, widthFraction: 0.25));
      if (l.length > 0) {
        l.add(SizedBox(width: screenWidth * 0.02));
      }
      l.add(myButton('SMS', screenWidth, () {
        sendSmsTo(context, phone, recipientKind);
      }, style: MyButtonStyle.blue, widthFraction: 0.25));
    }
    if (email != null) {
      if (l.length > 0) {
        l.add(SizedBox(width: screenWidth * 0.02));
      }
      l.add(myButton('E-mail', screenWidth, () {
        sendEmailTo(context, email, recipientKind);
      }, style: MyButtonStyle.blue, widthFraction: 0.25));
    }

    if (address != null) {
      if (l.length > 0) {
        l.add(SizedBox(width: screenWidth * 0.02));
      }
      l.add(myButton('Mapa', screenWidth, () {
        OurAnalytics.logEvent(name: OurAnalytics.OPEN_MAPS);
        MapsLauncher.launchQuery(address);
      }, style: MyButtonStyle.blue, widthFraction: 0.25));
    }
    return <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.start, children: l)
    ];
  }

  static List<Widget> contactWidgets(
      {@required Request request,
      @required String title,
      @required TextStyle topTextStyle,
      @required BuildContext context,
      @required String recipientKind,
      String email,
      fullName,
      phone,
      address}) {
    debugPrint("contactWidgets: $email, $fullName, $phone, $address");

    List<Widget> l = List<Widget>();

    if (fullName != null || email != null || phone != null || address != null) {
      List<Widget> contactItems = List<Widget>();
      if (fullName != null) {
        contactItems.add(Text(fullName));
      }
      if (email != null) {
        contactItems.add(Text(email));
      }
      if (phone != null) {
        contactItems.add(Text(phone));
      }
      if (address != null) {
        if (request.address != null && request.address.street != null) {
          contactItems.add(Text(address));
        } else {
          contactItems.add(Text("Orientační adresa: $address"));
        }
      }

      l.addAll(<Widget>[
            myDivider(screenWidth),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(title.toUpperCase(), style: topTextStyle),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            ListTile(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: contactItems)),
            SizedBox(height: screenWidth * 0.03),
          ] +
          contactButtons(context, email, phone, address, recipientKind));
    }
    return l;
  }

  static List<Widget> respondButtons(
      {@required Request request, Function onAccept, Function onDecline}) {
    debugPrint('request myState: ${request.myState}');
    //r.myState in {accepted, pending_notification, rejected

    Widget reject = myButton('Odmítnout', screenWidth, onDecline,
        widthFraction: 0.4, style: MyButtonStyle.light);
    Widget accept =
        myButton('Přijmout', screenWidth, onAccept, widthFraction: 0.35);

    List<Widget> widgets;
    if (request.myState == 'pending_notification' ||
        request.myState == 'notified' ||
        request.myState == 'to_be_notified') {
      widgets = <Widget>[
        reject,
        SizedBox(width: screenWidth * 0.02),
        accept,
      ];
    } else if (request.myState == 'rejected') {
      widgets = <Widget>[accept];
    } else if (request.myState == 'accepted') {
      widgets = <Widget>[reject];
    } else {
      debugPrint("Unknown request state: ${request.myState}");
    }

    List<Widget> l = List<Widget>();
    l.addAll([
      myDivider(screenWidth),
      //SizedBox(height: screenWidth * 0.05,)
    ]);
    l.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: widgets));
    return l;
  }

  static Function(BuildContext, Animation<double>, HeroFlightDirection,
      BuildContext, BuildContext) _flightShuttleBuilder() {
    return (
      BuildContext flightContext,
      Animation<double> animation,
      HeroFlightDirection flightDirection,
      BuildContext fromHeroContext,
      BuildContext toHeroContext,
    ) {
      return SingleChildScrollView(
        child: fromHeroContext.widget,
      );
    };
  }

  static Widget buildCard({
    @required BuildContext context,
    @required Request request,
    @required int cameFrom,
    @required bool isDetail,
    @required Function onReturn,
    Function onAccept,
    Function onDecline,
    bool bland = false,
  }) {
    int requestID = request.id;
    String cityAndPart = request.formatCityAndPart();
    String date = request.formatFulfillmentDate();
    String title = request.formatTitle();

    List<Widget> widgets = List<Widget>();

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
      widgets.addAll(searchingVolunteersWidgets(request: request) +
          descriptionWidgets(request: request) +
          contactWidgets(
            context: context,
            request: request,
            title: 'Koordinátor',
            email: request.coordinatorEmail,
            fullName: request.formatCoordinatorFullName(),
            phone: request.coordinatorPhone,
            topTextStyle: tsCardTop,
            recipientKind: OurAnalytics.RECIPIENT_COORDINATOR,
          ) +
          contactWidgets(
            context: context,
            request: request,
            title: 'Odběratel',
            fullName: request.subscriber,
            phone: request.subscriberPhone,
            address: request.getAddress(),
            topTextStyle: tsCardTopBrown,
            recipientKind: OurAnalytics.RECIPIENT_SUBSCRIBER,
          ) +
          respondButtons(
            request: request,
            onDecline: onDecline,
            onAccept: onAccept,
          ));
    }

    List<Widget> actualContent = <Widget>[
      SizedBox(
        height: screenWidth * 0.04,
      ),
    ];

    // Add the closing X button.
    if (isDetail) {
      actualContent.add(
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(
            height: screenWidth * 0.15,
            width: screenWidth * 0.13,
            child: InkWell(
              child: Icon(
                Icons.clear,
                size: screenWidth * 0.06,
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ))
      ]));
    }

    for (Widget w in widgets) {
      actualContent.add(Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.04, right: screenWidth * 0.04),
        child: w,
      ));
    }

    actualContent.add(SizedBox(
      height: screenWidth * 0.04,
    ));

    Widget content = Column(children: actualContent);

    Card result;

    if (isDetail) {
      result = Card(child: content);
    } else {
      String routeName;
      if (MyHomePageState.currentPage == HOME_PAGE) {
        routeName = '/home/request';
      } else {
        routeName = '/${ROUTES[MyHomePageState.currentPage]}/request';
      }

      result = Card(
          child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPage(
                            title: "Detail úkolu",
                            request: request,
                            cameFrom: cameFrom,
                          ),
                      settings: RouteSettings(
                        name: routeName,
                      )),
                ).then((_) {
                  onReturn();
                });
              },
              child: content));
    }
    if (bland) {
      return Hero(
          tag: 'request_$requestID',
          //flightShuttleBuilder: _flightShuttleBuilder(),
          child: Material(
              type: MaterialType.transparency,
              child: Opacity(opacity: 0.35, child: result)));
    } else {
      return Hero(
          tag: 'request_$requestID',
          //flightShuttleBuilder: _flightShuttleBuilder(),
          child: Material(type: MaterialType.transparency, child: result));
    }
  }
}

List<Widget> textWithPadding(List<String> texts, double screenWidth) {
  TextStyle ts = TextStyle(fontSize: screenWidth * 0.04);
  List<Widget> l = List<Widget>();
  for (String t in texts) {
    l.add(Text(t, style: ts));
  }
  return <Widget>[
    Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: l))
  ];
}
