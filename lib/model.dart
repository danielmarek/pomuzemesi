import 'package:flutter/material.dart';

// NOTE: This is based on a preliminary idea about how the model is gonna look like,
// based on reading the spec. This is subject to a lot of changes.

// Dovednost, kterou muze dobrovolnik nabidnout.
class Skill {
  int id;
  String name;
  IconData icon;

  Skill({this.name, this.icon, this.id});
}

// Dobrovolnik.
class Volunteer {
  String firstName, lastName, phone;
  String street, streetNumber, city, cityPart;
  Set<int> skillIDs;

  // TODO geo, localities
  // TODO approved by org
  Volunteer(
      {this.firstName,
      this.lastName,
      this.phone,
      this.street,
      this.streetNumber,
      this.city,
      this.cityPart,
      this.skillIDs});
}

// Ukol.
class Task {
  int id;
  String description;
  int volunteersRequired, volunteersBooked;

  // TODO format
  String address;
  String firstName, lastName;
  String phone;

  // TODO coordinator may be a relation in the future.
  String coordinator;
  Organization organization;
  int createdTs, lastUpdatedTs;

  Skill skillRequired;

  // TODO - this was simplified for demo purposes, will have a list of
  //  volunteers instead.
  bool isMine;
  String whenToDo;

  Task({
    this.id,
    this.description,
    this.volunteersRequired,
    this.volunteersBooked,
    this.address,
    this.firstName,
    this.lastName,
    this.phone,
    this.coordinator,
    this.organization,
    this.createdTs,
    this.lastUpdatedTs,
    this.skillRequired,
    this.isMine,
    this.whenToDo,
  });
}

class Organization {
  String name, ic, contactName, contactPhone, contactEmail, slug;

  Organization(
      {this.name,
      this.ic,
      this.contactName,
      this.contactPhone,
      this.contactEmail,
      this.slug});
}
