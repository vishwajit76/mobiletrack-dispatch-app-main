import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Technician {
  String id;
  bool deleted;
  bool activated;
  String? carrierId;
  String color;
  String firstName;
  String lastName;
  String mobile;
  String originalId;
  Roles roles;
  Schedule schedule;

  Technician({
    required this.id,
    required this.deleted,
    required this.activated,
    required this.color,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.originalId,
    required this.roles,
    required this.schedule,
    this.carrierId,
  });

  factory Technician.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return Technician(
        id: doc.id,
        deleted: data['deleted'] ?? false,
        activated: true,
        //activated: data['activated'] ?? true,
        color: data['color'] ?? '',
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        mobile: data['mobile'] as String,
        originalId: data['originalId'] ?? '',
        roles: Roles.fromMap(data['roles']),
        schedule: Schedule.fromMap(data['schedule']));
  }
}

class Roles {
  List? dispatch;
  List? procurement;
  List? admin;

  Roles({this.dispatch, this.procurement, this.admin});

  factory Roles.fromMap(Map roles) {
    return Roles(
        dispatch: roles['dispatch'] ?? null,
        procurement: roles['procurement'] ?? null,
        admin: roles['admin'] ?? null);
  }
}

class Schedule {
  List<Day> days;

  Schedule({required this.days});

  factory Schedule.fromMap(Map schedule) {
    List<Day> days = [];

    schedule.forEach((index, day) => days.add(Day.fromMap(index, day)));

    return Schedule(days: days);
  }
}

class Day {
  int id;
  TimeOfDay start;
  TimeOfDay end;
  bool isWorkday;

  Day({
    required this.id,
    required this.start,
    required this.end,
    required this.isWorkday,
  });

  factory Day.fromMap(String index, Map day) {
    var start = day['start'].split(':');
    var end = day['end'].split(':');

    return Day(
        id: int.parse(index),
        start:
            TimeOfDay(hour: int.parse(start[0]), minute: int.parse(start[1])),
        end: TimeOfDay(hour: int.parse(end[0]), minute: int.parse(end[1])),
        isWorkday: day['isWorkday'] as bool);
  }
}
