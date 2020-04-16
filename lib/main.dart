import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'dart:math';

import 'analytics.dart';
import 'data.dart';
import 'db.dart';
import 'misc.dart';
import 'model.dart';
import 'rest_client.dart';
import 'widget_misc.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(PomuzemeSiApp());
  });
}

Widget _wrapWithBanner(Widget child) {
  return Banner(
    child: child,
    location: BannerLocation.topStart,
    message: 'BETA',
    color: Colors.green.withOpacity(0.6),
    textStyle: TextStyle(
        fontWeight: FontWeight.w700, fontSize: 12.0, letterSpacing: 1.0),
    textDirection: TextDirection.ltr,
  );
}

class PomuzemeSiApp extends StatefulWidget {
  PomuzemeSiAppState createState() => PomuzemeSiAppState();
}

class PomuzemeSiAppState extends State<PomuzemeSiApp> {
  static FirebaseAnalytics analytics =
      OurAnalytics.instance = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingSetUpListeners(
      firebaseMessaging,
      onResume: onFCMResume,
    );
  }

  Future<dynamic> onFCMResume(Map<String, dynamic> message) {
    debugPrint('Firebase: onResume(): $message');
    if (!message.containsKey('data') || message['data'] == null) {
      debugPrint("FCM message doesn't contain the data key.");
      return null;
    }
    var data = message['data'];
    if (!data.containsKey('request_id') || data['request_id'] == null) {
      debugPrint("FCM message doesn't contain the data/request_id key.");
      return null;
    }
    var requestID = data['request_id'];
    int rid = int.parse(requestID.toString());
    debugPrint("FCM message concerning request: $rid");
    bool isAcceptedRequest = false;
    if (Data.acceptedRequests != null) {
      for (Request r in Data.acceptedRequests) {
        if (r.id == rid) {
          isAcceptedRequest = true;
          break;
        }
      }
    }
    if (isAcceptedRequest) {
      debugPrint(
          "This is an accepted request, routing to /, context: ${context.toString()}");
      navigatorKey.currentState.pushReplacementNamed('/');
    } else {
      debugPrint(
          "This is not an accepted request, routing to /$ROUTE_NEW_REQUESTS");
      navigatorKey.currentState.pushReplacementNamed('/$ROUTE_NEW_REQUESTS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        title: 'Pomuzeme.si',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        home: MyHomePage(tab: HOME_PAGE, firebaseMessaging: firebaseMessaging),
        initialRoute: '/',
        routes: {
          '/$ROUTE_NEW_REQUESTS': (context) => MyHomePage(
              tab: REQUESTS_PAGE, firebaseMessaging: firebaseMessaging),
          '/$ROUTE_PROFILE': (context) => MyHomePage(
              tab: PROFILE_PAGE, firebaseMessaging: firebaseMessaging),
          '/$ROUTE_ABOUT': (context) =>
              MyHomePage(tab: ABOUT_PAGE, firebaseMessaging: firebaseMessaging),
        });
  }
}

enum HomePageState {
  haveRegistration,
  enterPhone,
  waitForSMS,
  enterSMS,
  waitForToken,
  //enterRegistrationDetails,
  //uploadProfile,
  blockingFetchAll,
  ready,
}

class MyHomePage extends StatefulWidget {
  final int tab;
  final FirebaseMessaging firebaseMessaging;

