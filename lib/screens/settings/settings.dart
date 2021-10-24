import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/components/left_drawer.dart';
import 'package:mobiletrack_dispatch_flutter/components/status_key.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: Center(
          child: Text('Settings'),
        ),
        leading: Builder(
          builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        actions: [
          SizedBox(width: 50)
        ],
      ),
      drawer: Drawer(
        child: LeftDrawer(),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          ],
        ),
      )
    );
  }
}