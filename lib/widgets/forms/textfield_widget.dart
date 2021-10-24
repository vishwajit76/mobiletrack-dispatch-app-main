import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final TextInputType textInputType;
  final int maxLines;
  final bool readOnly;
  final String initialValue;
  final onChanged;
  final validator;
  final String labelText;
  final bool obscureText;
  // final FocusNode focusNode;

  TextFieldWidget({
    required this.readOnly,
    required this.textInputType,
    required this.maxLines,
    required this.obscureText,
    required this.initialValue,
    required this.onChanged,
    required this.validator,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      keyboardType: textInputType,
      maxLines: maxLines,
      initialValue: initialValue,
      obscureText: obscureText,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
            color: Colors.transparent,
            width: 0.0,
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
      textCapitalization: TextCapitalization.none,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
