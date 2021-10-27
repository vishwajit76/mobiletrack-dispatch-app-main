import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobiletrack_dispatch_flutter/components/left_drawer.dart';
import 'package:mobiletrack_dispatch_flutter/components/status_key.dart';
import 'package:mobiletrack_dispatch_flutter/constants/constants.dart';
import 'package:mobiletrack_dispatch_flutter/models/technician_model.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/schedule_provider.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/multiplication_table.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/new_service_request.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/render_widget.dart';
import 'package:provider/provider.dart';



class SchedulePage extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<SchedulePage> {
  late ScheduleProvider scheduleProvider;
  late SettingsProvider settingsProvider;
  Timestamp startDate = Timestamp.now();
  bool subServiceOrders = false;
  DateTime selectedDate = DateTime.now();

  DateFormat dateFormatter = DateFormat('MMDDyy');
  DateFormat textFormatter = DateFormat('yMMMMd');

  bool fullTimeline = false;

  List<DateTime> get timeline =>
      fullTimeline ? fullTimelineList() : timelineList();

  List<DateTime> fullTimelineList() {
    DateTime dateTime = new DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
    );
    return List.generate(24, (index) {
      dateTime = dateTime.add(Duration(hours: 1));
      return dateTime;
    });
  }

  List<DateTime> timelineList() {
    DateTime dateTime = new DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      5,
      1,
    );
    return List.generate(14, (index) {
      dateTime = dateTime.add(Duration(hours: 1));
      return dateTime;
    });
  }

  @override
  void initState() {
    super.initState();
    this.scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    this.settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    scheduleProvider.getTechnicians('hukills');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScheduleProvider scheduleProvider = Provider.of<ScheduleProvider>(context);
    if (scheduleProvider.technicians.isNotEmpty && !subServiceOrders) {
      scheduleProvider.subServiceOrdersByDate('hukills', selectedDate);
      setState(() => subServiceOrders = true);
    }
  }

  void _incrementDate() {
    print('Increment Date!');
    var newDate = new DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day + 1);
    setState(() => selectedDate = newDate);
    scheduleProvider.subServiceOrdersByDate('hukills', selectedDate);
  }

  void _decrementDate() {
    print('Decrement Date!');
    var newDate = new DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day - 1);
    setState(() => selectedDate = newDate);
    scheduleProvider.subServiceOrdersByDate('hukills', selectedDate);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      scheduleProvider.subServiceOrdersByDate('hukills', selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.greyBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.green,
          title: Text('Service Requests'),
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
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
          ],
        ),
        drawer: Drawer(
          child: LeftDrawer(),
        ),
        body: Container(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey[300]!))),
            width: double.infinity,
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.date_range),
                          onPressed: () => _selectDate(context)),
                      Text(textFormatter.format(this.selectedDate)),
                    ],
                  )),
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () => _decrementDate(),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () => _incrementDate(),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Row(children: [
                    InkWell(
                      child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  height: double.infinity,
                                  width: 4,
                                  color: Colors.green),
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text('Status Key'))
                            ],
                          )),
                    )
                  ])),
                  Row(
                    children: [
                      InkWell(
                          onTap: () async {
                            setState(() {
                              fullTimeline = !fullTimeline;
                            });
                            await scheduleProvider.subServiceOrdersByDate(
                                "hukills", selectedDate);
                            setState(() {});
                          },
                          child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey[400]!, width: 1),
                              ),
                              child: Icon(Icons.swap_horiz))),
                      SizedBox(width: 10),
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[400]!, width: 1),
                          ),
                          child: Icon(Icons.today)),
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[400]!, width: 1),
                          ),
                          child: Icon(Icons.event_note)),
                      Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[400]!, width: 1),
                          ),
                          child: Icon(Icons.event)),
                    ],
                  )
                ],
              )
            ]),
          ),
          Expanded(
              child: MultiplicationTable(
            timeline: timeline,
            timelineRows: scheduleProvider.timelineRows,
          ))
        ])));

    /* return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 760) {
          return TabletLayout(selectDate: this._selectDate, selectedDate: this.selectedDate, incrementDate: this._incrementDate, decrementDate: this._decrementDate);
        } else {
          return PhoneLayout();
        }
      },
    );*/
  }
}


