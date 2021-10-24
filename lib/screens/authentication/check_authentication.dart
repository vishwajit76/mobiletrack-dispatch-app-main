import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/check_handle.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/main_tabbar/main_tabbar.dart';

class CheckAuthentication extends StatefulWidget {
  @override
  _CheckAuthenticationState createState() => _CheckAuthenticationState();
}

class _CheckAuthenticationState extends State<CheckAuthentication> {
  late UserProvider userProvider;
  bool isSignedIn = false;
  String? handle;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getHandle().then((res) => subAuthStateChanges());
  }

  subAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          isSignedIn = false;
        });
        print('User is currently signed out!');
      } else {
        userProvider.subUser(user.email);
        setState(() => isSignedIn = true);
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    var user = userProvider.getUserInfo;

    if (!isSignedIn) {
      return CheckHandle();
    }
    if (isSignedIn && user != null) {
      return MainTabbar();
    }
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.5),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