  MyHomePage({this.tab, this.firebaseMessaging, Key key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

HomePageState homePageState;

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  double screenWidth;

  final _formEnterPhoneKey = GlobalKey<FormState>();
  final _formEnterSMSKey = GlobalKey<FormState>();
  TextEditingController controllerPhoneNumber = new TextEditingController();
  TextEditingController controllerSMS = new TextEditingController();

  String fcmToken, phoneNumber;
  static bool loaded = false;
  static HomePageState homePageState;

  //bool registrationDone = false;
  static int currentPage = HOME_PAGE;

  //static HomePageState homePageState;

  //final _formKey = GlobalKey<FormState>();

  //FormControllers controllers = FormControllers();

  Timer pollingTimer;

  AppLifecycleState _appLifecycleState;

  String lastExplicitRefreshError;
  double backoffTime = 10.0;
  Random random = Random();
  bool showNotificationsPreset = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.tab;
    WidgetsBinding.instance.addObserver(this);
    if (homePageState == null) {
      setStateBlockingFetchAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controllerPhoneNumber.dispose();
    controllerSMS.dispose();
    if (pollingTimer != null) {
      pollingTimer.cancel();
    }
    super.dispose();
  }

  /*Future<bool> getPrefsThenBuild() async {
    authToken = await SharedPrefs.getToken();
    loaded = true;
    if (authToken != null) {
      setStateBlockingFetchAll();
      loaded = true;
      return true;
    }
    setStateEnterPhone();
    return true;
  }*/

  static bool isInForeground(AppLifecycleState state) {
    return (state == null || state.index == null || state.index == 0);
  }

  void startPollingTimer() {
    pollingTimer = Timer.periodic(Duration(seconds: 2), (t) {
      timerTick();
    });
  }

  void timerTick() async {
    if (homePageState != HomePageState.ready) {
      return;
    }
    int tokenValidSeconds = TokenWrapper.tokenValidSeconds(TokenWrapper.token);
    debugPrint("TOKEN VALID FOR: $tokenValidSeconds s");
    if (tokenValidSeconds < REFRESH_TOKEN_BEFORE) {
      TokenWrapper.maybeTryToRefresh();
      return;
    }

    bool inForeground = isInForeground(_appLifecycleState);
    debugPrint("Timer tick, inForeground: $inForeground");
    if (inForeground) {
      Data.maybePollAndThen(backoffTime, (e) {
        // Only clear up the bar when we manage to fetch data after it
        // previously failed manually, but don't spam this with auto-refresh
        // failures.
        if (e == null) {
          debugPrint("Poll successful.");
          setLastRefreshError(e);
          backoffTime = STALENESS_LIMIT_MS;
        } else {
          debugPrint("Poll failed.");
          backoffTime =
              backoffTime * 3 + (backoffTime * random.nextInt(100) * 0.01);
        }
        setState(() {});
      });
    }
  }

  Future<bool> setStateHaveRegistration() async {
    setState(() {
      homePageState = HomePageState.haveRegistration;
    });
    return true;
  }

  Future<bool> setStateEnterPhone() async {
    setState(() {
      homePageState = HomePageState.enterPhone;
    });
    return true;
  }

  Future<bool> setStateEnterSMS() async {
    controllerSMS.text = '';
    setState(() {
      homePageState = HomePageState.enterSMS;
    });
    return true;
  }

  void setStateWaitForSMS({bool manualRetry = false}) async {
    setState(() {
      homePageState = HomePageState.waitForSMS;
    });
    askForSMS(manualRetry: manualRetry);
  }

  void askForSMS({bool manualRetry = false}) async {
    bool success = false;
    try {
      // TODO: captcha token.
      await RestClient.sessionNew(phoneNumber, 'foobar', fcmToken);
      setStateEnterSMS();
      success = true;
    } on APICallException catch (e) {
      if (e.errorCode == 404) {
        setStateEnterPhone().then((_) {
          showDialogWithText(
              context,
              'Nenalezena registrace pro toto telefonní číslo. Registrujte se na www.pomuzeme.si a pak zde zadejte telefonní číslo znovu.',
              null);
        });
      } else {
        if (e.errorKey == APICallException.CONNECTION_FAILED && manualRetry) {
          setStateEnterSMS().then((_) {
            showDialogWithText(context, e.cause, null);
          });
        } else {
          setStateEnterPhone().then((_) {
            showDialogWithText(context, e.cause, null);
          });
        }
      }
    }
    OurAnalytics.logEvent(
        name: manualRetry
            ? OurAnalytics.RESEND_SMS_CODE
            : OurAnalytics.SUBMIT_PHONE_NUMBER,
        parameters: {
          'success': success,
        });
  }

  /*void setStateEnterRegistrationDetails() {
    setState(() {
      homePageState = HomePageState.enterRegistrationDetails;
    });
  }*/

  void setStateReady() {
    //registrationDone = true;
    homePageState = HomePageState.ready;
    Data.maybeInitFromDb().then((_) {
      setState(() {});
      if (pollingTimer == null) {
        startPollingTimer();
      }
      if (showNotificationsPreset) {
        showDialogWithText(
            context,
            "Notifikace Vám od teď budou chodit do aplikace místo SMS. V nastavení toto můžete změnit.",
            null);
      }
    });
  }

  /*void setStateUploadProfile() {
    setState(() {
      homePageState = HomePageState.uploadProfile;
      Timer(const Duration(seconds: 2), () {
        setStateReady();
      });
    });
  }*/

  void setStateWaitForToken(String smsCode /*, bool hasRegistration*/) async {
    setState(() {
      homePageState = HomePageState.waitForToken;
    });
    submitSMSCode(smsCode);
  }

  void submitSMSCode(String smsCode) async {
    bool success = false;
    try {
      String t = await RestClient.sessionCreate(phoneNumber, smsCode);
      TokenWrapper.saveToken(t);
      Data.toggleNotificationsAndThen(
          setValue: true,
          then: (_) {
            showNotificationsPreset = true;
            setStateBlockingFetchAll();
          });
      success = true;
    } on APICallException catch (e) {
      if (e.errorCode == 401) {
        setStateEnterSMS().then((_) {
          showDialogWithText(
              context, 'Špatně zadaný kód, zkuste to znovu.', null);
        });
        // TODO double-check this is what the backend indeed returns.
      } else if (e.errorCode == 429) {
        setStateEnterPhone().then((_) {
          showDialogWithText(
              context,
              'Vyčerpali jste počet pokusů na zadání kódu. Zadejte telefonní číslo znovu.',
              null);
        });
      } else {
        setStateEnterSMS().then((_) {
          showDialogWithText(context, e.cause, null);
        });
      }
    }
    OurAnalytics.logEvent(name: OurAnalytics.SUBMIT_SMS_CODE, parameters: {
      'success': success,
    });
  }

  Future<bool> setStateBlockingFetchAll() async {
    debugPrint("SET STATE blockingFetchAll");
    setState(() {
      homePageState = HomePageState.blockingFetchAll;
    });
    blockingFetchAll();
    return true;
  }

  Future<bool> blockingFetchAll() async {
    await TokenWrapper.load();
    loaded = true;
    //debugPrint("blockingFetchAll: auth token: ${TokenWrapper.token}");
    if (TokenWrapper.token == null) {
      setStateHaveRegistration();
      return true;
    }
    Data.updateAllAndThen((e) {
      setLastRefreshError(e);
      setStateReady();
    });
    return true;
  }

  Widget imgBlock(String filename) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          top: screenWidth * 0.2,
          bottom: screenWidth * 0.1,
        ),
        child: Image.asset('assets/img/$filename.png'),
      ),
    );
  }

  void setLastRefreshError(APICallException e) {
    debugPrint("setLastRefreshError $e");
    if (e == null) {
      lastExplicitRefreshError = null;
    } else {
      lastExplicitRefreshError = e.cause;
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    Data.updateAllAndThen((e) {
      setLastRefreshError(e);
      if (e == null) {
        backoffTime = STALENESS_LIMIT_MS;
      }
      OurAnalytics.logEvent(
        name: OurAnalytics.MANUAL_REFRESH,
        parameters: {
          'success': e == null,
        },
      );
      setState(() {});
    });
  }

  List<Widget> cardsForList(List<Request> requests, {bool bland = false}) {
    List<Widget> l = List<Widget>();
    for (Request request in requests) {
      l.add(CardBuilder.buildCard(
        context: context,
        request: request,
        cameFrom: HOME_PAGE,
        isDetail: false,
        bland: bland,
        onReturn: () {
          Data.updateAllAndThen((e) {
            setLastRefreshError(e);
            setState(() {});
          });
        },
      ));
    }
    return l;
  }

  List<Widget> cards() {
    if (currentPage == HOME_PAGE) {
      if (Data.acceptedRequests.length > 0) {
        return cardsForList(Data.acceptedRequests);
      } else {
        return noTasks('Nemáte žádné přijaté úkoly.');
      }
    }
    List<Widget> l = List<Widget>();
    List<Widget> pending = cardsForList(Data.pendingRequests);
    List<Widget> rejected = cardsForList(Data.rejectedRequests, bland: true);
    l.add(SizedBox(height: screenWidth * 0.02));

    l.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Text("Čekají na rozhodnutí".toUpperCase(),
              style: CardBuilder.tsCardTop),
        )
      ],
    ));

    if (pending.length > 0) {
      l.addAll(pending);
    } else {
      l.addAll(noTasks('Nemáte žádné poptávky čekající na Vaše rozhodnutí.'));
      l.add(SizedBox(height: screenWidth * 0.15));
    }
    if (rejected.length > 0) {
      l.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child:
                Text("Odmítnuté".toUpperCase(), style: CardBuilder.tsCardTop),
          )
        ],
      ));
      l.addAll(rejected);
    }

    return l;
  }

  void switchToPage(int index) {
    //Navigator.pushNamed(context, '/${ROUTES[index]}');
    Navigator.pushReplacementNamed(context, '/${ROUTES[index]}');
  }

  Widget settingsPageBody() {
    return ListView(children: <Widget>[
      ExpansionTile(
          title: Text("Můj profil"),
          children: textWithPadding(Data.me.getNamesPhoneEmail(), screenWidth)),
      CheckboxListTile(
          title: Text('Dostávat notifikace do aplikace'),
          subtitle: Text("V opačném případě budete dostávat SMS"),
          secondary: Icon(Icons.notifications),
          value: Data.preferences.notificationsToApp,
          onChanged: (val) {
            Data.toggleNotificationsAndThen(then: (String err) {
              setState(() {});
              if (err != null) {
                showDialogWithText(context, err, () {
                  setState(() {});
                });
              }
            });
            setState(() {});
          }),
    ]);
  }

  void sendFeedback() async {
    sendEmailTo(context, FEEDBACK_MAILBOX, OurAnalytics.RECIPIENT_DEVELOPER);
  }

  Widget aboutBody() {
    return ListView(children: <Widget>[
      ExpansionTile(
        title: Text("O aplikaci"),
        children: textWithPadding([
          "Vytvořeno v březnu-dubnu 2020 v rámci pomoci potřebným v souvislosti s pandemií Covid-19."
        ], screenWidth),
      ),
      ListTile(
        title: Text("Podmínky užívání"),
        onTap: () {
          launch("https://pomuzeme.si/podminky_dobrovolnika_pomuzemesi.pdf");
        },
      ),
      ListTile(
        title: Text("Podmínky ochrany osobních údajů"),
        onTap: () {
          launch(
              "https://pomuzeme.si/podminky_ochrany_osobnich_udaju_pomuzemesi.pdf");
        },
      ),
      SizedBox(height: screenWidth * 0.05),
      ListTile(
        title: Text(
            "Máte pro nás zpětnou vazbu? Pošlete nám ji na $FEEDBACK_MAILBOX, ať můžeme aplikaci vylepšit."),
      ),
      SizedBox(height: screenWidth * 0.05),
      buttonListTile("Odeslat zpětnou vazbu", screenWidth, () {
        sendFeedback();
      }),
    ]);
  }

  List<Widget> noTasks(String msg) {
    return <Widget>[
      imgBlock('undraw_no_data'),
      ListTile(
          title: Center(
              child: Text(
        msg,
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.6),
          fontSize: screenWidth * 0.035,
        ),
      ))),
    ];
  }

  List<Widget> topBar() {
    debugPrint("TOPBAR: $lastExplicitRefreshError");
    Color textColor = Color.fromRGBO(0, 0, 0, 0.38);
    Color boxBkg = Color.fromRGBO(240, 240, 240, 1.0);
    EdgeInsets insets = EdgeInsets.all(screenWidth * 0.015);
    EdgeInsets insetsError = EdgeInsets.only(
      top: screenWidth * 0.025,
      left: screenWidth * 0.015,
      right: screenWidth * 0.015,
      bottom: screenWidth * 0.015,
    );
    double sizes = screenWidth * 0.035;
    TextStyle ts = TextStyle(
      color: textColor,
      fontSize: sizes,
    );
    TextStyle tsError = TextStyle(
      color: SECONDARY_COLOR2,
      fontSize: sizes,
    );

    List<Widget> l = List<Widget>();
    if (lastExplicitRefreshError != null) {
      l.add(SizedBox(
          width: screenWidth,
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: boxBkg,
              ),
              child: Padding(
                padding: insetsError,
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(lastExplicitRefreshError, style: tsError),
                    ])),
              ))));
    }

    l.add(SizedBox(
        width: screenWidth,
        child: DecoratedBox(
            decoration: BoxDecoration(
              color: boxBkg,
            ),
            child: Padding(
              padding: insets,
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text('Poslední aktualizace: ${Data.lastUpdatePretty()}',
                        style: ts),
                    SizedBox(width: screenWidth * 0.02),
                    Icon(
                      Icons.arrow_downward,
                      size: sizes,
                      color: textColor,
                    ),
                  ])),
            ))));
    return l;
  }

  Widget buildReady() {
    screenWidth = MediaQuery.of(context).size.width;

    Widget body;
    switch (currentPage) {
      case HOME_PAGE:
      case REQUESTS_PAGE:
        /*
        body = LiquidPullToRefresh(
          child: (Data.acceptedRequests.length == 0 && currentPage == HOME_PAGE)
              ? noTasks()
              : cards(),
          onRefresh: _onRefresh,
          showChildOpacityTransition: false,
          color: PRIMARY_COLOR,
        );*/
        body = RefreshIndicator(
          /*child: (Data.acceptedRequests.length == 0 && currentPage == HOME_PAGE)
              ? noTasks()
              : cards(), */
          child: ListView(children: topBar() + cards()),
          onRefresh: _onRefresh,
          color: PRIMARY_COLOR,
        );
        break;
      case PROFILE_PAGE:
        body = settingsPageBody();
        break;
      case ABOUT_PAGE:
        body = aboutBody();
        break;
    }

    List<String> pageTitles = [
      "Moje Úkoly",
      "Poptávky",
      "Profil",
      "O Aplikaci"
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
      bottomNavigationBar:
          bottomNavBar(context, currentPage, screenWidth, switchToPage),
      floatingActionButton: currentPage == ABOUT_PAGE
          ? FloatingActionButton(
              tooltip: 'Debug settings',
              backgroundColor: Colors.redAccent, //PRIMARY_COLOR,
              child: Icon(Icons.settings),
              onPressed: () {
                showDebugDialog(() {
                  setStateBlockingFetchAll();
                  //setState(() {});
                });
              },
            )
          : null,
    );
  }

  Widget buildHaveRegistration() {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: screenWidth * 0.05),
          imgBlock('pomuzemesi_laptop'),
          ListTile(
            title: Text(
                'Pro spuštění této aplikace musíte mít registraci na www.pomuzeme.si - pokud ji ještě nemáte, nejdříve se tam zaregistrujte.'),
          ),
          SizedBox(height: screenWidth * 0.1),
          buttonListTile("Registraci mám", screenWidth, () {
            setStateEnterPhone();
            OurAnalytics.logEvent(
              name: OurAnalytics.I_HAVE_REGISTRATION,
            );
          }),
        ],
      ),
    );
  }

  Widget buildEnterPhoneNumber() {
    // FIXME race condition
    widget.firebaseMessaging.getToken().then((firebaseToken) {
      fcmToken = firebaseToken;
      print("Firebase token: $firebaseToken");
    });
    debugPrint("build: auth token: ${TokenWrapper.token}");
    return Scaffold(
        body: Form(
      key: _formEnterPhoneKey,
      child: ListView(
        children: <Widget>[
          imgBlock('pomuzemesi_phone'),
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
                keyboardType: TextInputType.number,
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
          SizedBox(height: screenWidth * 0.05),
          buttonListTile("Získat ověřovací SMS", screenWidth, () {
            if (_formEnterPhoneKey.currentState.validate()) {
              phoneNumber = controllerPhoneNumber.text;
              setStateWaitForSMS(manualRetry: false);
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
          imgBlock('pomuzemesi_phone'),
          ListTile(
            title: Text(
                'Poslali jsme Vám SMS s ověřovacím kódem. Ten sem, prosím, přepište.'),
          ),
          ListTile(
              // TODO get from the phone automatically.
              leading: const Icon(Icons.textsms),
              title: TextFormField(
                keyboardType: TextInputType.number,
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
          SizedBox(height: screenWidth * 0.05),
          buttonListTile("Ověřit", screenWidth, () {
            if (_formEnterSMSKey.currentState.validate()) {
              setStateWaitForToken(controllerSMS.text /*, true*/);
            }
          }),
          ListTile(
            title: Text('Nepřišla Vám SMS?'),
          ),
          buttonListTile("Odeslat novou SMS", screenWidth, () {
            setStateWaitForSMS(manualRetry: true);
          }, myButtonStyle: MyButtonStyle.light),
          /*buttonListTile("Ověřit (TEST nemám registraci)", screenWidth, () {
            if (_formEnterSMSKey.currentState.validate()) {
              setStateWaitForToken(controllerSMS.text, false);
            }
          }),*/
        ],
      ),
    ));
  }

/*
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
  }*/

  @override
  Widget build(BuildContext context) {
    // DEBUG
    widget.firebaseMessaging.getToken().then((firebaseToken) {
      print("Firebase token: $firebaseToken");
    });
    debugPrint("build: auth token: ${TokenWrapper.token}");
    screenWidth = MediaQuery.of(context).size.width;
    CardBuilder.setScreenWidth(screenWidth);
    Widget body;
    if (!loaded) {
      body = buildLoading('Načítám data ...');
    } else {
      // Login/registration flow.
      //if (authToken == null || !registrationDone) {
      switch (homePageState) {
        case HomePageState.haveRegistration:
          body = buildHaveRegistration();
          break;
        case HomePageState.enterPhone:
          body = buildEnterPhoneNumber();
          break;
        case HomePageState.waitForSMS:
          body = buildLoading("Odesílám požadavek o potvrzovací SMS ...");
          break;
        case HomePageState.enterSMS:
          body = buildEnterSMS();
          break;
        case HomePageState.waitForToken:
          body = buildLoading("Čekám na potvrzení SMS kódu ...");
          break;
        /*case HomePageState.enterRegistrationDetails:
            return buildWithRegistrationForm();
          case HomePageState.uploadProfile:
            return buildLoading("Posílám registraci na server ...");*/
        case HomePageState.blockingFetchAll:
          body = buildLoading("Načítám data ...");
          break;
        case HomePageState.ready:
          body = buildReady();
          break;
      }
    }
    return _wrapWithBanner(body);
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
                      //registrationDone = false;
                      TokenWrapper.token = null;
                      phoneNumber = null;
                      controllerPhoneNumber.text = '';
                      controllerSMS.text = '';
                      DbRecords.deleteAll().then((_) {
                        setStateHaveRegistration();
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                  /*
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
                  ),*/
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
