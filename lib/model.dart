import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

// TODO: remove fields that are not explicitly used by this app?
// TODO: model of organisation
// TODO: parse all datetimes

// TODO: need a few more fields from the backend

// Ukol.
/*
  [{"id":1,
  "state":"searching_capacity",
  "requested_volunteer_state":"accepted",
  "short_description":"Testovaci poptavka",
  "city":null,
  "city_part":null,
  "organisation_id":1,
  "fullfillment_date":null,
  "required_volunteer_count":5,
  "accepted_volunteer_count":5,
  "created_at":"2020-03-26T17:26:52.009+01:00",
  "updated_at":"2020-03-26T17:26:52.009+01:00",
  "closed_state":null,
  "closed_note":"",
  "coordinator":{
    "email":"admin@example.com",
    "first_name":"admin",
    "last_name":"admin"},
  "subscriber":null,
  "subscriber_phone":null,
  "address":null,
  "all_details_granted":false}]
 */
class Request {
  // TODO backend:
  // - longDescription?
  // - coordinatorPhone?
  // - there is city+cityPart+address => missing street+streetNumber.
  // - subscriber - is this a name?
  final int id;

  // State of the request.
  final String state;

  // My own state as a volunteer in relation to the request.
  final String myState;

  final String title;
  final String shortDescription;
  final String longDescription;

  final String city;
  final String cityPart;
  final Address address;

  final int organisationID;
  final DateTime fulfillmentDate;
  final int requiredVolunteerCount, acceptedVolunteerCount;
  final DateTime createdAt, updatedAt;
  final String closedState;
  final String closedNote;
  final String coordinatorEmail;
  final String coordinatorFirstName;
  final String coordinatorLastName;
  final String coordinatorPhone;
  final String subscriber;
  final String subscriberPhone;
  final bool allDetailsGranted;

  Request(
      {this.id,
      this.state,
      this.myState,
      this.title,
      this.shortDescription,
      this.longDescription,
      this.city,
      this.cityPart,
      this.address,
      this.organisationID,
      this.fulfillmentDate,
      this.requiredVolunteerCount,
      this.acceptedVolunteerCount,
      this.createdAt,
      this.updatedAt,
      this.closedState,
      this.closedNote,
      this.coordinatorEmail,
      this.coordinatorFirstName,
      this.coordinatorLastName,
      this.coordinatorPhone,
      this.subscriber,
      this.subscriberPhone,
      this.allDetailsGranted});

  static Request fromParsedJson(var r) {
    return Request(
      id: r.containsKey('id') ? r['id'] : null,
      state: r.containsKey('state') ? r['state'] : null,
      myState: r.containsKey('requested_volunteer_state')
          ? r['requested_volunteer_state']
          : null,
      title: r.containsKey('title') ? r['title'] : null,
      shortDescription:
          r.containsKey('short_description') ? r['short_description'] : null,
      longDescription:
          r.containsKey('long_description') ? r['long_description'] : null,
      city: r.containsKey('city') ? r['city'] : null,
      cityPart: r.containsKey('city_part') ? r['city_part'] : null,
      address: (r.containsKey('address') && r['address'] != null)
          ? Address.fromParsedJson(r['address'])
          : null,
      organisationID:
          r.containsKey('organisation_id') ? r['organisation_id'] : null,
      // NOTE: typo on the backend.
      fulfillmentDate: r.containsKey('fullfillment_date')
          ? (r['fullfillment_date'] != null
              ? DateTime.parse(r['fullfillment_date'])
              : null)
          : null,
      requiredVolunteerCount: r.containsKey('required_volunteer_count')
          ? r['required_volunteer_count']
          : null,
      acceptedVolunteerCount: r.containsKey('accepted_volunteer_count')
          ? r['accepted_volunteer_count']
          : null,
      createdAt: r.containsKey('created_at')
          ? (r['created_at'] != null ? DateTime.parse(r['created_at']) : null)
          : null,
      updatedAt: r.containsKey('updated_at')
          ? (r['updated_at'] != null ? DateTime.parse(r['updated_at']) : null)
          : null,
      closedState: r.containsKey('closed_state') ? r['closed_state'] : null,
      closedNote: r.containsKey('closed_note') ? r['closed_note'] : null,
      subscriber: r.containsKey('subscriber') ? r['subscriber'] : null,
      subscriberPhone:
          r.containsKey('subscriber_phone') ? r['subscriber_phone'] : null,
      allDetailsGranted: r.containsKey('all_details_granted')
          ? r['all_details_granted']
          : null,
      // NOTE: dict in dict.
      coordinatorEmail: (r.containsKey('coordinator') &&
              r['coordinator'] != null &&
              r['coordinator'].containsKey('email'))
          ? r['coordinator']['email']
          : null,
      coordinatorFirstName: (r.containsKey('coordinator') &&
              r['coordinator'] != null &&
              r['coordinator'].containsKey('first_name'))
          ? r['coordinator']['first_name']
          : null,
      coordinatorLastName: (r.containsKey('coordinator') &&
              r['coordinator'] != null &&
              r['coordinator'].containsKey('last_name'))
          ? r['coordinator']['last_name']
          : null,
      coordinatorPhone: (r.containsKey('coordinator') &&
              r['coordinator'] != null &&
              r['coordinator'].containsKey('phone'))
          ? r['coordinator']['phone']
          : null,
    );
  }

