import 'package:flutter/material.dart';

import 'model.dart';
import 'dart:math';

// This is test data that we just filled the app with, so that we could have a
// demo without the backend.

List<Skill> SKILLS = [
  Skill(name: "Zdravotník", icon: Icons.healing, id: 0),
  Skill(name: "Řidič", icon: Icons.directions_car, id: 1),
  Skill(name: "Pečovatel", icon: Icons.transfer_within_a_station, id: 2),
];

List<Organization> ORGANIZATIONS = [
  Organization(
      name: "Nemocnice Motol",
      ic: "12345",
      contactName: "Jan Novák",
      contactPhone: "123456789",
      contactEmail: "test@example.com",
      slug: "FNM"),
  Organization(
      name: "Červený kříž",
      ic: "789799",
      contactName: "Joe Example",
      contactPhone: "222333444",
      contactEmail: "kriz@example.com",
      slug: "CEK"),
  Organization(
      name: "Diakonie Praha",
      ic: "97876",
      contactName: "Jana Nováková",
      contactPhone: "567567576",
      contactEmail: "diakonie@example.com",
      slug: "DIA"),
];

Organization getRandomOrganization({int seed = 1}) {
  Random r = Random(seed);
  return ORGANIZATIONS[r.nextInt(ORGANIZATIONS.length)];
}

Volunteer getRandomVolunteer({int seed = 1}) {
  Random r = Random(seed);
  List<String> firstNames = ["Petr", "Pavel", "Jan", "Jiří", "Josef"];
  List<String> lastNames = ["Novák", "Svoboda", "Dvořák", "Černý", "Procházka"];
  List<String> phones = ["123456789", "123765213", "987234873"];
  List<String> streets = ["Kaprova", "Palackého", "Dejvická"];
  List<String> streetNumbers = ["1", "100/2", "10", "1234/12", "30"];
  List<String> cities = ["Praha", "Brno", "Ostrava"];
  List<String> cityParts = ["Dejvice", "Braník", "Karlín"];

  return Volunteer(
    firstName: firstNames[r.nextInt(firstNames.length)],
    lastName: lastNames[r.nextInt(lastNames.length)],
    phone: phones[r.nextInt(phones.length)],
    street: streets[r.nextInt(streets.length)],
    streetNumber: streetNumbers[r.nextInt(streetNumbers.length)],
    city: cities[r.nextInt(cities.length)],
    cityPart: cityParts[r.nextInt(cityParts.length)],
    skillIDs: [r.nextInt(SKILLS.length)].toSet(),
  );
}

Task getRandomTask({int id, int seed = 1, bool isMine = false}) {
  Random r = Random(seed);
  List<String> descriptions = [
    "Vyzvednout nákup",
    "Pomoci na ambulanci",
    "Vyvenčit psa staré paní",
    "Provádět testy v nemocnici"
  ];
  List<Skill> skills = [SKILLS[1], SKILLS[0], SKILLS[2], SKILLS[0]];
  List<String> firstNames = ["Jana", "Petra", "Lucie"];
  List<String> lastNames = ["Nováková", "Křížová", "Novotná", "Čápopvá"];
  List<String> phones = ["645645455", "543543543", "765765765"];
  int vols = r.nextInt(3) + 1;
  int volsBooked = r.nextInt(vols + 1);
  List<String> addresses = [
    "Vlachova 1502, Praha 13-Stodůlky",
    "Václavské náměstí 1, Praha 1-Můstek",
    "nám. Jana Palacha 1/2, Praha, Staré Město",
  ];
  List<String> coordinators = ["Alice Doe", "Joe Smith", "John Black"];
  int descriptionID = r.nextInt(descriptions.length);
  List<String> when = ["17.3.2020, 18:00", "15.3.2020, 7:00", "Co nejdříve"];
  return Task(
    id: id,
    description: descriptions[descriptionID],
    volunteersRequired: vols,
    volunteersBooked: volsBooked,
    address: addresses[r.nextInt(addresses.length)],
    firstName: firstNames[r.nextInt(firstNames.length)],
    lastName: lastNames[r.nextInt(lastNames.length)],
    phone: phones[r.nextInt(phones.length)],
    coordinator: coordinators[r.nextInt(coordinators.length)],
    organization: getRandomOrganization(seed: seed),
    createdTs: 0,
    lastUpdatedTs: 0,
    skillRequired: skills[descriptionID],
    isMine: isMine,
    whenToDo: when[r.nextInt(when.length)],
  );
}
