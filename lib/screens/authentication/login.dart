import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/check_handle.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/invalid_registration.dart';
import 'package:mobiletrack_dispatch_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/components/background.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/forms/textfield_widget.dart';
import 'package:mobiletrack_dispatch_flutter/screens/main_tabbar/main_tabbar.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/registration.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/password_reset.dart';

class LoginScreen extends StatefulWidget {
  final Map companyInfo;

  const LoginScreen({required this.companyInfo});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Map companyInfo;
  String email = '';
  String password = '';
  String message = '';
  bool isLoading = false;
  bool signInError = false;
  late UserProvider userProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future login() async {
    setState(() => isLoading = true);
    var verify = await AuthService.verifyEmailRole(email, userProvider.handle, 'dispatch');

    if (verify == false) {
      setState(() => isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InvalidRegistration()));

    } else {
      userProvider.setRoles(verify.data['roles']);
      Map signInRes = await AuthService.signIn(email, password);

      if (signInRes['complete']) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainTabbar()));
      } else {
        setState(() {
          isLoading = false;
          signInError = true;
          message = signInRes['message'].code;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * .15,
                      ),
                      Container(
                          width: double.infinity,
                          height: 100,
                          child: CachedNetworkImage(
                              imageUrl: this.widget.companyInfo['logoUrl'])),
                      SizedBox(
                        height: size.height * .02,
                      ),
                      if (signInError)
                        Text(message, style: TextStyle(color: Colors.red)),
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
                            !isEmail(val.trim()) ? 'Invalid Email' : null,
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
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PasswordReset())),
                              child: Text('Forgot Password? Click Here'),
                            ),
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              }, //=> login()},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 15.0),
                                child: Text('Login'),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size.height * .03),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.black),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Container(
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegistrationScreen(
                                                companyInfo:
                                                    this.widget.companyInfo))),
                                child: Text('Register a New User'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.black),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Container(
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckHandle())),
                                child: Text('Change Handle'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading) LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('widget disposed!');
  }
}
