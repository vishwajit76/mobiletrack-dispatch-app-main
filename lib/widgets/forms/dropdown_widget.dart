import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';

class DropDownFormWidget extends StatelessWidget {
  final List<String> items;
  final String value;
  final onChanged;
  final validator;
  final String labelText;

  DropDownFormWidget({
      required this.items,
      required this.value,
      required this.onChanged,
      required this.validator,
      required this.labelText
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black87,
          ),
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
        isExpanded: true,
        validator: validator,
        selectedItemBuilder: (context) {
          return items.map((String item) {
            return Text(item);
          }).toList();
        },
        items: items.map(
          (String item) {
            return DropdownMenuItem(
              child: Text(item),
              value: item,
            );
          },
        ).toList(),
        value: value,
        onChanged: onChanged);
  }
}
