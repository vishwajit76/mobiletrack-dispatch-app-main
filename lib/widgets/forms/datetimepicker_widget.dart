import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';

class DateTimePickerWidget extends StatelessWidget {
  final validator;
  final DateFormat format;
  final onChanged;
  final DateTime? initialValue;
  final String labelText;

  final bool isDate;

  DateTimePickerWidget(
      {Key? key,
      this.isDate = true,
      required this.format,
      required this.onChanged,
      required this.initialValue,
      required this.labelText,
      required this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      validator: validator,
      format: format,
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: labelText,
        labelStyle: TextStyle(),
        fillColor: Colors.white,
        filled: true,
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: AppTheme.red,
          width: 2.0,
        )),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: AppTheme.red,
          width: 2.0,
        )),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.green,
            width: 2.0,
          ),
        ),
      ),
      onShowPicker: (context, currentValue) async {
        if (isDate) {
          return showDatePicker(
            context: context,
            initialDate: currentValue ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
        } else {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        }
      },
    );
  }
}
