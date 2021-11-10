import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/providers/customers_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/schedule_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/service_request_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/check_authentication.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return SomethingWrong();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              // Provider<UserProvider>(create: (_) => UserProvider()),
              // Provider<CustomersProvider>(create: (_) => CustomersProvider()),
              // Provider<ServiceRequestProvider>(
              //     create: (_) => ServiceRequestProvider()),
              // Provider<SettingsProvider>(create: (_) => SettingsProvider()),
              // Provider<ScheduleProvider>(create: (_) => ScheduleProvider()),

              ChangeNotifierProvider(create: (context) => UserProvider()),
              ChangeNotifierProvider(create: (context) => CustomersProvider()),
              ChangeNotifierProvider(
                  create: (context) => ServiceRequestProvider()),
              ChangeNotifierProvider(create: (context) => SettingsProvider()),
              //ChangeNotifierProvider(create: (context) => ScheduleProvider()),

              ChangeNotifierProvider<ScheduleProvider>(
                create: (BuildContext context) => ScheduleProvider(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mobile Track Dispatch',
              theme: ThemeData(
                primarySwatch: Colors.green,
                textTheme: TextTheme(),
              ),
              home: CheckAuthentication(),
            ),
          );
        }
        return LoadingOverlay();
      },
    );
  }
}

class SomethingWrong extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Container(
            child: Text('Error!'),
          ),
        ),
      ),
    );
  }
}
