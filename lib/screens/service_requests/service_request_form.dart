import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/models/service_request_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/service_request_provider.dart';


class ServiceRequestForm extends StatefulWidget {
  final formType;
  final ServiceRequestModel? serviceRequest;

  const ServiceRequestForm({Key? key, required this.formType, this.serviceRequest}) : super(key: key);
  @override
  _ServiceRequestFormState createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late String formType;
  ServiceRequestModel? serviceRequest;
  TextEditingController? typeAheadController;
  late ServiceRequestProvider serviceRequestProvider;
  String customerId = '';
  Timestamp? startDate;
  Timestamp? endDate;
  String summary = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    formType = widget.formType;
    if(widget.serviceRequest != null) serviceRequest = widget.serviceRequest;
    serviceRequestProvider = Provider.of<ServiceRequestProvider>(context, listen: false);
    populateForm(serviceRequest);
  }

  void populateForm(serviceRequest){
    if(formType == 'edit') {
      customerId = serviceRequest.customerId;
      startDate = serviceRequest.startDate;
      endDate = serviceRequest.endDate;
      summary = serviceRequest.summary;
      description = serviceRequest.description;
    }
    if(formType == 'new') {
      typeAheadController = TextEditingController();
    }
  }

  submitForm() {
    if(formType == 'edit') {
      serviceRequest!.customerId = customerId;
      serviceRequest!.startDate = startDate!;
      serviceRequest!.endDate = endDate!;
      serviceRequest!.summary = summary;
      serviceRequest!.description = description;
      serviceRequestProvider.updateServiceRequest('hukills', serviceRequest!).then((res) => Navigator.pop(context));
    }
    else {
      ServiceRequestModel serviceRequest = new ServiceRequestModel(
        id: '', 
        customerId: typeAheadController!.text,
        summary: summary,
        created: Timestamp.fromDate(new DateTime.now()), 
        modified: Timestamp.fromDate(new DateTime.now()),
        dueDate: Timestamp.fromDate(new DateTime.now()), 
        startDate: startDate!,
        endDate: endDate!,
        description: description,
        displayName: '', 
        addressId: '', 
        customId: '',
        deleted: false, 
        isTimeSet: false, 
        salespersonId: '', 
        statusId: '6', 
      );
      serviceRequestProvider.newServiceRequest('hukills', serviceRequest).then((res) => Navigator.pop(context));
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: Text(formType == 'edit' ? 'Edit Service Request' : 'New Service Request'),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * .02),
                    if(formType == 'edit') TextFieldWidget(
                      readOnly: formType == 'edit' ? true : false,
                      textInputType: TextInputType.text, 
                      maxLines: 1, 
                      obscureText: false, 
                      initialValue: customerId, 
                      onChanged: (val) => customerId = val, 
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      }, 
                      labelText: 'Customer ID*'
                    ),
                    if(formType == 'new') TypeAheadWidget(
                      labelText: 'Customer ID*',
                      typeAheadController: typeAheadController!,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please select a Customer Id';
                        }
                      },
                    ),
                    SizedBox(height: size.height * .02),
                    DateTimePickerWidget(
                      format: DateFormat('MM-dd-yyyy'), 
                      onChanged: (val) => startDate = Timestamp.fromDate(val),
                      validator: (val) {
                        if (val == null) {
                          return 'Please fill out this field';
                        }
                        return null;
                      }, 
                      initialValue: formType == 'edit' ? DateTime.fromMillisecondsSinceEpoch( startDate!.seconds * 1000 ) : null, 
                      labelText: 'Start Date*',
                    ),
                    SizedBox(height: size.height * .02),
                    DateTimePickerWidget(
                      format: DateFormat('MM-dd-yyyy'), 
                      onChanged: (val) => endDate = Timestamp.fromDate(val),
                      validator: (val) {
                        if (val == null) {
                          return 'Please fill out this field';
                        }
                        return null;
                      }, 
                      initialValue: formType == 'edit' ? DateTime.fromMillisecondsSinceEpoch( endDate!.seconds * 1000 ) : null, 
                      labelText: 'End Date*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text, 
                      maxLines: 3, 
                      obscureText: false, 
                      initialValue: summary, 
                      onChanged: (val) => summary = val, 
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      }, 
                      labelText: 'Summary*'
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text, 
                      maxLines: 5, 
                      obscureText: false, 
                      initialValue: description, 
                      onChanged: (val) => description = val, 
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      }, 
                      labelText: 'Description*'
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ButtonWidget(
                          onPressed: () { 
                            if (_formKey.currentState!.validate()) {
                              submitForm();
                            }
                          }, 
                          text: formType == 'edit' ? 'Save Changes' : 'Create Request'
                        ),
                        SizedBox(width: size.width * .02)
                      ],
                    )
                  ],
                ),
              ),
            )
          ),
          if (serviceRequestProvider.isLoading) LoadingOverlay()
        ],
      )
    );
  }
}