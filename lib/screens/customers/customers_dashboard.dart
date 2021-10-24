import 'package:intl/intl.dart';
import 'customers_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/models/customer_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/models/service_request_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/customers_provider.dart';

const Color textColor = Colors.black87;
const Color shadeColor = const Color(0xFF006401); // Green
const Color backgroundColor = const Color(0xFFf3f3f5); // Background color for Container
const Color avatarText = Colors.white; // Avatar Text inside Circle
const Color buttonBorder = const Color(0xFFECEAEA); // Border around button
const Color buttonBackground = Colors.white; // Background color of button
const Color tabbarColor = const Color(0xFFDFDFDF); // Tab Header Grey Color

class CustomerDetails extends StatefulWidget {
  final hit;
  const CustomerDetails({Key? key, this.hit}) : super(key: key);

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  late var hit;
  late CustomersProvider customersProvider;

  @override
  void initState() {
    super.initState();
    hit = widget.hit;
    customersProvider = Provider.of<CustomersProvider>(context, listen: false);
    customersProvider.subCustomer('hukills', hit['id']);
    customersProvider.subServiceRequestsByCustomer('hukills', hit['id']);
  }

  @override
  void dispose() {
    super.dispose();
    customersProvider.serviceRequestsStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    customersProvider = Provider.of<CustomersProvider>(context);
    final Size size = MediaQuery.of(context).size;

    if (customersProvider.isLoading || customersProvider.customer == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: shadeColor,
          title: Text('Customer Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.mode_edit),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
    }
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
            title: Text('Customer Dashboard'),
            backgroundColor: shadeColor,
            actions: [
              IconButton(
                icon: Icon(Icons.mode_edit),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CustomersForm(
                        formType: 'edit',
                        customer: customersProvider.customer),
                      ),
                    );
                },
              )
            ]),
        body: Container(
          child: Column(
            children: [
              IBoxComponent(customer: customersProvider.customer,),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        color: tabbarColor,
                        child: TabBar(
                          isScrollable: true,
                          indicatorWeight: 5,
                          indicatorColor: shadeColor,
                          unselectedLabelColor: Colors.black54,
                          labelColor: Colors.black87,
                          tabs: [
                            Tab(text: 'General',),
                            Tab(text: 'Service Requests',),
                            Tab(text: 'Invoices',),
                            Tab(text: 'Quotes',),
                            Tab(text: 'Attachments',),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: backgroundColor,
                          child: Container(
                            child: TabBarView(
                              children: [
                                GeneralTab(customer: customersProvider.customer),
                                ServiceTab(serviceRequests: customersProvider.serviceRequests),
                                Text('Invoices'),
                                Text('Quotes'),
                                Text('Attachments'),
                              ]
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        )
      ),
    );
  }
}

class ServiceTab extends StatelessWidget {
  final List<ServiceRequestModel> serviceRequests;
  const ServiceTab({ Key? key, required this.serviceRequests }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: tabbarColor)
                )
            ),
            height: size.height * .05,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Search'),
              ],
            )
          ),
          Container(
            height: size.height * .05,
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: tabbarColor)
                )
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: size.width * .02,
                ),
                Container(
                  width: size.width * .15,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'ID',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: size.width * .20,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'REQUESTED',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: size.width * .63,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'SUMMARY',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: serviceRequests.length,
              itemBuilder: (BuildContext context, int index) {
                ServiceRequestModel serviceRequest = serviceRequests[index];
                return ServiceCard( serviceRequest: serviceRequest, index: index );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceRequestModel serviceRequest;
  final int index;

  const ServiceCard({ Key? key, required this.serviceRequest, required this.index }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final date = DateTime.fromMillisecondsSinceEpoch(serviceRequest.created.seconds * 1000);
    final formattedDate = DateFormat.yMMMd().format(date);
    return Container(
      width: size.width,
      color: index % 2 == 0 ? backgroundColor : Colors.white,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: index % 2 == 0 ? Colors.blue : Colors.orange,
              width: size.width * .02,
              
            ),
            Container(
              width: size.width * .15,
              padding: EdgeInsets.all(5),
              child: Text(
                serviceRequest.id,
                style: TextStyle(
                  fontSize: 12.0
                )
              )
            ),
            Container(
              width: size.width * .20,
              padding: EdgeInsets.all(5),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12.0
                )
              )
            ),
            Container(
              width: size.width * .63,
              padding: EdgeInsets.all(5),
              child: Text(
                serviceRequest.summary,
                style: TextStyle(
                  fontSize: 12.0
                )
              )
            ),
          ],
        ),
      )
    );
  }
}

class GeneralTab extends StatelessWidget {
  final CustomerModel customer;

