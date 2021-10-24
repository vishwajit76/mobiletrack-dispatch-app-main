import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  String id;
  String displayName;
  String addressId;
  String customerId;
  Timestamp created;
  String customId;
  bool deleted;
  String description;
  Timestamp dueDate;
  Timestamp endDate;
  var isTimeSet;
  Timestamp modified;
  String salespersonId;
  Timestamp startDate;
  String statusId;
  String summary;

  ServiceRequestModel({
    required this.id,
    required this.displayName,
    required this.customerId,
    required this.addressId,
    required this.created,
    required this.customId,
    required this.deleted,
    required this.description,
    required this.dueDate,
    required this.endDate,
    required this.isTimeSet,
    required this.modified,
    required this.salespersonId,
    required this.startDate,
    required this.statusId,
    required this.summary
  });
  factory ServiceRequestModel.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ServiceRequestModel(
      id: doc.id,
      displayName: data['_displayName'] ?? '',
      customerId: data['customerId'],
      addressId: data['addressId'] ?? '',
      created: data['created'] ?? '',
      customId: data['customId'] ?? '',
      deleted: data['deleted'] ?? false,
      description: data['description'] ?? '',
      dueDate: data['dueDate'] ?? '',
      endDate: data['endDate'] ?? '',
      isTimeSet: data['isTimeSet'] ?? '',
      modified: data['modified'] ?? '',
      salespersonId: data['salespersonId'] ?? '',
      startDate: data['startDate'] ?? Timestamp.now(),
      statusId: data['statusId'] ?? '',
      summary: data['summary'] ?? '',
    );
  }
}
