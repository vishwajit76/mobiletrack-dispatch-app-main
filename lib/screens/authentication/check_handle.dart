import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/components/background.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/login.dart';
import 'package:mobiletrack_dispatch_flutter/services/auth_service.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CheckHandle extends StatefulWidget {
  @override
  _CheckHandleState createState() => _CheckHandleState();
}

class _CheckHandleState extends State<CheckHandle> {
  bool error = false;
  bool isLoading = false;
  late String handle;
  late UserProvider userProvider;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    handle = userProvider.handle;
  }

  Future checkHandle() async {
    setState(() => isLoading = true);
    Map res = await AuthService.checkHandle(handle);

    if (res['success']) {
      userProvider.setHandle(handle);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(companyInfo: res['companyInfo'])));
    } else {
      setState(() => isLoading = false);
      setState(() => error = true);
      _formKey.currentState!.validate();
      print('This handle does not exists!');
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
                          height: 200,
                          child: Image.asset('assets/images/logo.png')),
                      SizedBox(
                        height: size.height * .03,
                      ),
                      SizedBox(
                        height: size.height * .03,
                      ),
                      TextFieldWidget(
                        readOnly: false,
                        textInputType: TextInputType.text,
                        maxLines: 1,
                        obscureText: false,
                        initialValue: handle,
                        onChanged: (val) {
                          handle = val;
                          error = false;
                        },
                        validator: (val) {
                          if (handle.isEmpty) return 'Please enter a handle';
                          return error ? 'This handle does not exist!' : null;
                        },
                        labelText: 'Handle',
                      ),
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: AppTheme.green),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  checkHandle();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 15.0),
                                child: Text('Login'),
                              ),
                            ),
                          )
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
}