  const GeneralTab({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        color: backgroundColor,
        child: Column(
          children: [
            AddressesComponent(customer: customer, addresses: customer.addresses,),
            CustomerAddOptions(),
            MapBox(addresses: customer.addresses,)
          ],
        ),
      ),
    );
  }
}

class CustomerAddOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: size.height * 0.042,
            decoration: BoxDecoration(
              border: Border.all(
                color: buttonBorder,
                width: 1,
              ),
              color: buttonBackground,
            ),
            child: TextButton(
              onPressed: () {
                // TODO: Add Address
              },
              child: Row(
                children: [
                  Icon(Icons.add, size: 14, color: textColor),
                  Text(
                    'New Address',
                    style: TextStyle(
                      fontSize: 12.0, 
                      color: textColor,
                    ),
                  ),
                ],
              )
            ),
          ),
          SizedBox(width: size.width * .025),
          Container(
            height: size.height * 0.042,
            decoration: BoxDecoration(
              border: Border.all(
                color: buttonBorder,
                width: 1,
              ),
              color: buttonBackground,
            ),
            child: TextButton(
              onPressed: () {
                // TODO: Add Contact
              },
              child: Row(
                children: [
                  Icon(Icons.add, size: 14, color: textColor),
                  Text(
                    'New Contact',
                    style: TextStyle(
                      fontSize: 12.0, 
                      color: textColor,
                    ),
                  ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
class IBoxComponent extends StatelessWidget {
  final CustomerModel customer;

  const IBoxComponent({ Key? key, required this.customer }) : super(key: key);

  getCustomerType(Map settingsLocal, customerTypeId) {
    if (customerTypeId.isEmpty) return '';
    for (var item in settingsLocal['customerTypes']) {
      if (item['id'] == customerTypeId) return item['name'];
    }
  }

  List<String> getInitials(String displayName) {
    List<String> nameArray = displayName.split(" ");
    String address = '';
    String initials = '';
    int i = 0;
    int x = 0;
    if (isNumeric(nameArray[0])) {
      address = nameArray[0];
      i++;
      x = 1;
    }
    if (nameArray.length == (2 + x))
      initials = nameArray[i][0] + nameArray[i + 1][0];
    else if (nameArray.length >= (3 + x))
      initials = nameArray[i][0] + nameArray[i + 1][0] + nameArray[i + 2][0];
    else
      initials = displayName.substring(i, 3);
    return [address, initials];
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    final CustomersProvider customersProvider = Provider.of<CustomersProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settingsGlobal = settingsProvider.globalSettings;
    final Size size = MediaQuery.of(context).size;
    final String id = customer.id;
    final String description = customer.notes;
    final String displayName = customer.displayName;
    final String customerTypeId = customer.customerTypeId;
    final initials = getInitials(displayName);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 80.0,
                  width: 80.0,
                  child: CircleAvatar(
                    backgroundColor: shadeColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (initials[0].isNotEmpty)
                          Text(
                            initials[0],
                            style: TextStyle(
                              fontSize: 14,
                              color: avatarText,
                            ),
                          ),
                        Text(
                          initials[1].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            color: avatarText
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Column(
                  children: [
                    Container(
                      width: size.width * 0.55,
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: size.height * 0.042,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: buttonBorder,
                      width: 1,
                    ),
                    color: buttonBackground,
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CustomersForm(
                            formType: 'edit',
                            customer: customersProvider.customer),
                          ),
                        );
                    },
                    child: Text(
                      'Edit Customer Details',
                      style: TextStyle(
                        fontSize: 12.0, 
                        color: textColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Text(
                    'Id: ',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    id,
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cust Type: ',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getCustomerType(settingsGlobal, customerTypeId),
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description: ',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: size.width * .02,
                    ),
                    width: size.width * .57,
                    child: Text(
                      description,
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomScrollView(
//         slivers: [
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _SliverAppBarDelegate(
//               minHeight:  120.0,
//               maxHeight: 300.0,
//               child: Container(
//                 color: Colors.red,
//                 child: IBoxComponent(customer: this.customersProvider.customer,)
//               )
//             ),
            
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 return Container(
//                   color: index.isOdd ? Colors.white : Colors.black12,
//                   height: 100.0,
//                   child: Center(
//                     child: Text('$index', textScaleFactor: 5),
//                   ),
//                 );
//               },
//               childCount: 20,
//             )
//           ),
//         ],
//       ),

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });  
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;  @override
//   double get minExtent => minHeight;  @override
//   double get maxExtent => math.max(maxHeight, minHeight);  @override
//   Widget build(
//       BuildContext context, 
//       double shrinkOffset, 
//       bool overlapsContent) 
//   {
//     return child;
//   }  @override
//   bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;
//     // return maxHeight != oldDelegate.maxHeight ||
//     //     minHeight != oldDelegate.minHeight ||
//     //     child != oldDelegate.child;
// }