import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobiletrack_dispatch_flutter/models/technician_model.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';

class ScheduleProvider extends ChangeNotifier {
  Schedule _schedule = new Schedule(rows: []);
  List<Technician> _technicians = [];
  List<WorkOrder> _serviceOrders = [];
  bool _isLoading = true;

  List<TimelineRow> _timelineRows = [];
  List<TimelineRow> get timelineRows => _timelineRows;

  Schedule get schedule => _schedule;
  List<WorkOrder> get serviceOrders => _serviceOrders;
  List<Technician> get technicians => _technicians;
  bool get isLoading => _isLoading;

  Future getTechnicians(String handle) async {
    _timelineRows.clear();
    _technicians.clear();

    Query usersRef = FirebaseFirestore.instance
        .collection('$handle/users/users')
        .orderBy("firstName");
    QuerySnapshot data = await usersRef.get();

    data.docs.forEach((doc) {
      Map data = doc.data() as Map;

      if (data['roles']['dispatch'].contains('1') &&
          data.containsKey('schedule') &&
          !data['deleted']) {
        _technicians.add(Technician.fromSnapshot(doc));
      }
    });

    technicians.asMap().map((index, tech) {
      _timelineRows.add(TimelineRow(technician: tech, workOrders: []));

      _schedule.rows.add(TechnicianRow(
        color: Color(int.parse('0xFF${tech.color}')),
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 19, minute: 0),
        techRowId: tech.id,
        techName: '${tech.firstName} ${tech.lastName}',
        timeSlots: [],
        day: 1,
      ));

      _schedule.rows[index].generateTimeSlots();

      return MapEntry(index, tech);
    });

    Future.delayed(Duration(seconds: 0));
    notifyListeners();
  }

  Future subServiceOrdersByDate(String handle, DateTime date) async {
    this.schedule.clearTimeSlots();
    this._serviceOrders = [];
    _isLoading = true;

    _timelineRows.forEach((e) => e.workOrders.clear());

    // Format date to ex: 010421 (Jan 4th 2021)
    DateFormat month = DateFormat('MM');
    DateFormat day = DateFormat('dd');
    DateFormat year = DateFormat('yy');

    DateFormat dateFormatter = DateFormat('dd/mm/yyyy HH:MM');

    String dateString =
        month.format(date) + day.format(date) + year.format(date);

    print("subServiceOrdersByDate - ${dateString}");

    Query ref = FirebaseFirestore.instance
        .collection('$handle/work-orders/work-orders')
        .where('dates', arrayContains: dateString);

    // Query ref = FirebaseFirestore.instance
    //     .collection('$handle/service-requests/service-requests')
    //     .where('dates', arrayContains: dateString);

    QuerySnapshot docs = await ref.get();

    docs.docs.forEach((doc) {
      Map data = doc.data() as Map;

      WorkOrder wo = WorkOrder.fromSnapshot(doc);

      print(
          "${wo.technicianId}, ${wo.description}, ${dateFormatter.format(wo.startDate.toDate())}, ${dateFormatter.format(wo.endDate.toDate())}");

      if (!data['deleted']) {
        _serviceOrders.add(wo);

        TimelineRow? row2 = this
            ._timelineRows
            .singleWhereOrNull((e) => e.technician.id == wo.technicianId);

        if (row2 != null) {
          print("added into work list");
          row2.workOrders.add(
              wo); // Add Work Orders to Correct TimeSlots under correct Technician
        }
      }
    });


    //Sutton@hukills.com data
    TimelineRow? testData = this
        ._timelineRows
        .singleWhereOrNull((e) => e.technician.id == "Sutton@hukills.com");

    if(testData != null){
      testData.workOrders.forEach((wo) {
        print(
            "Test Data - ${wo.technicianId}, ${wo.description}, ${dateFormatter.format(wo.startDate.toDate())}, ${dateFormatter.format(wo.endDate.toDate())}");

      });
    }


    this.serviceOrders.forEach((workOrder) {
      // pass the work orders to the correct technician
      TechnicianRow? row = this
          .schedule
          .rows
          .singleWhereOrNull((e) => e.techRowId == workOrder.technicianId);

      if (row != null) {
        row.addWorkOrder(
            workOrder); // Add Work Orders to Correct TimeSlots under correct Technician
      }
    });

    _isLoading = false;
    notifyListeners();
  }
}

class TimelineRow {
  final Technician technician;
  final List<WorkOrder> workOrders;

  TimelineRow({
    required this.technician,
    required this.workOrders,
  });
}

class Schedule {
  Timestamp? day;
  List<TechnicianRow> rows;

  Schedule({
    this.day,
    required this.rows,
  });

  void clearTimeSlots() {
    this.rows.forEach((row) {
      row.timeSlots = [];
      row.generateTimeSlots();
    });
  }
}

class TechnicianRow {
  int day;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String techRowId;
  String techName;
  List<TimeSlot>? timeSlots;
  Color color;

  TechnicianRow({
    required this.color,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.techRowId,
    required this.techName,
    this.timeSlots,
  });

  void addWorkOrder(WorkOrder workOrder) {
    this.timeSlots!.forEach((e) {
      if (e.startTime.hour >= workOrder.startTime.hour &&
          e.endTime.hour <= workOrder.endTime.hour) {
        e.workOrder = workOrder;
        e.startDate = workOrder.startDate;
        e.endDate = workOrder.endDate;
      }
    });
  }

  void generateTimeSlots() {
    this.timeSlots = [];

    List.generate(14, (i) {
      this.timeSlots!.add(TimeSlot(
          workOrder: null,
          columns: 1,
          day: 1,
          startTime: TimeOfDay(hour: i + 6, minute: 0),
          endTime: TimeOfDay(hour: i + 7, minute: 0),
          techRowId: this.techRowId));
    });
  }
}

class TimeSlot {
  int day;
  String techRowId;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Timestamp? startDate;
  Timestamp? endDate;
  WorkOrder? workOrder;
  Widget? uiContainer;
  int columns;

  TimeSlot({
    required this.day,
    required this.techRowId,
    required this.startTime,
    required this.endTime,
    required this.columns,
    required this.workOrder,
    this.startDate,
    this.endDate,
    this.uiContainer,
  });

  double toDouble(TimeOfDay time) => time.hour + time.minute / 60.0;
}
