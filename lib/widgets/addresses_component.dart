import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobiletrack_dispatch_flutter/models/customer_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
class AddressesComponent extends StatelessWidget {
  final addresses;
  final CustomerModel customer;
  const AddressesComponent(
      {Key? key, required this.addresses, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: addresses.length,
        itemBuilder: (BuildContext context, int index) {
          final address = addresses[index];
          Map contact = {};
          address['contactIds'].map((id) {
            contact = customer.contacts.singleWhere((contact) => contact['contactId'] == id);
          }).toList();
          return AddressComponent(address: address, contact: contact);
        },
      ),
    );
  }
}

class AddressComponent extends StatefulWidget {
  final Map address;
  final contact;
  const AddressComponent({ Key? key, required this.address, required this.contact }) : super(key: key);

  @override
  _AddressComponentState createState() => _AddressComponentState();
}

class _AddressComponentState extends State<AddressComponent> {
  // late CustomersProvider customersProvider;

  @override
  void initState() {
    super.initState();
    // customersProvider = Provider.of<CustomersProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // final CustomersProvider customersProvider = Provider.of<CustomersProvider>(context);
    late String addressLine1;
    late String addressLine2;

    if (widget.address.containsKey('city')) {
      addressLine1 = widget.address['addressLine1'];
      addressLine2 =
          '${widget.address['city']}, ${widget.address['state']} ${widget.address['zip']}';
    } else {
      addressLine1 = widget.address['addressLine1'] ?? '';
      addressLine2 = widget.address['addressLine2'] ?? '';
    }

    final String addressType =
        widget.address['addressTypeId'] == '1' ? 'Service' : 'Billing';
    final String addressName =
        widget.address['addressName'] ?? '-no addressName given-';
    final String wholeAddress = '$addressLine1 $addressLine2';

    final Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 20,
                    ),
                    SizedBox(width: size.width * .02),
                    Text(
                      addressType,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        icon: Icon(Icons.drive_file_rename_outline),
                        iconSize: 18,
                        onPressed: () {
                          print('CLICK Edit');
                        },
                      ),
                    ),
                    Container(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        icon: Icon(Icons.add),
                        iconSize: 18,
                        onPressed: () {
                          print('CLICK Add');
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Divider(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (addressName.isNotEmpty)
                  Text(
                    addressName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                SizedBox(height: size.height * 0.01),
                Text(
                  wholeAddress.trim(),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                if (widget.address['contactIds'].isNotEmpty)
                  ContactComponent(contactIds: widget.address['contactIds'], contact: widget.contact)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactComponent extends StatefulWidget {
  final contactIds;
  final contact;

  const ContactComponent({Key? key, required this.contactIds, required this.contact }) : super(key: key);

  @override
  _ContactComponentState createState() => _ContactComponentState();
}

class _ContactComponentState extends State<ContactComponent> {
  late final contact;
  late final contactIds;
  bool contactReady = false;
  late SettingsProvider settingsProvider;
  

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    contact = widget.contact;
    contactIds = widget.contactIds;
  }

  getContactType() {
    var contactTypeId = widget.contact['contactTypeId'];
    var contactType = settingsProvider.globalSettings['contactTypes'].singleWhere((item) => item['id'] == contactTypeId );
    return '${contactType['name']}: ';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(0),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.person, size: 18, 
              color: Colors.black87,
            ),
            SizedBox(width: 5),
            Container(
              width: size.width * .6,
              child: Text(
                getContactType() + '${contact['firstName']} ${contact['lastName']}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        children: [
          Row(
            children: [
              Icon(
                Icons.phone, 
                size: 18,
              ),
              SizedBox(width: size.width * .02),
              Text(
                contact['phone'] ?? contact['mobile'] ?? '- no number listed -',
                style: TextStyle(
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.email, 
                size: 18,
              ),
              SizedBox(width: size.width * .02),
              Container(
                width: size.width * .7,
                child: Text(
                  contact['email'] ?? '- no email listed -',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
