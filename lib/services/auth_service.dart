import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future signIn(String email, String password) async {
    try {
      UserCredential res = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return {'complete': true, 'user': res, 'message': 'Complete'};
    } on FirebaseAuthException catch (e) {
      print('Error on Sign in: ${e.message}');
      return {'complete': false, 'user': null, 'message': e.message};
    }
  }

  static Future verifyEmailRole(String email, String handle, String appname) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('verifyEmailRole');
      HttpsCallableResult res = await callable.call({'handle': handle.trim(), 'email': email.trim(), 'appname': appname});
      return res;
    } on FirebaseFunctionsException catch (e) {
      print('Error executing function: ${e.message}');
      return false;
    }
  }

  static Future<Map> checkHandle(String handle) async {
    DocumentReference handleRef =
        FirebaseFirestore.instance.collection('companies').doc(handle.trim());
    var doc = await handleRef.get();
    if (doc.exists) {
      return {'success': true, 'companyInfo': doc.data()};
    }
    return {'success': false, 'companyInfo': null};
  }
}
