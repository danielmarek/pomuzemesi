import 'package:flutter/material.dart';

import 'data.dart';
import 'model.dart';
import 'misc.dart';
import 'widget_misc.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final myControllerFirstName = TextEditingController(text: Data.me.firstName);
  final myControllerLastName = TextEditingController(text: Data.me.lastName);
  final myControllerPhone = TextEditingController(text: Data.me.phone);
  final myControllerStreet = TextEditingController(text: Data.me.street);
  final myControllerStreetNumber =
      TextEditingController(text: Data.me.streetNumber);
  final myControllerCity = TextEditingController(text: Data.me.city);
  final myControllerCityPart = TextEditingController(text: Data.me.cityPart);

  @override
  void dispose() {
    myControllerFirstName.dispose();
    myControllerLastName.dispose();
    myControllerPhone.dispose();
    myControllerStreet.dispose();
    myControllerStreetNumber.dispose();
    myControllerCity.dispose();
    myControllerCityPart.dispose();
    super.dispose();
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
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.person),
                title: TextFormField(
                  controller: myControllerFirstName,
                  decoration: new InputDecoration(
                    hintText: "Jméno",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.person),
                title: TextFormField(
                  controller: myControllerLastName,
                  decoration: new InputDecoration(
                    hintText: "Příjmení",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.phone),
                title: TextFormField(
                  controller: myControllerPhone,
                  decoration: new InputDecoration(
                    hintText: "Telefon",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: TextFormField(
                  controller: myControllerStreet,
                  decoration: new InputDecoration(
                    hintText: "Ulice",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: TextFormField(
                  controller: myControllerStreetNumber,
                  decoration: new InputDecoration(
                    hintText: "Číslo popisné",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: TextFormField(
                  controller: myControllerCity,
                  decoration: new InputDecoration(
                    hintText: "Město",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: TextFormField(
                  controller: myControllerCityPart,
                  decoration: new InputDecoration(
                    hintText: "Čtvrť",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Vyplňte prosím';
                    }
                    return null;
                  },
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: SECONDARY_COLOR,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a Snackbar.
                      //Scaffold.of(context)
                      //    .showSnackBar(SnackBar(content: Text('Zpracovávám')));
                      //_formKey.currentState.
                      Set<int> mySkills = Data.me.skillIDs;
                      Volunteer updatedMe = Volunteer(
                        firstName: myControllerFirstName.text,
                        lastName: myControllerLastName.text,
                        phone: myControllerPhone.text,
                        street: myControllerStreet.text,
                        streetNumber: myControllerStreetNumber.text,
                        city: myControllerCity.text,
                        cityPart: myControllerCityPart.text,
                        skillIDs: mySkills,
                      );
                      Data.saveMyProfile(updatedMe);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Uložit',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, SETTINGS_PAGE),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help),
      ),
    );
  }
}
