import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';

import 'dart:io';
import 'dart:async';

import 'data.dart';
import 'task_detail_page.dart';
import 'model.dart';
import 'misc.dart';
import 'personal_details_form.dart';
import 'shared_prefs.dart';
import 'widget_misc.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  Data.initWithRandomData();
  SharedPrefs.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Pomuzeme.si',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(),
    );
  }
}

enum HomePageState {
  enterPhone,
  waitForSMS,
  enterSMS,
  waitForToken,
  enterRegistrationDetails,
  uploadProfile,
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  double screenWidth;

  final _formEnterPhoneKey = GlobalKey<FormState>();
  final _formEnterSMSKey = GlobalKey<FormState>();
  TextEditingController controllerPhoneNumber = new TextEditingController();
  TextEditingController controllerSMS = new TextEditingController();

  String token;
  bool loaded = false;
  bool registrationDone = false;

  HomePageState homePageState = HomePageState.enterPhone;

  final _formKey = GlobalKey<FormState>();
  FormControllers controllers = FormControllers();

  Future<bool> getPrefsThenBuild() async {
    token = await SharedPrefs.getToken();
    setState(() {
      loaded = true;
    });
    return true;
  }

  @override
  void dispose() {
    controllerPhoneNumber.dispose();
    controllerSMS.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingSetUpListeners(firebaseMessaging);
    getPrefsThenBuild();
  }

  void setStateEnterSMS() {
    setState(() {
      homePageState = HomePageState.enterSMS;
    });
  }

  void setStateWaitForSMS() {
    setState(() {
      homePageState = HomePageState.waitForSMS;
      Timer(const Duration(seconds: 2), () {
        setStateEnterSMS();
      });
    });
  }

  void setStateEnterRegistrationDetails() {
    setState(() {
      homePageState = HomePageState.enterRegistrationDetails;
    });
  }

  void setStateReady() {
    registrationDone = true;
    getPrefsThenBuild().then((_) {
      showDialogWithText(
          context,
          "Notifikace Vám od teď budou chodit do aplikace místo SMS. V nastavení toto můžete změnit.",
          () {});
    });
  }

  void setStateUploadProfile() {
    setState(() {
      homePageState = HomePageState.uploadProfile;
      Timer(const Duration(seconds: 2), () {
        setStateReady();
      });
    });
  }

  void setStateWaitForToken(String smsCode, bool hasRegistration) {
    setState(() {
      homePageState = HomePageState.waitForToken;
      Timer(const Duration(seconds: 2), () {
        tryToValidateSMS(smsCode, hasRegistration);
      });
    });
  }

  void tryToValidateSMS(String smsCode, bool hasRegistration) {
    if (smsCode == '123456') {
      SharedPrefs.setToken('123456');
      if (hasRegistration) {
        setStateReady();
      } else {
        setStateEnterRegistrationDetails();
      }
      getPrefsThenBuild();
    } else {
      setState(() {
        homePageState = HomePageState.enterSMS;
      });
      showDialogWithText(context, "Kód byl zadán chybně.", () {});
    }
  }

