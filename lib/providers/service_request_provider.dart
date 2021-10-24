import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/models/customer_model.dart';
import 'package:mobiletrack_dispatch_flutter/services/elastic_search.dart';
import 'package:mobiletrack_dispatch_flutter/models/service_request_model.dart';


class ServiceRequestProvider extends ChangeNotifier {
  ServiceRequestModel? _serviceRequest;
  
  
  CustomerModel? _customer;
  List<dynamic> _hits = [];
  bool _isLoading = false;
  String handle = 'hukills';

  get hits => _hits;
  get customer => _customer;
  get serviceRequest => _serviceRequest;
  get isLoading => _isLoading;

  void loading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  subServiceRequest(String handle, String id) {
    _serviceRequest = null;
    _customer = null;
    Stream documentStream = FirebaseFirestore.instance
        .collection('$handle/service-requests/service-requests')
        .doc(id)
        .snapshots();
    documentStream.listen((snapshot) {
      ServiceRequestModel serviceRequest = ServiceRequestModel.fromSnapshot(snapshot);
      _serviceRequest = serviceRequest;
      notifyListeners();
    });
  }

  subCustomer(String handle, String id) {
    _customer = null;
    Stream documentStream = FirebaseFirestore.instance
        .collection('$handle/customers/customers')
        .doc(id)
        .snapshots();
    documentStream.listen((snapshot) {
      CustomerModel customer = CustomerModel.fromSnapshot(snapshot);
      _customer = customer;
      notifyListeners();
    });
  }

  nextServiceRequestId(handle) async {
    DocumentSnapshot serviceRequestDoc = await FirebaseFirestore.instance
        .collection('$handle')
        .doc('service-requests')
        .get();
    Map data = serviceRequestDoc.data() as Map;
    await FirebaseFirestore.instance
        .collection('$handle')
        .doc('service-requests')
        .update({
      'nextServiceRequestId': data['nextServiceRequestId'] + 1
    });
    return data['nextServiceRequestId'].toString();
  }

  newServiceRequest( String handle, ServiceRequestModel serviceRequestModel) async {
    loading(true);
    CollectionReference serviceRequestRef = FirebaseFirestore.instance.collection('$handle/service-requests/service-requests');
    
    var serviceRequestID = await nextServiceRequestId('hukills');
    serviceRequestModel.created = Timestamp.fromDate(new DateTime.now());
    serviceRequestModel.modified = Timestamp.fromDate(new DateTime.now());

    serviceRequestRef.doc(serviceRequestID).set({
      'modified': serviceRequestModel.modified,
      'created': serviceRequestModel.created,
      'displayName': serviceRequestModel.displayName,
      'customerId': serviceRequestModel.customerId,
      'dueDate': serviceRequestModel.dueDate,
      'endDate': serviceRequestModel.endDate,
      'summary': serviceRequestModel.summary,
      'description': serviceRequestModel.description,
    }).then((res) {
      loading(false);
    });
  }

  updateServiceRequest(String handle, ServiceRequestModel serviceRequestModel) {
    DocumentReference serviceRequestDoc = FirebaseFirestore.instance
        .collection('$handle/service-requests/service-requests')
        .doc(serviceRequestModel.id);

    return serviceRequestDoc.update({
      'customerId': serviceRequestModel.customerId,
      'startDate': serviceRequestModel.startDate,
      'endDate': serviceRequestModel.endDate,
      'summary': serviceRequestModel.summary,
      'description': serviceRequestModel.description,
    });
  }

  getServiceRequests(String query) async {
    _hits.clear();

    Map config = {
      'table': 'hukills-service-requests',
      'fields': ['id', 'customId', 'displayName', 'summary', 'description'],
      'sort': [
        {"customId": "desc"}
      ]
    };

    var data = await ElasticSearch.search(query, config);

    data.map((dynamic item) {
      _hits.add({...item['_source'], 'id': item['_id']});
    }).toList();
    notifyListeners();
  }
}
