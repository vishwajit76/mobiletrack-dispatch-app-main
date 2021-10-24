import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/components/background.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/main_tabbar/main_tabbar.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/invalid_registration.dart';
class RegistrationScreen extends StatefulWidget {
  final Map companyInfo;

  const RegistrationScreen({Key? key, required this.companyInfo}) : super(key: key);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _firstName = '';
  String _lastName = '';
  String email = '';
  String password = '';
  String message = '';
  String passwordConfirm = '';
  bool isLoading = false;
  bool signUpError = false;
  late UserProvider userProvider;
  final _formKey = GlobalKey<FormState>();

  String get firstName => _firstName;
  String get lastName => _lastName;

  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    super.initState();
  }

  Future verifyEmailRole() async {
    return await AuthService.verifyEmailRole(email, userProvider.handle, 'dispatch');
  }

  Future _signUp() async {
    setState(() => isLoading = true);
    var res = await verifyEmailRole();
    if(res == false) {
      setState(() => isLoading = false);
      Navigator.push(context, MaterialPageRoute(builder: (context) => InvalidRegistration()));
    } else if(res.data['exists']) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password.trim()
        );
        userProvider.setRoles(res.data['roles']);
        userProvider.subUser(email);
        setState(() => isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainTabbar()));

      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false; signUpError = true; message = e.code;
        });
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.chevron_left),
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(height: size.height * .05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: double.infinity,
                            child:  CachedNetworkImage(
                              imageUrl: this.widget.companyInfo['logoUrl'],
                            ),
                          ),
                          SizedBox(
                            height: size.height * .03,
                          ),
                          if (signUpError)
                            Text(message, style: TextStyle(color: Colors.red)),
                          SizedBox(
                            height: size.height * .03,
                          ),
                          Container(
                            height: 55,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 2.5),
                                    child: TextFieldWidget(
                                      readOnly: false,
                                      textInputType: TextInputType.text,
                                      maxLines: 1,
                                      obscureText: false,
                                      initialValue: email,
                                      onChanged: (val) => _firstName = val,
                                      validator: (val) => firstName.isEmpty ? 'Cannot be Empty' : null,
                                      labelText: 'First Name',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2.5),
                                    child: TextFieldWidget(
                                      readOnly: false,
                                      textInputType: TextInputType.text,
                                      maxLines: 1,
                                      obscureText: false,
                                      initialValue: email,
                                      onChanged: (val) => _lastName = val,
                                      validator: (val) => lastName.isEmpty ? "Cannot be Empty" : null,
                                      labelText: 'Last Name',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * .03,
                          ),
                          TextFieldWidget(
                            readOnly: false,
                            textInputType: TextInputType.text,
                            maxLines: 1,
                            obscureText: false,
                            initialValue: email,
                            onChanged: (val) => setState(() => email = val),
                            validator: (val) =>
                                !isEmail(val) ? 'Invalid Email' : null,
                            labelText: 'Email Address',
                          ),
                          SizedBox(
                            height: size.height * .03,
                          ),
                          TextFieldWidget(
                            readOnly: false,
                            textInputType: TextInputType.text,
                            maxLines: 1,
                            obscureText: true,
                            initialValue: email,
                            onChanged: (val) => setState(() => password = val),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                            labelText: 'Password',
                          ),
                          SizedBox(
                            height: size.height * .03,
                          ),
                          TextFieldWidget(
                            readOnly: false,
                            textInputType: TextInputType.text,
                            maxLines: 1,
                            obscureText: true,
                            initialValue: email,
                            onChanged: (val) => setState(() => passwordConfirm = val),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Please enter a password';
                              }
                              if(val != password) {
                                return 'Password doesnt not match';
                              }
                              return null;
                            },
                            labelText: 'Confirm Password',
                          ),
                          SizedBox(height: size.height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              
                              Container(
                                child: ElevatedButton(
                                  onPressed: _formKey.currentState!.validate() ? _signUp : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    child: Text('Sign Up'),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading) LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
