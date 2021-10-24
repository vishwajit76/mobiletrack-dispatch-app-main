import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkOrder {
  String id;
  String displayName;
  String? customId;
  String description;
  String serviceRequestId;
  String statusId;
  String technicianId;
  Timestamp created;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Timestamp startDate;
  Timestamp endDate;
  Timestamp modified;
  List? dates;
  String? invoicingMemo;
  bool? deleted;
  
  WorkOrder({
    required this.id,
    required this.displayName,
    required this.description,
    required this.serviceRequestId,
    required this.statusId,
    required this.technicianId,
    required this.created,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
    required this.modified,
    this.dates,
    this.customId,
    this.invoicingMemo,
    this.deleted
  });

  factory WorkOrder.fromSnapshot(DocumentSnapshot doc) {

    Map data = doc.data() as Map;
    DateFormat formatter = DateFormat('Hm');

    var startTimeParse = formatter.format(data['startDate'].toDate()).split(':');
    var endTimeParse = formatter.format(data['endDate'].toDate()).split(':');

    TimeOfDay startTime = TimeOfDay(hour: int.parse(startTimeParse[0]), minute: int.parse(startTimeParse[1]));
    TimeOfDay endTime = TimeOfDay(hour: int.parse(endTimeParse[0]), minute: int.parse(endTimeParse[1]));
    
    return WorkOrder(
      id: doc.id,
      displayName: data['_displayName'] ?? '',
      created: data['created'] as Timestamp,
      customId: data['customId'] ?? null,
      dates: data['dates'] ?? null,
      description: data['description'] ?? '',
      startTime: startTime,
      endTime: endTime,
      startDate: data['startDate'] as Timestamp,
      endDate: data['endDate'] as Timestamp,
      invoicingMemo: data['invoicingMemo'] ?? null,
      modified: data['modified'] as Timestamp,
      serviceRequestId: data['serviceRequestId'] as String,
      statusId: data['statusId'] as String,
      deleted: data['deleted'] ?? null,
      technicianId: data['technicianId'] as String
    );

  }
  
}
