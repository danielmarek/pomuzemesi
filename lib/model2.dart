import 'dart:convert';

// TODO: remove fields that are not explicitly used by this app?
// TODO: more detailed work for missing keys etc.
// TODO: model of organisation
// TODO: parse datetime

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
class Request2 {
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

  final String shortDescription;

  final String city;
  final String cityPart;
  final String address;

  final int organisationID;
  final DateTime fulfillmentDate;
  final int requiredVolunteerCount, acceptedVolunteerCount;
  final String createdAt, updatedAt;
  final String closedState;
  final String closedNote;
  final String coordinatorEmail;
  final String coordinatorFirstName;
  final String coordinatorLastName;
  final String subscriber;
  final String subscriberPhone;
  final bool allDetailsGranted;

  Request2({this.id, this.state, this.myState, this.shortDescription, this.city,
      this.cityPart, this.address, this.organisationID, this.fulfillmentDate,
      this.requiredVolunteerCount, this.acceptedVolunteerCount, this.createdAt,
      this.updatedAt, this.closedState, this.closedNote, this.coordinatorEmail,
      this.coordinatorFirstName, this.coordinatorLastName, this.subscriber,
      this.subscriberPhone, this.allDetailsGranted});

  static Request2 fromParsedJson(var r) {
    return Request2(
      id: r['id'],
      state: r['state'],
      myState: r['requested_volunteer_state'],
      shortDescription: r['short_description'],
      city: r['city'],
      cityPart: r['city_part'],
      address: r['address'],
      organisationID: r['organisation_id'],
      // NOTE: typo on the backend.
      fulfillmentDate: r['fullfillment_date'] != null ? DateTime.parse(r['fullfillment_date']) : null,
      requiredVolunteerCount: r['required_volunteer_count'],
      acceptedVolunteerCount: r['accepted_volunteer_count'],
      createdAt: r['created_at'],
      updatedAt: r['updated_at'],
      closedState: r['closed_state'],
      closedNote: r['closed_note'],
      coordinatorEmail: r['coordinator']['email'],
      coordinatorFirstName: r['coordinator']['first_name'],
      coordinatorLastName: r['coordinator']['last_name'],
      subscriber: r['subscriber'],
      subscriberPhone: r['subscriber_phone'],
      allDetailsGranted: r['all_details_granted'],
    );
  }

  static List<Request2> listFromRawJson(String jsonData) {
    List<Request2> l = List<Request2>();
    var parsedJson = json.decode(jsonData);
    for (int i = 0; i < parsedJson.length; i++) {
      var r = parsedJson[i];
      l.add(Request2.fromParsedJson(r));
    }
    return l;
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

class Address2 {
  final int id;
  final String street, streetNumber, city, cityPart, postalCode, countryCode;
  final String geoEntryID, geoUnitID, geoProvider, coordinate;
  final String addressableType;
  final int addressableID;
  final String createdAt, updatedAt;

  Address2({this.id, this.street, this.streetNumber, this.city,
      this.cityPart, this.postalCode, this.countryCode, this.geoEntryID,
      this.geoUnitID, this.geoProvider, this.coordinate, this.addressableType,
      this.addressableID, this.createdAt, this.updatedAt});

  static Address2 fromParsedJson(var a){
    return Address2(
        id: a['id'],
        street: a['street'],
        streetNumber: a['street_number'],
        city: a['city'],
        cityPart: a['city_part'],
        postalCode: a['postal_code'],
        countryCode: a['country_code'],
        geoEntryID: a['geo_entry_id'],
        geoUnitID: a['geo_unit_id'],
        geoProvider: a['geo_provider'],
        coordinate: a['coordinate'],
        addressableType: a['addressable_type'],
        addressableID: a['addressable_id'],
        createdAt: a['created_at'],
        updatedAt: a['updated_at'],
    );
  }
}

class Volunteer2 {
  final int id;
  final String firstName, lastName, email, phone;
  final Address2 address;

  Volunteer2({this.id, this.firstName, this.lastName, this.email,
      this.phone, this.address});

  static Volunteer2 fromRawJson(String jsonData) {
    var v = json.decode(jsonData);
    return Volunteer2(
      id: v['id'],
      firstName: v['first_name'],
      lastName: v['last_name'],
      email: v['email'],
      phone: v['phone'],
      address: Address2.fromParsedJson(v['address']),
    );
  }
}

class Preferences2 {
  final bool notificationsToApp;

  Preferences2({this.notificationsToApp});

  static Preferences2 fromRawJson(String jsonData) {
    var v = json.decode(jsonData);
    return Preferences2(
      notificationsToApp: v['notifications_to_app'],
    );
  }
}