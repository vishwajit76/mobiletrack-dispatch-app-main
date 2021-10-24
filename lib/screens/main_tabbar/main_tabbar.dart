import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/components/left_drawer.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/user_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/authentication/check_handle.dart';
import 'package:mobiletrack_dispatch_flutter/screens/customers/customers.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/schedule.dart';
import 'package:mobiletrack_dispatch_flutter/screens/service_requests/service_requests.dart';
import 'package:mobiletrack_dispatch_flutter/screens/settings/settings.dart';
import 'package:provider/provider.dart';

class MainTabbar extends StatefulWidget {
  @override
  _MainTabbarState createState() => _MainTabbarState();
}

class _MainTabbarState extends State<MainTabbar> {
  late UserProvider userProvider;
  late SettingsProvider settingsProvider;
  int _selectedIndex = 0;
  Image? profileImage;
  bool statusKey = false;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.subLocalSettings('hukills');
    settingsProvider.subGlobalSettings();
    ;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);

    // Once both Local and Global Settings are retrieved
    // Create Status Key
    if (settingsProvider.parentStatusTypes.isNotEmpty &&
        settingsProvider.workOrderCustomStatusTypes.isNotEmpty &&
        !statusKey) {
      setState(() => this.statusKey = true);
      settingsProvider.createStatusKey();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CheckHandle()));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            SchedulePage(),
            CustomersScreen(),
            ServiceRequests(),
            Settings(),
          ],
        ),
        drawer: Drawer(
          child: LeftDrawer(),
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            height: 76,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              iconSize: 30,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              unselectedItemColor: Colors.blue.shade200,
              selectedItemColor: Colors.white,
              items: [
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.calendar_today_rounded),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                ),
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.person),
                  activeIcon: Icon(Icons.person),
                ),
                BottomNavigationBarItem(
                    label: '',
                    icon: Icon(Icons.build),
                    activeIcon: Icon(
                      Icons.build,
                    )),
                BottomNavigationBarItem(
                  label: '',
                  icon: Icon(Icons.settings),
                  activeIcon: Icon(Icons.settings),
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