  Widget imgBlock() {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          top: screenWidth * 0.2,
          bottom: screenWidth * 0.1,
        ),
        child: Image.asset('assets/img/undraw_confirmed.png'),
      ),
    );
  }

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

  List<Widget> buildCenterContentNotAuthorized() {
    return [
      ListTile(
        title: SizedBox(height: 30),
      ),
      ListTile(
        title: Image.asset('assets/img/undraw_confirmation.png'),
      ),
      ListTile(
        title: Text(
            "Vaše registrace je hotová, už jen čeká na schválení organizací.",
            style: TextStyle(fontSize: screenWidth * FONT_SIZE_NORMAL)),
      ),
      ListTile(
        title: Text(
            "Schválení Vám oznámíme SMS/notifikací a Vám pak můžou začít chodit poptávky.",
            style: TextStyle(fontSize: screenWidth * FONT_SIZE_NORMAL)),
      ),
    ];
  }

  List<Widget> buildCenterContentWithNoTasks() {
    return [
      ListTile(
        title: SizedBox(height: 30),
      ),
      ListTile(
        title: Image.asset('assets/img/pomuzemesi-drawing.png'),
      ),
      ListTile(
        title: Text(
            "Zatím jste se neujali žádného úkolu. Nějaký si vyberte, pak ho uvidíte tady.",
            style: TextStyle(fontSize: screenWidth * FONT_SIZE_NORMAL)),
      ),
      buttonListTile("Přidat úkol", screenWidth, () {
        launchTaskSearch(context);
      }),
    ];
  }

  List<Widget> buildCenterContentWithTasks() {
    return [
          ListTile(
            title: Image.asset('assets/img/pomuzemesi-logo.png'),
          ),
        ] +
        allTaskTiles(Data.myTasks(), context);
  }

  Widget buildReady() {
    screenWidth = MediaQuery.of(context).size.width;
    firebaseMessaging.getToken().then((token) {
      print("Firebase token: $token");
    });

    List<Widget> centerContent;
    if (Data.authorized) {
      if (Data.myTasks().length > 0) {
        centerContent = buildCenterContentWithTasks();
      } else {
        centerContent = buildCenterContentWithNoTasks();
      }
    } else {
      centerContent = buildCenterContentNotAuthorized();
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
        tooltip: 'Debug settings',
        backgroundColor: Colors.red, //PRIMARY_COLOR,
        child: Icon(Icons.settings),
        onPressed: () {
          showDebugDialog(() {
            getPrefsThenBuild();
            //setState(() {});
          });
        },
      ),
    );
  }

  Widget buildEnterPhoneNumber() {
    return Scaffold(
        body: Form(
      key: _formEnterPhoneKey,
      child: ListView(
        children: <Widget>[
          imgBlock(),
          ListTile(
            title: Text('Nejprve je potřeba ověřit Vaše telefonní číslo'),
          ),
          ListTile(
            title: Text('Po zadání čísla Vám přijde SMS s ověřovacím kódem'),
          ),
          ListTile(
              // TODO get from the phone automatically.
              leading: const Icon(Icons.smartphone),
              // leading: Text('+420'),
              title: TextFormField(
                controller: controllerPhoneNumber,
                decoration: new InputDecoration(
                  hintText: "Vaše telefonní číslo",
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Vyplňte prosím';
                  }
                  return null;
                },
              )),
          buttonListTile("Získat ověřovací SMS", screenWidth, () {
            if (_formEnterPhoneKey.currentState.validate()) {
              setStateWaitForSMS();
            }
          }),
        ],
      ),
    ));
  }

  Widget buildLoading() {
    return Scaffold(
        body: Container(
            //color: PRIMARY_COLOR,
            child: Center(
                child: //Loading(
                    //indicator: BallPulseIndicator(), size: 100.0, color: PRIMARY_COLOR),
                    //),
                    LoadingBouncingGrid.square(
      borderColor: PRIMARY_COLOR,
      borderSize: 3.0,
      size: 30.0,
      backgroundColor: PRIMARY_COLOR,
      duration: Duration(milliseconds: 1000),
    ))));
  }

  Widget buildEnterSMS() {
    return Scaffold(
        body: Form(
      key: _formEnterSMSKey,
      child: ListView(
        children: <Widget>[
          imgBlock(),
          ListTile(
            title: Text(
                'Poslali jsme Vám SMS s ověřovacím kódem. Ten sem, prosím, přepište.'),
          ),
          ListTile(
            title: Text('Nepřišla SMS? Řekněte si o novou SMS (TODO).'),
          ),
          ListTile(
            title: Text(
                'TEST: 123456 je "správně" než to napárujem s backendem. Taky si zvolte, jestli "máte" registraci.'),
          ),
          ListTile(
              // TODO get from the phone automatically.
              leading: const Icon(Icons.textsms),
              title: TextFormField(
                controller: controllerSMS,
                decoration: new InputDecoration(
                  hintText: "SMS kód",
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Vyplňte prosím';
                  }
                  return null;
                },
              )),
          buttonListTile("Ověřit (TEST mám registraci)", screenWidth, () {
            if (_formEnterSMSKey.currentState.validate()) {
              setStateWaitForToken(controllerSMS.text, true);
            }
          }),
          buttonListTile("Ověřit (TEST nemám registraci)", screenWidth, () {
            if (_formEnterSMSKey.currentState.validate()) {
              setStateWaitForToken(controllerSMS.text, false);
            }
          }),
        ],
      ),
    ));
  }

  Widget buildWithRegistrationForm() {
    return Scaffold(
        body: getPersonalDetailsForm(
            formKey: _formKey,
            screenWidth: screenWidth,
            context: context,
            controllers: controllers,
            onProfileSaved: () {
              setStateUploadProfile();
            }));
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (!loaded) {
      return buildLoading();
    } else {
      // Login/registration flow.
      if (token == null || !registrationDone) {
        switch (homePageState) {
          case HomePageState.enterPhone:
            return buildEnterPhoneNumber();
          case HomePageState.waitForSMS:
            return buildLoading();
          case HomePageState.enterSMS:
            return buildEnterSMS();
          case HomePageState.waitForToken:
            return buildLoading();
          case HomePageState.enterRegistrationDetails:
            return buildWithRegistrationForm();
          case HomePageState.uploadProfile:
            return buildLoading();
        }
      } else {
        // Normal case of being in the app.
        return buildReady();
      }
    }
  }

  void showDebugDialog(Function fn) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("DEBUG/TEST options"),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MaterialButton(
                    color: Colors.red,
                    child: Text(
                      'Přegenerovat data',
                      style: TextStyle(
                          fontSize: screenWidth * FONT_SIZE_NORMAL,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Data.initWithRandomData();
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.red,
                    child: Text(
                      'Zpět před login',
                      style: TextStyle(
                          fontSize: screenWidth * FONT_SIZE_NORMAL,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      homePageState = HomePageState.enterPhone;
                      registrationDone = false;
                      controllerPhoneNumber.text = '';
                      controllerSMS.text = '';
                      SharedPrefs.removeToken().then((_) {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                  MaterialButton(
                    color: Colors.red,
                    child: Text(
                      'Toggle ověřen organizací',
                      style: TextStyle(
                          fontSize: screenWidth * FONT_SIZE_NORMAL,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Data.authorized = !Data.authorized;
                      Navigator.of(context).pop();
                    },
                  ),
                ]),
            actions: <Widget>[
              new FlatButton(
                child: new Text("GO BACK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }).then((_) {
      fn();
    });
  }
}
