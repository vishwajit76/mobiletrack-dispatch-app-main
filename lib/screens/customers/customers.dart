import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/components/left_drawer.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/search_widget.dart';
import 'package:mobiletrack_dispatch_flutter/providers/customers_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/customers/customers_dashboard.dart';

const BoxDecoration searchDecoration = BoxDecoration(color: Color(0xfffca800));

class CustomersScreen extends StatefulWidget {

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late CustomersProvider customersProvider;
  final fieldText = TextEditingController();
  bool showSearch = false;

  @override
  void initState() {
    customersProvider = Provider.of<CustomersProvider>(context, listen: false);
    customersProvider.getCustomers('');
    super.initState();
  }


  toggleSearch() => setState(() => showSearch = !showSearch);

  void clearText() {
    fieldText.clear();
    search('');
  }

  void search(query) async {
    customersProvider.getCustomers(query);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final customersProvider = Provider.of<CustomersProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      drawer: Drawer(
          child: LeftDrawer(),
        ),
        body: Container(
          child: Column(
            children: [
              AppBar(
                backgroundColor: AppTheme.green,
                title: Center(child: Text('Customers')),
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
              SizedBox(height: size.height * .02,),
              Text(
                'Search Customers', 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: Text('Customer',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text('Modified',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: customersProvider.hits.length,
                    itemBuilder: (BuildContext context, int index) {
                      var hit = customersProvider.hits[index];
                      return CustomerCard(hit: hit);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  final hit;
  const CustomerCard({Key? key, this.hit}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final date = DateTime.fromMillisecondsSinceEpoch(hit['modified'] * 1000);
    final formattedDate = DateFormat.yMMMd().format(date);
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerDetails(hit: hit))),
      child: Column(
        children: [
          SizedBox(height: size.height * .01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(
                    width: 1, 
                    color: Colors.black38,
                  ),
              ),
              width: double.infinity,
              height: size.height * .1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${hit['displayName']}'), 
                  Text('$formattedDate'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
