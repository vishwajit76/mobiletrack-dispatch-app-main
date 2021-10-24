import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:mobiletrack_dispatch_flutter/models/customer_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/customers_provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/forms/textfield_widget.dart';

class CustomersForm extends StatefulWidget {
  final formType;
  final CustomerModel? customer;
  const CustomersForm({Key? key, required this.formType, this.customer})
      : super(key: key);
  @override
  _CustomersFormState createState() => _CustomersFormState();
}

class _CustomersFormState extends State<CustomersForm> {
  final _formKey = GlobalKey<FormState>();
  late CustomersProvider customersProvider;
  late SettingsProvider settingsProvider;
  late String formType;
  CustomerModel? customer;

  String id = '';
  String displayName = '';
  String customerTypeId = '';
  String companyName = '';
  String notes = '';
  // *** ADDRESS *** //
  String address = '';
  String secondaryAddress = '';
  String city = '';
  String state = '';
  String zip = '';
  // *** MAIN CONTACT *** //
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String mobile = '';

  late Map localSettings;
  List<String> dropdownOptions = [];
  List<String> stateOptions = [];

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    customersProvider = Provider.of<CustomersProvider>(context, listen: false);
    localSettings = settingsProvider.localSettings;
    formType = widget.formType;
    if (widget.customer != null) customer = widget.customer;
    populateForm(customer);
    super.initState();
  }

  populateForm(customer) {
    if (formType == 'edit') {
      displayName = customer.displayName;
      companyName = customer.companyName;
      customerTypeId = customer.customerTypeId;
      notes = customer.notes;
      localSettings['customerTypes'].map((item) {
        if (customerTypeId == item['id']) customerTypeId = item['name'];
        dropdownOptions.add(item['name']);
      }).toList();
    } else if (formType == 'new') {
      dropdownOptions.add('-select-');
      localSettings['customerTypes'].map((item) {
        dropdownOptions.add(item['name']);
      }).toList();

      stateOptions.add('-select-');
      state_options.forEach((key, value) {
        stateOptions.add(key);
      });
    }
  }

  submitForm() {
    // If Edit, Update only those fields
    if (formType == 'edit') {
      localSettings['customerTypes'].map((item) {
        if (customerTypeId == item['name']) customerTypeId = item['id'];
      }).toList();
      customer!.displayName = displayName;
      customer!.companyName = companyName;
      customer!.notes = notes;
      customer!.customerTypeId = customerTypeId;
      customersProvider.updateCustomer('hukills', customer).then((res) => Navigator.pop(context));
    }
    // If New Set All Fields
    if (formType == 'new') {
      localSettings['customerTypes'].map((item) {
        if (customerTypeId == item['name']) customerTypeId = item['id'];
      }).toList();
      state_options.forEach((key, value) {
        if (state == key) state = value;
      });
      Map customerAddress = {
        'addressLine1': address,
        'addressLine2': secondaryAddress,
        'city': city,
        'state': state,
        'zip': zip,
        'addressTypeId': '1',
      };
      Map contact = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'phone': phone,
        'contactTypeId': '2',
        'customerIds': []
      };
      CustomerModel customer = new CustomerModel(
          id: id,
          addresses: [],
          appIds: [],
          companyName: companyName,
          contacts: [],
          created: Timestamp.fromDate(new DateTime.now()),
          customId: '',
          customerTypeId: customerTypeId,
          deleted: false,
          displayName: displayName,
          isTaxable: false,
          modified: Timestamp.fromDate(new DateTime.now()),
          notes: notes,
          quickbooksListId: '',
          quickbooksNumber: '',
          sourceTypeId: '',
          taxCodeId: '',
          taxRate: '',
          tierNumber: '');
      customersProvider
          .createCustomer('hukills', customer, customerAddress, contact)
          .then((res) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomersProvider customersProvider = Provider.of<CustomersProvider>(context);
    final Size size = MediaQuery.of(context).size;
    if (formType == 'edit' && !customersProvider.isLoading) {
      return Scaffold(
          appBar: AppBar(title: Text('Customer Details')),
          body: Form(
            key: _formKey,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * .03,
                        ),
                        TextFieldWidget(
                          readOnly: false,
                          textInputType: TextInputType.text,
                          maxLines: 1,
                          obscureText: false,
                          initialValue: displayName,
                          onChanged: (val) => displayName = val,
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Please fill out this field';
                            }
                            return null;
                          },
                          labelText: 'Display Name*',
                        ),
                        SizedBox(
                          height: size.height * .02,
                        ),
                        DropDownFormWidget(
                            items: dropdownOptions,
                            value: dropdownOptions[0],
                            onChanged: (val) => customerTypeId = val,
                            validator: (val) {},
                            labelText: 'Customer Type ID*',
                        ),
                        SizedBox(height: size.height * .02),
                        TextFieldWidget(
                          readOnly: false,
                          textInputType: TextInputType.text,
                          maxLines: 1,
                          obscureText: false,
                          initialValue: companyName,
                          onChanged: (val) => companyName = val,
                          validator: (val) {},
                          labelText: 'Company Name',
                        ),
                        SizedBox(height: size.height * .02),
                        TextFieldWidget(
                          readOnly: false,
                          textInputType: TextInputType.text,
                          maxLines: 3,
                          obscureText: false,
                          initialValue: notes,
                          onChanged: (val) => notes = val,
                          validator: (val) {},
                          labelText: 'Notes',
                        ),
                        SizedBox(height: size.height * .02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ButtonWidget(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  submitForm();
                                }
                              },
                              text: 'Edit Form',
                            ),
                            SizedBox(
                              width: size.width * .02,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (customersProvider.isLoading) LoadingOverlay()
              ],
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Customer',
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * .03,
                    ),
                    Text('Customer Information',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0,
                        ),
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: displayName,
                      onChanged: (val) => displayName = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'Display Name*',
                    ),
                    SizedBox(
                      height: size.height * .02,
                    ),
                    DropDownFormWidget(
                        items: dropdownOptions,
                        value: dropdownOptions[0],
                        onChanged: (val) => customerTypeId = val,
                        validator: (val) {
                          if (val == '-select-') {
                            return 'Please choose an option!';
                          }
                          return null;
                        },
                        labelText: 'Customer Type ID*'),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: companyName,
                      onChanged: (val) => companyName = val,
                      validator: (val) {},
                      labelText: 'Company Name',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 3,
                      obscureText: false,
                      initialValue: notes,
                      onChanged: (val) => notes = val,
                      validator: (val) {},
                      labelText: 'Notes',
                    ),
                    SizedBox(height: size.height * .03),
                    Text('Service Address',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0,
                        ),
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: address,
                      onChanged: (val) => address = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'Address*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: secondaryAddress,
                      onChanged: (val) => secondaryAddress = val,
                      validator: (val) {},
                      labelText: 'Secondary Address',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: city,
                      onChanged: (val) => city = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'City*',
                    ),
                    SizedBox(height: size.height * .02),
                    DropDownFormWidget(
                      items: stateOptions,
                      value: stateOptions[0], // TODO: correct
                      onChanged: (val) => state = val,
                      validator: (val) {
                        if (val == '-select-') {
                          return 'Please choose an option!';
                        }
                        return null;
                      },
                      labelText: 'State*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.number,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: zip,
                      onChanged: (val) => zip = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'Zip Code*',
                    ),
                    SizedBox(height: size.height * .03),
                    Text('Main Contact',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0,
                        ),
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: firstName,
                      onChanged: (val) => firstName = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'First Name*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: lastName,
                      onChanged: (val) => lastName = val,
                      validator: (val) {
                        if (val.isEmpty) {
                          return 'Please fill out this field';
                        }
                        return null;
                      },
                      labelText: 'Last Name*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.emailAddress,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: email,
                      onChanged: (val) => email = val,
                      validator: (val) => !isEmail(val) ? 'Invalid Email' : null,
                      labelText: 'Email Address*',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.number,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: phone,
                      onChanged: (val) => phone = val,
                      validator: (val) {},
                      labelText: 'Phone',
                    ),
                    SizedBox(height: size.height * .02),
                    TextFieldWidget(
                      readOnly: false,
                      textInputType: TextInputType.number,
                      maxLines: 1,
                      obscureText: false,
                      initialValue: mobile,
                      onChanged: (val) => mobile = val,
                      validator: (val) {},
                      labelText: 'Mobile',
                    ),
                    SizedBox(height: size.height * .02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ButtonWidget(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              submitForm();
                            }
                          },
                          text: 'Create Customer',
                        ),
                        SizedBox(
                          width: size.width * .02,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (customersProvider.isLoading) LoadingOverlay()
        ],
      ),
    );
  }
}