  static List<Request> listFromRawJson(String jsonData) {
    List<Request> l = List<Request>();
    var parsedJson = json.decode(jsonData);
    for (int i = 0; i < parsedJson.length; i++) {
      //debugPrint(parsedJson[i].toString());
      var r = parsedJson[i];
      l.add(Request.fromParsedJson(r));
    }
    return l;
  }

  String formatCityAndPart({bool upper = true}) {
    String c = city;
    String p = cityPart;
    if (c == null && p == null) {
      return upper ? 'Neurčené místo'.toUpperCase() : 'Neurčené místo';
    }
    String cityAndPart = "$c, $p";
    if (c == null) {
      cityAndPart = p;
    } else if (p == null || c == p) {
      cityAndPart = c;
    }
    if (cityAndPart.length > 22) {
      cityAndPart = cityAndPart.substring(0, 18) + ' ...';
    }
    return upper ? cityAndPart.toUpperCase() : cityAndPart;
  }

  String formatFulfillmentDate({bool upper = true}) {
    if (fulfillmentDate != null) {
      var dateFormatter = new DateFormat('dd. MM. kk:mm');
      return dateFormatter.format(fulfillmentDate.toLocal());
    } else {
      return upper ? 'Neurčený čas'.toUpperCase() : 'Neurčený čas';
    }
  }

  String formatCreatedAt() {
    if (createdAt != null) {
      var dateFormatter = new DateFormat('dd. MM. kk:mm');
      return dateFormatter.format(createdAt.toLocal());
    } else {
      return 'neznámo';
    }
  }

  String formatTitle() {
    if (title != null) {
      return title;
    }
    String r = 'Popis není vyplněn';
    if (shortDescription != null) {
      if (shortDescription.length > 25) {
        r = shortDescription.substring(0, 25) + ' ...';
      } else {
        r = shortDescription;
      }
    }
    return r;
  }

  // TODO also phone number, when the backend supports this.
  String formatCoordinatorFullName() {
    String first = coordinatorFirstName == null ? '' : coordinatorFirstName;
    String last = coordinatorLastName == null ? '' : coordinatorLastName;
    if (first == '' && last == '') {
      return null;
    }
    return <String>[first, last].join(' ');
  }

  String getAddress() {
    if (address == null) {
      return null;
    }
    return address.asString();
  }
}

