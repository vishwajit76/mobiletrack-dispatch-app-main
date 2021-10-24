import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:mobiletrack_dispatch_flutter/models/service_request_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/service_request_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/service_requests/service_request_form.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ServiceRequestDetails extends StatefulWidget {
  final hit;

  const ServiceRequestDetails({Key? key, this.hit}) : super(key: key);

  @override
  _ServiceRequestDetailsState createState() => _ServiceRequestDetailsState();
}


class _ServiceRequestDetailsState extends State<ServiceRequestDetails> {
  late var hit;
  late ServiceRequestProvider serviceRequestProvider;
  bool subCustomer = false;

  @override
  void initState() {
    super.initState();
    hit = widget.hit;
    serviceRequestProvider = Provider.of<ServiceRequestProvider>(context, listen: false);
    serviceRequestProvider.subServiceRequest('hukills', hit['id']);
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final serviceRequestProvider = Provider.of<ServiceRequestProvider>(context, listen: false);
    if(serviceRequestProvider.serviceRequest != null && subCustomer == false) {
      setState(() => subCustomer = true);
      serviceRequestProvider.subCustomer('hukills', serviceRequestProvider.serviceRequest.customerId);
    } 
  }

  @override
  void dispose() {
    super.dispose();
    print('WIDGET DISPOSED!');
  }
  
  @override
  Widget build(BuildContext context) {
    final serviceRequestProvider = Provider.of<ServiceRequestProvider>(context, listen: true);
    final Size size = MediaQuery.of(context).size;    

    if( serviceRequestProvider.serviceRequest == null || serviceRequestProvider.customer == null || serviceRequestProvider.isLoading ) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.green,
          title: Center(child: Text('Service Request ID #${hit['id']}', style: TextStyle( fontSize: 16.0)),),
          actions: [
            IconButton(
              icon: Icon(Icons.edit), 
              onPressed: () {},
            )
          ],
        ),
        body: Center( child: CircularProgressIndicator())
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: Center(child: Text('Service Request ID #${hit['id']}', style: TextStyle( fontSize: 16.0)),),
        actions: [
          IconButton(
            icon: Icon(Icons.edit), 
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ServiceRequestForm(formType: 'edit', serviceRequest: serviceRequestProvider.serviceRequest)));
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DashboardHeader(serviceRequest: serviceRequestProvider.serviceRequest),
              SizedBox(height: size.height *.02 ),
              // AddressesComponent(addresses: serviceRequestProvider.customer.addresses),
              SizedBox(height: size.height *.02 ),
              ContactsWidget(contacts: serviceRequestProvider.customer.contacts, addresses: serviceRequestProvider.customer.addresses),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactsWidget extends StatelessWidget {
  final contacts;
  final addresses;

  const ContactsWidget({ Key? key, required this.contacts, required this.addresses }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var filteredContacts = [...contacts];
    addresses.map((address) {
      contacts.map((contact) {
        if(address['contactIds'].contains(contact['contactId'])) {
          filteredContacts = filteredContacts.where((e) => e['contactId'] != contact['contactId']).toList();
        }
      }).toList();
    }).toList();

    if(filteredContacts.length >= 1) {
      return Container(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          final contact = contacts[index];
          return ContactComponent(contact: contact);
        },
        ),
      ); 
    }
    return Container(child: Text('-No Additional Contacts-', style: TextStyle(fontWeight: FontWeight.bold)));
  }
}


class ContactComponent extends StatelessWidget {
  final contact;

  const ContactComponent({Key? key, this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1,),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person),
              Text('Additional Contacts')
            ],
          ),
          Divider(height: 4),
          Column(
            children: [
              Text('${contact['firstName']} ${contact['lastName']} '),
              Text('${contact['phone']}'),
            ],
          )
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final ServiceRequestModel serviceRequest;
  
  const DashboardHeader({Key? key, required this.serviceRequest}) : super(key: key);

  getStatus(Map settingsLocal, status) {
    if (status.isEmpty) return '';
    for (var item in settingsLocal['workOrderStatusTypes']) {
      if (item['id'] == status) return item['name'] ?? '-error unknown-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settingsLocal = settingsProvider.localSettings;
    final String displayName = serviceRequest.displayName;
    final String startDate = DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch( serviceRequest.startDate.seconds * 1000));
    final String dueDate = DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch( serviceRequest.dueDate.seconds * 1000));
    final String endDate = DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch( serviceRequest.endDate.seconds * 1000));
    final String summary = serviceRequest.summary;
    final String status = serviceRequest.statusId;
    final Size size = MediaQuery.of(context).size;

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text(displayName)],
              )
            ],
          ),
          Row(
            children: [Text('Start: '), Text(startDate)],
          ),
          Row(
            children: [
              Text('End Date: '),
              Text(endDate)
            ],
          ),
          Row(
            children: [
              Text('Due Date: '),
              Text(dueDate)
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary: '),
              SizedBox(
                width: size.width * .7,
                child: Text(summary),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: '),
              SizedBox(
                width: size.width * .7,
                child: Text(getStatus(settingsLocal, status)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}