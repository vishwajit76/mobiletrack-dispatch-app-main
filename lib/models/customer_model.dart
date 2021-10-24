import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String id;
  String displayName;
  String companyName;
  String notes;
  String taxRate;
  String customId;
  String taxCodeId;
  String sourceTypeId;
  String customerTypeId;
  String quickbooksListId;
  var tierNumber;
  var quickbooksNumber;
  var created;
  var modified;
  var appIds;
  var contacts;
  var addresses;
  bool deleted;
  var isTaxable;

  CustomerModel({
      required this.id,
      required this.addresses,
      required this.appIds,
      required this.companyName,
      required this.contacts,
      required this.created,
      required this.customId,
      required this.customerTypeId,
      required this.deleted,
      required this.displayName,
      required this.isTaxable,
      required this.modified,
      required this.notes,
      required this.quickbooksListId,
      required this.quickbooksNumber,
      required this.sourceTypeId,
      required this.taxCodeId,
      required this.taxRate,
      required this.tierNumber
  });
  factory CustomerModel.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CustomerModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      companyName: data['companyName'] ?? '',
      notes: data['notes'] ?? '',
      taxRate: data['taxRate'] ?? '',
      customId: data['customId'] ?? '',
      taxCodeId: data['taxCodeId'] ?? '',
      sourceTypeId: data['sourceTypeId'] ?? '',
      customerTypeId: data['customerTypeId'] ?? '',
      quickbooksListId: data['quickbooksListId'] ?? '',
      tierNumber: data['tierNumber'] ?? '',
      quickbooksNumber: data['quickbooksNumber'] ?? '',
      created: data['created'] ?? '',
      modified: data['modified'] ?? '',
      appIds: data['appIds'] ?? '',
      contacts: data['contacts'] ?? '',
      addresses: data['addresses'] ?? '',
      deleted: data['deleted'] ?? '',
      isTaxable: data['isTaxable'] ?? '',
    );
  }
}
