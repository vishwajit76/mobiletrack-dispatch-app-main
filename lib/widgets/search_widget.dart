import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';

class SearchWidget extends StatelessWidget {

  final TextEditingController fieldText;
  final clearText;
  final search;
  const SearchWidget({Key? key, required this.fieldText, required this.search, required this.clearText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: fieldText,
        decoration: InputDecoration(
          prefixIcon: GestureDetector(
              child: Icon(Icons.search, color: Colors.black87)),
          suffixIcon: GestureDetector(
            child: Icon(Icons.clear, color: Colors.black87),
            onTap: () {
              clearText();
            },
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: 'Search',
          labelStyle: TextStyle(),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.red,
              width: 2.0,
            )
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.red,
              width: 2.0,
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:  Colors.transparent,
              width: 0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppTheme.green,
              width: 2.0,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        obscureText: false,
        onChanged: (val) {
          search(val);
        },
        validator: (val) {},
      ),
    );
  }
}