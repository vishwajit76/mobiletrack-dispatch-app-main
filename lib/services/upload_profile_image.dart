import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadProfileImage {
  String handle = 'hukills';

  upload(File image, userEmail) async {
    print('UPLOADING PROFILE IMAGE!');
    String filename = getFileName(image);
    File file = File(image.absolute.path);
    String fileUrl = await uploadImage(userEmail, filename, file);
    print('PROFILE IMAGE UPLOADED!');
    await uploadPhotoUrl(userEmail, fileUrl);
    print('PHOTO URL UPLOADED!');
  }

  String getFileName(File image) {
    List<String> hashFileName = image.path.split("/");
    String filename = hashFileName[hashFileName.length - 1];
    return filename;
  }

  uploadPhotoUrl(String userEmail, String fileUrl) async {
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('$handle/users/users/')
        .doc(userEmail);

    return userDoc.update({
      'photoUrl': fileUrl,
    });
  }

  uploadImage(String userEmail, String filename, File image) async {
    String fileUrl = '';
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('$handle/users/$userEmail/$filename')
          .putFile(image);
      fileUrl = await firebase_storage.FirebaseStorage.instance
          .ref('$handle/users/$userEmail/$filename')
          .getDownloadURL();
    } on FirebaseException catch (e) {
      print('Error!');
      print(e.message);
    }
    return fileUrl;
  }
}
