import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  String id;
  String firstName;
  String lastName;
  String photoUrl;
  

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
        id: doc.id,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
    );
  }
}
