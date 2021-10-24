import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:mobiletrack_dispatch_flutter/services/elastic_search.dart';

class TypeAheadWidget extends StatelessWidget {
  final TextEditingController typeAheadController;
  final String labelText;
  final validator;

  const TypeAheadWidget({ Key? key, required this.typeAheadController, required this.labelText, required this.validator }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: this.typeAheadController,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.black87),
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
        ),
        suggestionsCallback: (pattern) async {
          Map config = {
            'table': 'hukills-service-requests',
            'fields': ['id', 'customId', 'displayName', 'summary', 'description'],
            'sort': [
              {"displayName": "asc"}
            ]
          };
          if(pattern == '') {
            return [];
          }
          return await ElasticSearch.search(pattern, config);
        }, 
        itemBuilder: (context, dynamic suggestion) {
          var item = suggestion['_source'];
          return Container(
            margin: EdgeInsets.all(5.0),
            child: ListTile(
              leading: Icon(Icons.person, size: 14.0,),
              title: Text(item['displayName']),
            )
          );
        },
        onSuggestionSelected: (dynamic suggestion) {
          var item = suggestion['_source'];
          this.typeAheadController.text = item['id'];
        },
        noItemsFoundBuilder: (context) {
          return Text('No Items Found');
        },
        loadingBuilder: (context) {
          return Container(
            padding: EdgeInsets.all(20.0),
            width: double.infinity,
            height: 100,
            child: Center(child: CircularProgressIndicator())
          );
        },
        errorBuilder: (context, error) {
          return Text('Error: $error');
        },
        onSaved: (value) {
          print('Saved Value: $value');
        },
        validator: validator,
      ),
    );
  }
}