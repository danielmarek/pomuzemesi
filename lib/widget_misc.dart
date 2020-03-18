import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'list_tasks_page.dart';
import 'misc.dart';
import 'settings_page.dart';
import 'privacy_policy_page.dart';


void launchTaskSearch(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ListPage(
          title: "Co je potřeba s mojí specializací",
          getTasks: Data.mySpecTasks),
    ),
  );
}

BottomNavigationBar bottomNavBar(BuildContext context, int pageId) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Moje úkoly'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        title: Text('Úkoly'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        title: Text('Můj profil'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info_outline),
        title: Text('O aplikaci'),
      ),
    ],
    currentIndex: pageId,
    backgroundColor: PRIMARY_COLOR,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.black,
    onTap: (index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      switch (index) {
        case 0:
          return;
        case 1:
          launchTaskSearch(context);
          return;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                title: "Můj profil a dovednosti",
              ),
            ),
          );
          return;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrivacyPolicyPage(
                title: "Privacy Policy",
              ),
            ),
          );
          return;
      }
    },
  );
}