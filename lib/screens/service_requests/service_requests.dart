import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/components/left_drawer.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';
import 'package:mobiletrack_dispatch_flutter/providers/service_request_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/service_requests/service_request_dashboard.dart';

const BoxDecoration searchDecoration = BoxDecoration(color: Color(0xfffca800));


class ServiceRequests extends StatefulWidget {
  @override
  _ServiceRequestsState createState() => _ServiceRequestsState();
}

class _ServiceRequestsState extends State<ServiceRequests> {
  late ServiceRequestProvider serviceRequestProvider;
  final fieldText = TextEditingController();
  bool showSearch = false;
  @override
  void initState() {
    serviceRequestProvider = Provider.of<ServiceRequestProvider>(context, listen: false);
    serviceRequestProvider.getServiceRequests('');
    super.initState();
  }

  toggleSearch() => setState(() => showSearch = !showSearch);

  void clearText() {
    fieldText.clear();
    search('');
  }

  void search(query) async {
    serviceRequestProvider.getServiceRequests(query);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final serviceRequestProvider = Provider.of<ServiceRequestProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: Drawer(
          child: LeftDrawer(),
        ),
        body: Column(
          children: [
            AppBar(
              backgroundColor: AppTheme.green,
              title: Center(child: Text('Service Requests')),
              leading: Builder(
                builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
              actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    toggleSearch();
                  },
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: showSearch ? 1 : 0, 
              duration: Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                height: showSearch ? 52 : 0,
                padding: EdgeInsets.all(2),
                child: SearchWidget(fieldText: fieldText, search: search, clearText: clearText),
              ),
            ),
            Text('Search Service Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
                    child: Text('Display Name',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: serviceRequestProvider.hits.length,
                itemBuilder: (BuildContext context, int index) {
                  var hit = serviceRequestProvider.hits[index];
                  return RequestCard(hit: hit);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final hit;

  const RequestCard({Key? key, this.hit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceRequestDetails(hit: hit))),
      child: Column(
        children: [
          SizedBox(height: size.height * .01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(width: 1, color: Colors.black38)),
              width: double.infinity,
              height: size.height * .1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('${hit['id']}'), Text('${hit['displayName']}')],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
