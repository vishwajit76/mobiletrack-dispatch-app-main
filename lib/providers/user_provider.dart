import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  List<String> _roles = [];
  String _handle = '';
  UserModel? _user;
  String _userEmail = '';
  bool _isLoading = false;

  get getUserInfo => _user;
  get getUserEmail => _userEmail;
  get isLoading => _isLoading;
  String get handle => _handle;
  List<String> get roles => _roles;

  void setRoles(List userRoles) {
    userRoles.forEach((e) => _roles.add(e));
    notifyListeners();
  }

  // Saving handle for future login

  Future getHandle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? res = prefs.getString('handle');
    if (res != null) _handle = res;
    notifyListeners();
  }

  Future setHandle(String handleInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('handle', handleInfo);
    _handle = handleInfo;
    notifyListeners();
  }

  // Subscribing to User details

  void subUser(String? email) {
    _userEmail = email!;
    Stream documentStream = FirebaseFirestore.instance.collection(handle + '/users/users').doc(email).snapshots();
    documentStream.listen((snapshot) {
      UserModel user = UserModel.fromSnapshot(snapshot);
      _user = user;
      notifyListeners();
    });
  }

  // Updating User details

  Future updateUserProfile(UserModel user) async {
    DocumentReference userDoc = FirebaseFirestore.instance.collection(handle + '/users/users/').doc(_userEmail);
    _isLoading = true;
    notifyListeners();

    return userDoc.update({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'photoUrl': user.photoUrl,
    }).then((value) {
      _isLoading = false;
      notifyListeners();
    });
  }
}
