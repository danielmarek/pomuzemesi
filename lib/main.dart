import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


// FIXME DEBUG
import 'api_page.dart';
import 'a_webview_page.dart';
import 'captcha_page.dart';

import 'dart:io';
import 'dart:async';

import 'data2.dart';
import 'model2.dart';
//import 'task_detail_page.dart';
import 'misc.dart';
import 'personal_details_form.dart';
import 'rest_client.dart';
import 'shared_prefs.dart';
import 'widget_misc.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  //Data.initWithRandomData();
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
  firstFetch,
  ready,
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

  String fcmToken, authToken, phoneNumber;
  bool loaded = false;
  bool registrationDone = false;
  int currentPage = HOME_PAGE;

  HomePageState homePageState = HomePageState.enterPhone;

  final _formKey = GlobalKey<FormState>();
  FormControllers controllers = FormControllers();

  Future<bool> getPrefsThenBuild() async {
    authToken = await SharedPrefs.getToken();
    if (authToken != null) {
      setStateFirstFetch();
      loaded = true;
      return true;
    }
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

  void setStateWaitForSMS(String phone) async {
    phoneNumber = phone;
    await RestClient.sessionNew(phone, 'foobar', fcmToken);
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
    homePageState = HomePageState.ready;
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

  void setStateWaitForToken(String smsCode, bool hasRegistration) async {
    // FIXME flow
    authToken = await RestClient.sessionCreate(phoneNumber, smsCode);
    RestClient.token = authToken;
    setState(() {
      homePageState = HomePageState.waitForToken;
      Timer(const Duration(seconds: 2), () {
        //tryToValidateSMS(smsCode, hasRegistration);
        setStateFirstFetch();
      });
    });
  }

  void setStateFirstFetch() async {
    try {
      await Data2.updateRequests();
      await Data2.updateMe();
      await Data2.updatePreferences();
    } on APICallException catch (e) {
      // Unauthorized resource.
      if (e.errorCode == 401) {
        homePageState = HomePageState.enterPhone;
        controllerSMS.text = '';
        await SharedPrefs.removeToken();
        setState(() {});
        return;
      }
    }

    setState(() {
      homePageState = HomePageState.firstFetch;
      Timer(const Duration(seconds: 2), () {
        //tryToValidateSMS(smsCode, hasRegistration);
        setStateReady();
      });
    });
  }

  /*void tryToValidateSMS(String smsCode, bool hasRegistration) {
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
  }*/

  Widget imgBlock() {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          top: screenWidth * 0.2,
          bottom: screenWidth * 0.1,
        ),
        child: Image.asset('assets/img/pomuzemesi_phone.png'),
      ),
    );
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
        //launchTaskSearch(context);
      }),
    ];
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    await Data2.updateRequests();
    //_refreshController.refreshCompleted();
    setState(() {});
  }

  ListView cards() {
    List<Request2> requests = currentPage == 0 ? Data2.myRequests : Data2.otherRequests;
    List<Widget> l = List<Widget>();
    for (Request2 request in requests) {
      l.add(cardBuilder(
          context: context,
          request: request,
          cameFrom: HOME_PAGE,
          screenWidth: screenWidth,
          isDetail: false));
    }
    return ListView(
      children: l,
    );
  }

  void switchToPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  Widget settingsPageBody() {
    return ListView(children: <Widget>[
      ExpansionTile(
        title: Text("Můj profil"),
        children: <Widget>[
          Text(Data2.me.firstName),
          Text(Data2.me.lastName),
          Text(Data2.me.phone),
          Text(Data2.me.email),
        ]
      ),
      CheckboxListTile(
          title: Text('Dostávat notifikace do aplikace'),
          subtitle: Text("V opačném případě budete dostávat SMS"),
          secondary: Icon(Icons.notifications),
          value: Data2.preferences.notificationsToApp,
          onChanged: (val) {
            setState(() {
              //Data2.toggleNotifications();
            });
          }),
    ]);
  }

  Widget aboutBody() {
    return ListView(children: <Widget>[
      ExpansionTile(
          title: Text("O Aplikaci"),
          children: <Widget>[
            Text("Vytvořeno v březnu 2020."),
          ]
      ),
      ExpansionTile(
          title: Text("Privacy Policy"),
          children: <Widget>[
            Text("TODO: přidat privacy policy"),
          ]
      ),
    ]);
  }

  Widget buildReady() {
    screenWidth = MediaQuery.of(context).size.width;

    Widget body;
    switch (currentPage) {
      case HOME_PAGE:
      case TASKS_PAGE:
        body = LiquidPullToRefresh(
          child: cards(),
          onRefresh: _onRefresh,
          showChildOpacityTransition: false,
          color: PRIMARY_COLOR,
        );
        break;
      case SETTINGS_PAGE:
        body = settingsPageBody();
        break;
      case PRIVACY_POLICY_PAGE:
        body = aboutBody();
        break;
    }

    List<String> pageTitles = [
      "Pomůžeme.si: Moje Úkoly",
      "Pomůžeme.si: Poptávky",
      "Pomůžeme.si: Profil",
      "Pomůžeme.si: O Aplikaci"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[currentPage],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: PRIMARY_COLOR,
      ),
      body: body,
      /*
      body: refresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        itemCount: Data2.requests != null ? Data2.requests.length : 0,
        cardBuilder: cardBuilder,
      ),*/ //ListView(children: <Widget>[] + centerContent + []),
      bottomNavigationBar: bottomNavBar(context, currentPage, switchToPage),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Debug settings',
        backgroundColor: Colors.redAccent, //PRIMARY_COLOR,
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
    // FIXME race condition
    firebaseMessaging.getToken().then((firebaseToken) {
      fcmToken = firebaseToken;
      print("Firebase token: $firebaseToken");
    });
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
              setStateWaitForSMS(controllerPhoneNumber.text);
            }
          }),
        ],
      ),
    ));
  }

  Widget buildLoading(String text) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
          LoadingBouncingGrid.square(
            borderColor: PRIMARY_COLOR,
            borderSize: 3.0,
            size: 30.0,
            backgroundColor: PRIMARY_COLOR,
            duration: Duration(milliseconds: 1000),
          ),
          SizedBox(height: screenWidth / 16),
          Text(
            text,
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
        ])));
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
    // DEBUG
    firebaseMessaging.getToken().then((firebaseToken) {
      print("Firebase token: $firebaseToken");
    });
    screenWidth = MediaQuery.of(context).size.width;
    if (!loaded) {
      return buildLoading('Načítám data ...');
    } else {
      // Login/registration flow.
      //if (authToken == null || !registrationDone) {
        switch (homePageState) {
          case HomePageState.enterPhone:
            return buildEnterPhoneNumber();
          case HomePageState.waitForSMS:
            return buildLoading("Odesílám požadavek o potvrzovací SMS ...");
          case HomePageState.enterSMS:
            return buildEnterSMS();
          case HomePageState.waitForToken:
            return buildLoading("Čekám na potvrzení SMS kódu ...");
          case HomePageState.enterRegistrationDetails:
            return buildWithRegistrationForm();
          case HomePageState.uploadProfile:
            return buildLoading("Posílám registraci na server ...");
          case HomePageState.firstFetch:
            return buildLoading("Načítám data ...");
          case HomePageState.ready:
            return buildReady();
        }
     /* } else {
        // Normal case of being in the app.
        return buildReady();
      }*/
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
                      'api page',
                      style: TextStyle(
                          fontSize: screenWidth * FONT_SIZE_NORMAL,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApiPage(
                            title: "api",
                          ),
                        ),
                      );
                    },
                  ),
            MaterialButton(
              color: Colors.red,
              child: Text(
                'webview',
                style: TextStyle(
                    fontSize: screenWidth * FONT_SIZE_NORMAL,
                    color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebviewPage(
                      title: "webview",
                    ),
                  ),
                );
              },
            ),
                  MaterialButton(
                    color: Colors.red,
                    child: Text(
                      'captcha',
                      style: TextStyle(
                          fontSize: screenWidth * FONT_SIZE_NORMAL,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CaptchaPage(
                            title: "captcha",
                          ),
                        ),
                      );
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
