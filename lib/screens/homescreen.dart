import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Center(child: Text('Home Screen', style: TextStyle(fontSize: 20.0),))
        ],
      ),
    );
  }
}