import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/check_handle.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/user/user_profile.dart';
import 'package:mobiletrack_dispatch_flutter/services/upload_profile_image.dart';

class LeftDrawer extends StatefulWidget {
  @override
  _LeftDrawerState createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  UploadProfileImage uploadProfileImage = UploadProfileImage();
  late UserProvider userProvider;
  final ImagePicker _picker = ImagePicker();
  // late Image profileImage;
  File? _image;
  String photoUrl = '';
  late String userEmail;
  bool photoUploaded = false;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userEmail = userProvider.getUserEmail;
    super.initState();
  }

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadProfileImage.upload(_image!, userEmail);
        photoUploaded = true;
      } else {
        print('No Image Selected!');
      }
    });
  }

  void openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraCamera(
          onFile: (File file) {
            Navigator.pop(context);
            setState(
              () {
                if (file.path.isNotEmpty) {
                  _image = file;
                  uploadProfileImage.upload(_image!, userEmail);
                  photoUploaded = true;
                } else {
                  print('No Picture Taken!');
                }
              },
            );
          },
        ),
      ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CheckHandle()));
  }

  getAvatar() {
    // final user = userProvider.getUserInfo;
    // if (user.photoUrl.isNotEmpty || photoUploaded) {
    //   return SizedBox(width: 0);
    // }
    // return Icon(
    //   Icons.person,
    //   size: 70,
    // );
    return SizedBox(width: 0);
  }

  getBackground() {
    // final user = userProvider.getUserInfo;
    // if (user.photoUrl.isNotEmpty) {
    //   return NetworkImage(user.photoUrl);
    // }
    // if (photoUploaded) {
    //   return NetworkImage(_image!.absolute.path);
    // }
    // return null;
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(0),
            child: Container(
              height: 142,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 110,
                          width: 110,
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: new Border.all(
                                width: 1,
                                color: Colors.black,
                              )),
                          child: CircleAvatar(
                              child: getAvatar(),
                              backgroundColor: Colors.white,
                              backgroundImage: getBackground()),
                        ),
                        Text(userProvider.getUserInfo.firstName +
                            ' ' +
                            userProvider.getUserInfo.lastName)
                      ],
                    ),
                  ),
                  Positioned(
                    top: 70,
                    right: 80,
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: new Border.all(
                              width: 1,
                              color: Colors.black,
                            )),
                        child: Center(
                            child: PopupMenuButton(
                          onSelected: (val) {
                            if (val == 1) openCamera();
                            if (val == 2) getImage();
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: Text('Camera'),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: Text('Gallery'),
                                value: 2,
                              )
                            ];
                          },
                          child: Icon(Icons.add_a_photo, size: 20),
                        ))),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => UserProfile())),
          ),
          Divider(height: 4.0),
          ListTile(
            title: Text('Item 2'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Item 3'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Item 4'),
            onTap: () {},
          ),
          Divider(height: 4.0),
          ListTile(
            trailing: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => logout(),
          )
        ],
      ),
    );
  }
}
