import 'package:cloud_firestore/cloud_firestore.dart';

class ContactService {
  
  static getContact(handle, id) async {
    DocumentSnapshot contactDoc = await FirebaseFirestore.instance
        .collection('$handle/contacts/contacts/')
        .doc(id)
        .get();
    return contactDoc.data();
  }
}