/*
{"id":2,
 "first_name":"Dan",
 "last_name":"Marek",
 "email":"dan.marek@gmail.com",
 "phone":"+420723914553",
 "address":{
   "id":2,
   "street":"Václavské náměstí",
   "street_number":"1",
   "city":"Hlavní město Praha",
   "city_part":"Nové Město",
   "geo_entry_id":"ChIJBcQ4PO2UC0cRGGWzwrNDlrs",
   "geo_unit_id":"ChIJBcQ4PO2UC0cRGGWzwrNDlrs",
   "geo_provider":"google_places",
   "coordinate":"POINT (14.4241414 50.08424400000001)",
   "postal_code":"110 00",
   "country_code":"cz",
   "addressable_type":"Volunteer",
   "addressable_id":2,
   "created_at":"2020-03-26T16:38:46.832+01:00",
   "updated_at":"2020-03-26T16:38:46.832+01:00"
  }
 }
 */

class Address {
  final int id;
  final String street, streetNumber, city, cityPart, postalCode, countryCode;
  final String geoEntryID, geoUnitID, geoProvider, coordinate;
  final String addressableType;
  final int addressableID;
  final String createdAt, updatedAt;

  Address(
      {this.id,
      this.street,
      this.streetNumber,
      this.city,
      this.cityPart,
      this.postalCode,
      this.countryCode,
      this.geoEntryID,
      this.geoUnitID,
      this.geoProvider,
      this.coordinate,
      this.addressableType,
      this.addressableID,
      this.createdAt,
      this.updatedAt});

  static Address fromParsedJson(var a) {
    return Address(
      id: a.containsKey('id') ? a['id'] : null,
      street: a.containsKey('street') ? a['street'] : null,
      streetNumber: a.containsKey('street_number') ? a['street_number'] : null,
      city: a.containsKey('city') ? a['city'] : null,
      cityPart: a.containsKey('city_part') ? a['city_part'] : null,
      postalCode: a.containsKey('postal_code') ? a['postal_code'] : null,
      countryCode: a.containsKey('country_code') ? a['country_code'] : null,
      geoEntryID: a.containsKey('geo_entry_id') ? a['geo_entry_id'] : null,
      geoUnitID: a.containsKey('geo_unit_id') ? a['geo_unit_id'] : null,
      geoProvider: a.containsKey('geo_provider') ? a['geo_provider'] : null,
      coordinate: a.containsKey('coordinate') ? a['coordinate'] : null,
      addressableType:
          a.containsKey('addressable_type') ? a['addressable_type'] : null,
      addressableID:
          a.containsKey('addressable_id') ? a['addressable_id'] : null,
      createdAt: a.containsKey('created_at') ? a['created_at'] : null,
      updatedAt: a.containsKey('updated_at') ? a['updated_at'] : null,
    );
  }

  String asString() {
    List<String> parts = List<String>();
    if (street != null) {
      if (streetNumber != null) {
        parts.add('$street $streetNumber');
      }
    }
    if (city != null) {
      parts.add(city);
    }
    if (cityPart != null && cityPart != city) {
      parts.add(cityPart);
    }
    return parts.join(', ');
  }
}

class Volunteer {
  final int id;
  final String firstName, lastName, email, phone;
  final Address address;

  Volunteer(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.address});

  static Volunteer fromRawJson(String jsonData) {
    var v = json.decode(jsonData);
    return Volunteer(
      id: v.containsKey('id') ? v['id'] : null,
      firstName: v.containsKey('first_name') ? v['first_name'] : null,
      lastName: v.containsKey('last_name') ? v['last_name'] : null,
      email: v.containsKey('email') ? v['email'] : null,
      phone: v.containsKey('phone') ? v['phone'] : null,
      address: v.containsKey('address')
          ? Address.fromParsedJson(v['address'])
          : null,
    );
  }

  List<String> getNamesPhoneEmail() {
    List<String> r = List<String>();
    String first = firstName == null ? '' : firstName;
    String last = lastName == null ? '' : lastName;
    r.add(<String>[first, last].join(' '));
    r.add(phone != null ? phone : '');
    r.add(email != null ? email : '');
    return r;
  }
}

class VolunteerPreferences {
  final bool notificationsToApp;

  VolunteerPreferences({this.notificationsToApp});

  static VolunteerPreferences fromRawJson(String jsonData) {
    var v = json.decode(jsonData);
    return VolunteerPreferences(
      notificationsToApp: v.containsKey('notifications_to_app')
          ? v['notifications_to_app']
          : null,
    );
  }
}
