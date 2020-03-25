import 'package:flutter/material.dart';
import 'data.dart';
import 'model.dart';
import 'widget_misc.dart';

class FormControllers {
  TextEditingController controllerFirstName,
      controllerLastName,
      controllerPhone,
      controllerStreet,
      controllerStreetNumber,
      controllerCity,
      controllerCityPart;

  FormControllers(
      {String firstName = '',
      String lastName = '',
      String phone = '',
      String street = '',
      String streetNumber = '',
      String city = '',
      String cityPart = ''}) {
    controllerFirstName = TextEditingController(text: firstName);
    controllerLastName = TextEditingController(text: lastName);
    controllerPhone = TextEditingController(text: phone);
    controllerStreet = TextEditingController(text: street);
    controllerStreetNumber = TextEditingController(text: streetNumber);
    controllerCity = TextEditingController(text: city);
    controllerCityPart = TextEditingController(text: cityPart);
  }

  void dispose() {
    controllerFirstName.dispose();
    controllerLastName.dispose();
    controllerPhone.dispose();
    controllerStreet.dispose();
    controllerStreetNumber.dispose();
    controllerCity.dispose();
    controllerCityPart.dispose();
  }
}

Form getPersonalDetailsForm({
  @required GlobalKey<FormState> formKey,
  @required double screenWidth,
  @required BuildContext context,
  @required FormControllers controllers,
  Function onProfileSaved,
}) {
  return Form(
    key: formKey,
    child: ListView(
      children: <Widget>[
        ListTile(
            leading: const Icon(Icons.person),
            title: TextFormField(
              controller: controllers.controllerFirstName,
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
              controller: controllers.controllerLastName,
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
            leading: const Icon(Icons.smartphone),
            title: TextFormField(
              controller: controllers.controllerPhone,
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
              controller: controllers.controllerStreet,
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
              controller: controllers.controllerStreetNumber,
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
              controller: controllers.controllerCity,
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
              controller: controllers.controllerCityPart,
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
        buttonListTile('Uložit', screenWidth, () {
          if (formKey.currentState.validate()) {
            // If the form is valid, display a Snackbar.
            //Scaffold.of(context)
            //    .showSnackBar(SnackBar(content: Text('Zpracovávám')));
            //_formKey.currentState.
            Set<int> mySkills = Data.me.skillIDs;
            Volunteer updatedMe = Volunteer(
              firstName: controllers.controllerFirstName.text,
              lastName: controllers.controllerLastName.text,
              phone: controllers.controllerPhone.text,
              street: controllers.controllerStreet.text,
              streetNumber: controllers.controllerStreetNumber.text,
              city: controllers.controllerCity.text,
              cityPart: controllers.controllerCityPart.text,
              skillIDs: mySkills,
            );
            Data.saveMyProfile(updatedMe);
            onProfileSaved();
          }
        }),
      ],
    ),
  );
}
