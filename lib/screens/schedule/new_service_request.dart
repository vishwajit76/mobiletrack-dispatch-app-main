import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobiletrack_dispatch_flutter/widgets/widgets.dart';

class NewServiceRequest extends StatefulWidget {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  NewServiceRequest(
      {required this.date, required this.startTime, required this.endTime});

  @override
  _NewServiceRequestState createState() => _NewServiceRequestState();
}

class _NewServiceRequestState extends State<NewServiceRequest> {
  DateTime? date;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date = widget.date;
    startTime = widget.startTime;
    endTime = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // centerTitle: true,
        // title: Center(
        //   child: Text(
        //     'Service Request',
        //     style: TextStyle(color: Colors.black),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text('Service Request Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: DateTimePickerWidget(
                format: DateFormat('MM-dd-yyyy'),
                onChanged: (val) {
                  date = val;
                },
                // startDate = Timestamp.fromDate(val),
                validator: (val) {
                  if (val == null) {
                    return 'Please fill out this field';
                  }
                  return null;
                },
                initialValue: date,
                labelText: 'Date*',
                isDate: true,
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: DateTimePickerWidget(
                        format: DateFormat('HH:mm'),
                        onChanged: (val) {
                          startTime = val;
                        },
                        // startDate = Timestamp.fromDate(val),
                        validator: (val) {
                          if (val == null) {
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                        initialValue: startTime,
                        labelText: 'Start Time*',
                        isDate: false,
                      )),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      flex: 1,
                      child: DateTimePickerWidget(
                        format: DateFormat('HH:mm'),
                        onChanged: (val) {
                          endTime = val;
                        },
                        // startDate = Timestamp.fromDate(val),
                        validator: (val) {
                          if (val == null) {
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                        isDate: false,
                        initialValue: endTime,
                        labelText: 'End Time*',
                      )),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextFieldWidget(
                textInputType: TextInputType.text,
                maxLines: 1,
                obscureText: false,
                initialValue: "",
                onChanged: (val) => {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please fill out this field';
                  }
                  return null;
                },
                labelText: 'Customer ID*',
                readOnly: false,
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextFieldWidget(
                textInputType: TextInputType.text,
                maxLines: 1,
                obscureText: false,
                initialValue: "",
                onChanged: (val) => {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please fill out this field';
                  }
                  return null;
                },
                labelText: 'Description*',
                readOnly: false,
              )),
          SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextFieldWidget(
                textInputType: TextInputType.text,
                maxLines: 3,
                obscureText: false,
                initialValue: "",
                onChanged: (val) => {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Please fill out this field';
                  }
                  return null;
                },
                labelText: 'Summery*',
                readOnly: false,
              )),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(onPressed: () {}, text: 'Create Request'),
            ],
          )
        ]
            //Text("Service Request Information")],
            ),
      ),
    );
  }
}
