import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/models/customer_model.dart';
import 'package:mobiletrack_dispatch_flutter/models/service_request_model.dart';
import 'package:mobiletrack_dispatch_flutter/services/elastic_search.dart';

class CustomersProvider extends ChangeNotifier {
  
  List<dynamic> _hits = [];
  CustomerModel? _customer;
  
  List<ServiceRequestModel> _serviceRequests = [];
  StreamSubscription? serviceRequestsStream;
  
  bool _isLoading = false;

  get hits => _hits;
  get customer => _customer;
  get isLoading => _isLoading;
  get serviceRequests => _serviceRequests;

  void loading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  subCustomer(handle, id) {
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

  subServiceRequestsByCustomer(String handle, String id) {
    _serviceRequests.clear();
    serviceRequestsStream = FirebaseFirestore.instance
        .collection('$handle/service-requests/service-requests').where('customerId', isEqualTo: id )
        .snapshots()
        .listen((snapshot) { 
          snapshot.docs.forEach((doc) { 
            _serviceRequests.add( ServiceRequestModel.fromSnapshot(doc) );
          });
          notifyListeners();
        });
  }

  //*** ELASTIC SEARCH ACTIONS */

  createHitsList(data) {
    _hits.clear();
    data.map((dynamic item) {
      _hits.add({...item['_source'], 'id': item['_id']});
    }).toList();
    notifyListeners();
  }

  getCustomers(String query) async {
    Map config = {
      'table': 'hukills-customers',
      'fields': ['displayName', 'customerName', 'addresses', 'contacts'],
      'sort': [
        {'modified': 'desc'},
        {'displayName': 'desc'}
      ]
    };
    var data = await ElasticSearch.search(query, config);
    createHitsList(data);
  }

  //*** CUSTOMER SAVE ACTIONS */

  nextCustomerId(handle) async {
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance
        .collection('$handle')
        .doc('customers')
        .get();
    Map doc = customerDoc.data() as Map;
    await FirebaseFirestore.instance
        .collection('$handle')
        .doc('customers')
        .update({'nextCustomerId': doc['nextCustomerId'] + 1});
    return doc['nextCustomerId'].toString();
  }

  nextAddressId(handle) async {
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance
        .collection('$handle')
        .doc('addresses')
        .get();
     Map doc = customerDoc.data() as Map;
    await FirebaseFirestore.instance
        .collection('$handle')
        .doc('addresses')
        .update({'nextAddressId': doc['nextAddressId'] + 1});
    return doc['nextAddressId'].toString();
  }

  nextContactId(handle) async {
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance
        .collection('$handle')
        .doc('contacts')
        .get();
    Map doc = customerDoc.data() as Map;
    await FirebaseFirestore.instance
        .collection('$handle')
        .doc('contacts')
        .update({'nextContactId': doc['nextContactId'] + 1});
    return doc['nextContactId'].toString();
  }

  createCustomer(handle, customer, Map customerAddress, Map contact) async {
    loading(true);
    CollectionReference customerRef =FirebaseFirestore.instance.collection('$handle/customers/customers/');
    var batch = FirebaseFirestore.instance.batch();

    var customerId = await nextCustomerId('hukills');
    var addressId = await nextAddressId('hukills');
    var contactId = await nextContactId('hukills');

    // ----------Contact Info ------------------------
    CollectionReference contactRef = FirebaseFirestore.instance.collection('$handle/contacts/contacts/');
    contact['contactId'] = contactId;
    contact['customerIds'] = [customerId];
    contact['deleted'] = false;
    contact['created'] = Timestamp.fromDate(new DateTime.now());
    contact['modified'] = Timestamp.fromDate(new DateTime.now());
    batch.set(contactRef.doc(contactId), {...contact}, SetOptions(merge: true));

    // ----------Address Info ------------------------
    CollectionReference addressRef =
        FirebaseFirestore.instance.collection('$handle/addresses/addresses/');
    customerAddress['addressId'] = addressId;
    customerAddress['customerIds'] = [customerId];
    customerAddress['contactIds'] = [contactId];
    customerAddress['deleted'] = false;
    customerAddress['created'] = Timestamp.fromDate(new DateTime.now());
    customerAddress['modified'] = Timestamp.fromDate(new DateTime.now());
    batch.set(addressRef.doc(addressId), {...customerAddress},
        SetOptions(merge: true));

    // ----------Customer Info ------------------------
    customer.addresses = [customerAddress];
    customer.contacts = [contact];
    customer.created = Timestamp.fromDate(new DateTime.now());
    customer.modified = Timestamp.fromDate(new DateTime.now());
    batch.set(
        customerRef.doc(customerId),
        {
          'addresses': customer.addresses,
          'contacts': customer.contacts,
          'appIds': customer.appIds,
          'companyName': customer.companyName,
          'created': customer.created,
          'customId': null,
          'customerTypeId': customer.customerTypeId,
          'deleted': customer.deleted,
          'displayName': customer.displayName,
          'isTaxable': customer.isTaxable,
          'modified': customer.modified,
          'notes': customer.notes,
          'quickbooksListId': null,
          'quickbooksNumber': null,
          'sourceTypeId': null,
          'taxCodeId': null,
          'taxNameId': null,
          'taxRate': null,
          'tierNumber': null
        },
        SetOptions(merge: true));

    batch.commit().then((res) {
      loading(false);
    }).catchError((onError) {
      print(onError);
    });
  }

  updateCustomer(handle, customer) {
    DocumentReference customerDoc = FirebaseFirestore.instance
        .collection('$handle/customers/customers/')
        .doc(customer.id);
    return customerDoc.update({
      'displayName': customer.displayName,
      'companyName': customer.companyName,
      'customerTypeId': customer.customerTypeId,
      'notes': customer.notes,
    });
  }
}
