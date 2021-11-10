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

  DateTime selectedDate = DateTime.now();

  bool filterDone = false;

  List<WorkOrder> filteredWorkOrders = [];
  List<WorkOrder> carryOvers = [];

  ScheduleProvider() {
    print("***started ScheduleProvider***");
  }

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
      _timelineRows.add(TimelineRow(
          technician: tech, workOrders: [], filteredWorkOrders: []));

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

  Future subServiceOrdersByDate(
      String handle, DateTime start, DateTime end) async {
    this.schedule.clearTimeSlots();
    this.selectedDate = start;
    this._serviceOrders = [];
    _isLoading = true;
    filterDone = false;

    _timelineRows.forEach((e) => e.workOrders.clear());

    // Format date to ex: 010421 (Jan 4th 2021)
    DateFormat month = DateFormat('MM');
    DateFormat day = DateFormat('dd');
    DateFormat year = DateFormat('yy');

    DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    String dateString =
        month.format(start) + day.format(start) + year.format(start);

    print("subServiceOrdersByDate - ${dateFormatter.format(start)}");

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

    await filterWorkOrder(start, end);
    _isLoading = false;

    notifyListeners();
  }

  Future<void> clearWorkOrder(WorkOrder workOrder,
      {bool shouldUpdate: true}) async {
    _timelineRows
        .firstWhere(
            ((element) => element.technician.id == workOrder.technicianId))
        .workOrders
        .removeWhere((element) => element.id == workOrder.id);

    print(
        "sp clearWorkOrder workOrderId - ${workOrder.id}, from techId - ${workOrder.technicianId}");

    // _timelineRows.forEach(
    //     (e) => e.workOrders.removeWhere((element) => element.id == id));

    //await Future.delayed(Duration(seconds: 1));

    if (shouldUpdate) notifyListeners();
  }

  Future<void> addWorkOrder(WorkOrder workOrder,
      {bool shouldUpdate: true}) async {
    _timelineRows
        .firstWhere(
            ((element) => element.technician.id == workOrder.technicianId))
        .workOrders
        .add(workOrder);

    int index = _timelineRows.indexWhere(((element) =>
        element.workOrders
            .indexWhere((element) => element.id == workOrder.id) !=
        -1));

    print(
        "sp addWorkOrder workOrderId - ${workOrder.id}, techId - ${workOrder.technicianId}, new added index - $index");

    if (shouldUpdate) notifyListeners();
  }

  Future<void> sortWorkOrders({bool shouldUpdate: true}) async {
    //sort work order by dateTime
    this._timelineRows.forEach((element) {
      element.workOrders
          .sort((a, b) => a.startDate.toDate().compareTo(b.startDate.toDate()));
    });

    filterDone = false;
    if (shouldUpdate) notifyListeners();
  }

  Future<void> filterWorkOrder(DateTime start, DateTime end,
      {bool shouldUpdate: true}) async {
    sortWorkOrders(shouldUpdate: false);

    this._timelineRows.forEach((element) {
      element.filteredWorkOrders.clear();
    });

    this._timelineRows.forEach((row) {
      //List<WorkOrder> workOrders = [];
      row.filteredWorkOrders.add([]);
      int index = 0;

      row.workOrders.forEach((workOrder) {
        if (index == row.filteredWorkOrders.length) {
          row.filteredWorkOrders.add([]);
        }

        if (workOrder.startDate.toDate().isBefore(end)) {
          if (row.filteredWorkOrders[index].isEmpty) {
            row.filteredWorkOrders[index].add(workOrder);
          } else {
            if (workOrder.startDate
                .toDate()
                .isAfter(row.filteredWorkOrders[index].last.endDate.toDate())) {
              print(
                  "${workOrder.technicianId} - true - ${workOrder.displayName}");
              row.filteredWorkOrders[index].add(workOrder);
            } else {
              print(
                  "${workOrder.technicianId} - false - ${workOrder.displayName}");
              index++;
              row.filteredWorkOrders.add([]);
              row.filteredWorkOrders[index].add(workOrder);
              //row.filteredWorkOrders[index].add(workOrder);
            }
          }
        }
      });
    });

    filterDone = true;

    if (shouldUpdate) notifyListeners();
    //notifyListeners();
  }

/*  Future<void> filterWorkOrder(DateTime start, DateTime end,
      {bool shouldUpdate: true}) async {
    this._timelineRows.forEach((element) {
      element.filteredWorkOrders.clear();
    });

    this._timelineRows.forEach((row) {
      row.filteredWorkOrders.add([]);
      int index = 0;
      carryOvers.clear();

      List<WorkOrder> workOrders = row.workOrders;

      generateFilteredWorkOrderRow(index, workOrders, row, end);

      while (carryOvers.length > 0) {
        workOrders.clear();
        carryOvers.forEach((row) {
          workOrders.add(row);
        });
        row.filteredWorkOrders.add([]);
        index++;
        carryOvers.clear();
        generateFilteredWorkOrderRow(index, workOrders, row, end);
      }
    });

    filterDone = true;
    if (shouldUpdate) notifyListeners();
  }

  generateFilteredWorkOrderRow(index, workOrders, row, end) {
    workOrders.forEach((workOrder) {
      if (workOrder.startDate.toDate().isBefore(end)) {
        if (row.filteredWorkOrders[index].isEmpty ||
            workOrder.startDate
                .toDate()
                .isAfter(row.filteredWorkOrders[index].last.endDate.toDate())) {
          // || workOrder.startDate.toDate() == row.filteredWorkOrders[index].last.endDate.toDate())) {
          row.filteredWorkOrders[index].add(workOrder);
        } else {
          carryOvers.add(workOrder);
        }
      }
    });
  }*/

  Future<List<TimelineRow>> updateList() async {
    List<TimelineRow> newList =
        _timelineRows.map((element) => element).toList();
    _timelineRows.clear();
    _timelineRows.addAll(newList);
    _timelineRows = newList;
    await Future.delayed(Duration(seconds: 1));
    return _timelineRows;
  }
}

//timeline model display at schedule screen
class TimelineRow {
  final Technician technician;
  final List<WorkOrder> workOrders;
  final List<List<WorkOrder>> filteredWorkOrders;

  TimelineRow(
      {required this.technician,
      required this.workOrders,
      required this.filteredWorkOrders});
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
