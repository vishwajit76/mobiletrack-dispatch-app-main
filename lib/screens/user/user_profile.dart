import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/models/user_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/forms/textfield_widget.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late UserProvider userProvider;
  final _formKey = GlobalKey<FormState>();
  String photoUrl = '';
  String firstName = '';
  String lastName = '';
  bool photoUploaded = false;
  
  @override
  void initState() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    photoUrl = userProvider.getUserInfo.photoUrl;
    firstName = userProvider.getUserInfo.firstName;
    lastName = userProvider.getUserInfo.lastName;
    super.initState();
  }


  submitForm() {
      UserModel user = UserModel(
        id: userProvider.getUserInfo.id,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );
      userProvider.updateUserProfile(user);
      Navigator.pop(context);
  }

  getAvatar() {
    final user = userProvider.getUserInfo;
    if (user.photoUrl.isNotEmpty) {
      return SizedBox(width: 0);
    }
    return Icon(
      Icons.person,
      size: 70,
    );
  }

  getBackground() {
    final user = userProvider.getUserInfo;
    if (user.photoUrl.isNotEmpty) {
      return NetworkImage(user.photoUrl);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: getBackground(),
                                    radius: 100,
                                    child: getAvatar()
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * .01,
                        ),
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        TextFieldWidget(
                          readOnly: false,
                          textInputType: TextInputType.text,
                          maxLines: 1,
                          obscureText: false,
                          initialValue: firstName,
                          onChanged: (val) {
                            setState(() => firstName = val);
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Field cannot be empty!';
                            }
                            return null;
                          },
                          labelText: 'First Name',
                        ),
                        SizedBox(height: size.height * 0.03),
                        TextFieldWidget(
                          readOnly: false,
                          textInputType: TextInputType.text,
                          maxLines: 1,
                          obscureText: false,
                          initialValue: lastName,
                          onChanged: (val) {
                            setState(() => lastName = val);
                          },
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Field cannot be empty!';
                            }
                            return null;
                          },
                          labelText: 'Last Name',
                        ),
                        SizedBox(height: size.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              child: ButtonWidget(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      submitForm();
                                    }
                                  },
                                  text: 'Save',
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }
}
