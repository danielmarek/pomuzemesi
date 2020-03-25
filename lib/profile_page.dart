import 'package:flutter/material.dart';

import 'data.dart';
import 'misc.dart';
import 'personal_details_form.dart';
import 'widget_misc.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  FormControllers controllers = FormControllers(
    firstName: Data.me.firstName,
    lastName: Data.me.lastName,
    phone: Data.me.phone,
    street: Data.me.street,
    streetNumber: Data.me.streetNumber,
    city: Data.me.city,
    cityPart: Data.me.cityPart,
  );

  double screenWidth;

  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: getPersonalDetailsForm(
          formKey: _formKey,
          screenWidth: screenWidth,
          context: context,
          controllers: controllers,
          onProfileSaved: () {
            Navigator.of(context).pop();
          }),
      bottomNavigationBar: bottomNavBar(context, SETTINGS_PAGE),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Help',
        child: Icon(Icons.help),
      ),
    );
  }
}
