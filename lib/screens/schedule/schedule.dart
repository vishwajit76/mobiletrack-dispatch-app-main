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
import 'package:mobiletrack_dispatch_flutter/screens/schedule/new_service_request.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/render_widget.dart';
import 'package:provider/provider.dart';

class MultiplicationTableCell extends StatelessWidget {
  final Color color;
  final Widget child;
  final double cellWidth;

  MultiplicationTableCell({
    required this.child,
    required this.color,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      height: 50,
      //height: cellWidth,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black12,
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class TableHead extends StatelessWidget {
  final ScrollController scrollController;
  final double cellWidth;

  final Widget title;
  final List<String> headerList;

  TableHead({
    required this.scrollController,
    required this.title,
    required this.cellWidth,
    required this.headerList,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: cellWidth,
      height: 50,
      child: Row(
        children: [
          Container(width: 100, child: title),
          Expanded(
            child: ListView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: List.generate(headerList.length, (index) {
                return MultiplicationTableCell(
                  color: Colors.transparent,
                  child: Text(
                    headerList[index],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  cellWidth: cellWidth,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class TableBody extends StatefulWidget {
  final ScrollController scrollController;

  final List<TimelineRow> timelineRows;
  final List<DateTime> timeline;

  TableBody({
    required this.timeline,
    required this.scrollController,
    required this.timelineRows,
  });

  @override
  _TableBodyState createState() => _TableBodyState();
}

class _TableBodyState extends State<TableBody> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _firstColumnController;
  late ScrollController _restColumnsController;

  late double cellWidth = 50.0;

  final key = GlobalKey();

  //final Set<RenderProxyWidget> selectedTimes = Set<RenderProxyWidget>();
  final List<RenderProxyWidget> selectedTimes = [];
  final Set<RenderProxyWidget> _trackTaped = Set<RenderProxyWidget>();

  DateFormat dateFormatter = DateFormat('dd/mm/yyyy HH:MM');

  bool activeSelection = false;
  bool activeDrag = false;
  WorkOrder? activeWorkOrder;
  int timeDiffInMinutes = 0;

  late ScheduleProvider scheduleProvider;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();
    this.scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    super.dispose();
  }

  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    final Random random = Random();
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    } else {
      return Color.fromRGBO(
          random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
    }
  }

  _detectTapedItem(PointerEvent event) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final result = BoxHitTestResult();

    print("box w - ${box.size.width}, h-${box.size.height}");
    Offset local = box.globalToLocal(event.position);

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is RenderProxyWidget &&
            !_trackTaped.contains(target) &&
            activeSelection) {
          _trackTaped.add(target);

          //if (!activeDrag) {
          _selectTime(target);
          //}
        }

        // if (target is RenderProxyWidget2) {
        //   onChangeWorkOrder(target, event, local, box);
        // }
      }
    } else {}
  }

/*  onChangeWorkOrder(RenderProxyWidget2 workWidget, PointerEvent event,
      Offset local, RenderBox box) {
    activeWorkOrder = workWidget.workOrder;
    activeDrag = true;

    double x = event.position.dx;
    double y = event.position.dy;

    double wp = local.dx / box.size.width;
    double hp = local.dy / box.size.height;

    int tp = (widget.timeline.length * wp).toInt();

    print("wp - $wp, hp - $hp, tp - $tp");

    print(
        "onChangeWorkOrder local - dx-${local.dx}, dy-${local.dy}, distance-${local.distance} track is Empty - ${_trackTaped.isEmpty} techId - ${workWidget.workOrder!.technicianId}, dx-$x, dy-$y, distance - ${event.position.distance}");

    print(
        "total offset - ${widget.scrollController.offset}, maxScrollExtent - ${widget.scrollController.position.maxScrollExtent}, minScrollExtent - ${widget.scrollController.position.minScrollExtent}");

    if (_trackTaped.isNotEmpty) {
      //activeWorkOrder!.startDate = Timestamp.fromDate(_trackTaped.last.time!);

      if (_trackTaped.last.technicianId != activeWorkOrder!.technicianId) {
        TimelineRow timelineRow = widget.timelineRows.singleWhere((element) =>
            element.technician.id == activeWorkOrder!.technicianId);
        timelineRow.workOrders
            .removeWhere((element) => element.id == activeWorkOrder!.id);

        TimelineRow timelineRow2 = widget.timelineRows.singleWhere((element) =>
            element.technician.id == _trackTaped.last.technicianId);
        timelineRow2.workOrders.add(activeWorkOrder!);
      }
    }

    double startPosition = 0;

    DateTime timeStart = widget.timeline.first;
    DateTime timeEnd = widget.timeline.last;

    timeEnd = timeEnd.add(Duration(hours: 1));

    double totalMinutes = widget.timeline.length * 60;

    Duration differenceStart =
        activeWorkOrder!.startDate.toDate().difference(timeStart);

    int minutesStart = differenceStart.inMinutes;

    setState(() {});
  }*/

  _selectTime(RenderProxyWidget time) {
    if (time.isWorkOrder && selectedTimes.isEmpty) {
      activeWorkOrder = time.workOrder;

      setState(() {
        timeDiffInMinutes = activeWorkOrder!.endDate
            .toDate()
            .difference(activeWorkOrder!.startDate.toDate())
            .inMinutes;
        //lastTechId = activeWorkOrder!.technicianId;
        activeDrag = true;
      });
    }

    bool exist = selectedTimes.contains(time);
    if (exist) {
      print("exist cell");

      //selectedTimes.remove(time);
      int index = selectedTimes.indexOf(time);
      if (index == (selectedTimes.length - 1)) {
        selectedTimes.remove(time);
      }
    } else {
      if (selectedTimes.isNotEmpty) {
        if (selectedTimes.first.technicianId == time.technicianId) {
          selectedTimes.add(time);
        } else {
          selectedTimes.clear();
          _trackTaped.clear();
          selectedTimes.add(time);
        }
      } else {
        selectedTimes.add(time);
      }
    }

    print(
        "total offset - ${widget.scrollController.offset}, position - ${widget.scrollController.position.maxScrollExtent}");

    // bool isTimeFound = selectedTimes
    //     .where((element) => element.isWorkOrder == false)
    //     .isNotEmpty;

    if (selectedTimes
        .where((element) => element.isWorkOrder == false)
        .isNotEmpty) {
      /* DateTime first = selectedTimes
          .firstWhere((element) => element.isWorkOrder == false)
          .time!;
      DateTime last = selectedTimes
          .lastWhere((element) => element.isWorkOrder == false)
          .time!;*/

      RenderProxyWidget firstItem =
          selectedTimes.firstWhere((element) => element.isWorkOrder == false);

      RenderProxyWidget lastItem =
          selectedTimes.lastWhere((element) => element.isWorkOrder == false);

      DateTime firstDate = firstItem.time!; //selectedTimes.first.time!;
      DateTime lastDate = lastItem.time!; //selectedTimes.last.time!;

      final diff = firstDate.difference(lastDate);

      double offset = (widget.scrollController.position.maxScrollExtent /
          widget.timeline.length);

      if (diff.inMinutes > 0) {
        //move right
        widget.scrollController.animateTo(
            widget.scrollController.offset - (offset * 1.2),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn);
      } else {
        //move left
        widget.scrollController.animateTo(
            widget.scrollController.offset + (offset * 1.2),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn);
      }

      if (activeDrag && !time.isWorkOrder) {
        //if (selectedTimes.last.technicianId != activeWorkOrder!.technicianId) {

        /*TimelineRow timelineRow = scheduleProvider.timelineRows
            .singleWhere((element) => element.technician.id == activeWorkOrder!.technicianId);

        timelineRow.workOrders
            .removeWhere((element) => element.id == activeWorkOrder!.id);*/

        scheduleProvider.timelineRows.forEach((e) => e.workOrders
            .removeWhere((element) => element.id == activeWorkOrder!.id));
        setState(() {});

        DateTime t1 = lastDate;
        DateTime t2 = lastDate.add(Duration(minutes: timeDiffInMinutes));

        print(
            "new Start Date - ${dateFormatter.format(t1)}, End Date - ${dateFormatter.format(t2)}");

        TimelineRow timelineRow2 = scheduleProvider.timelineRows.singleWhere(
            (element) =>
                element.technician.id == selectedTimes.last.technicianId);

        activeWorkOrder!.startDate = Timestamp.fromDate(t1);
        activeWorkOrder!.endDate = Timestamp.fromDate(t2);
        timelineRow2.workOrders.add(activeWorkOrder!);
      }
    }

    //correct list

    // } else {
    //   selectedTimes.remove(time);
    // }

    setState(() {});
  }

  void _clearSelection(PointerUpEvent event) {
    // else{
    _trackTaped.clear();
    setState(() {
      activeWorkOrder = null;

      if (selectedTimes.length > 1 && !activeDrag) {
        List list = selectedTimes.toList();
        list.sort((a, b) => a.time!.compareTo(b.time!));

        DateTime first = list.first.time!;
        DateTime last = list.last.time!;

        DateTime start = DateTime.utc(
            first.year, first.month, first.day, first.hour, first.minute);

        DateTime end =
            DateTime.utc(last.year, last.month, last.day, last.hour + 1, 0);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewServiceRequest(
                date: widget.timeline.first, startTime: start, endTime: end)));
      }
      selectedTimes.clear();

      activeDrag = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return /*GestureDetector(
        onLongPress: () {
          setState(() {
            activeSelection = true;
          });
        },
        onLongPressUp: () {
          setState(() {
            activeSelection = false;
          });
        },
        onPanUpdate: (d) {
          print('on pan update doesn\'t work');
        },
        child:*/
        GestureDetector(
            onLongPressUp: () {
              setState(() {
                activeSelection = false;
              });
            },
            onLongPress: () {
              setState(() {
                activeSelection = true;
              });
            },
            child: Listener(
                onPointerDown: _detectTapedItem,
                onPointerMove: _detectTapedItem,
                onPointerUp: _clearSelection,
                behavior: HitTestBehavior.deferToChild,
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: ListView(
                        controller: _firstColumnController,
                        physics: ClampingScrollPhysics(),
                        children:
                            List.generate(widget.timelineRows.length, (index) {
                          Technician technician =
                              widget.timelineRows[index].technician;

                          return MultiplicationTableCell(
                            color: getColorFromHex(technician.color),
                            cellWidth: 100,
                            child: Text(
                              "${technician.firstName} ${technician.lastName}",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: widget.scrollController,
                        scrollDirection: Axis.horizontal,
                        //clipBehavior: Clip.antiAliasWithSaveLayer,
                        //physics: const ClampingScrollPhysics(),

                        physics:
                            (selectedTimes.isNotEmpty && activeSelection) ||
                                    activeDrag
                                ? const NeverScrollableScrollPhysics()
                                : const ClampingScrollPhysics(),

                        child: SizedBox(
                          width: (widget.timeline.length) * cellWidth,
                          child: ListView(
                              key: key,
                              //shrinkWrap: true,
                              //primary: selectedTimes.isEmpty ? true : false,
                              controller: _restColumnsController,
                              //physics: const ClampingScrollPhysics(),
                              physics: (selectedTimes.isNotEmpty &&
                                          activeSelection) ||
                                      activeDrag
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                              children: List.generate(
                                  widget.timelineRows.length, (y) {
                                return SizedBox(
                                    width: (widget.timeline.length) * cellWidth,
                                    height: 50,
                                    child: Stack(children: [
                                      Positioned(
                                        bottom: 0,
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          //width: 1,
                                          alignment: Alignment.bottomCenter,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...List.generate(widget.timeline.length,
                                          (x) {
                                        return Positioned(
                                          bottom: 0,
                                          top: 0,
                                          left: 0,
                                          right: cellWidth * x,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 1),
                                            alignment: Alignment.centerRight,
                                            child: VerticalDivider(
                                              color: Colors.black12,
                                              width: 1,
                                              thickness: 2,
                                            ),
                                          ),
                                        );
                                      }),
                                      Row(
                                          children: List.generate(
                                              widget.timeline.length, (x) {
                                        bool checked = selectedTimes
                                                    .map((e) => e)
                                                    .toList()
                                                    .indexWhere((element) => (element
                                                                .time!
                                                                .difference(
                                                                    widget.timeline[
                                                                        x])
                                                                .inMinutes ==
                                                            0 &&
                                                        element.technicianId ==
                                                            widget
                                                                .timelineRows[y]
                                                                .technician
                                                                .id)) !=
                                                -1
                                            ? true
                                            : false;

                                        return Expanded(
                                            child: Container(
                                                child: RenderWidget(
                                          isWorkOrder: false,
                                          index: x,
                                          technicianId: widget
                                              .timelineRows[y].technician.id,
                                          time: widget.timeline[x],
                                          child: Container(
                                            color: checked && !activeDrag
                                                ? Colors.green
                                                : Colors.transparent,
                                          ),
                                        )));
                                      })),
                                      ...List.generate(
                                          widget.timelineRows[y].workOrders
                                              .length, (x) {
                                        WorkOrder workOrder = widget
                                            .timelineRows[y].workOrders[x];

                                        double startPosition = 0;
                                        double endPosition = 1;

                                        DateTime timeStart =
                                            widget.timeline.first;
                                        DateTime timeEnd = widget.timeline.last;
                                        timeEnd =
                                            timeEnd.add(Duration(hours: 1));

                                        print("### WORk ORDER START");
                                        print(
                                            "TID - ${workOrder.technicianId}, ${workOrder.description}");

                                        print(
                                            "work start - ${dateFormatter.format(workOrder.startDate.toDate())} , end - ${dateFormatter.format(workOrder.endDate.toDate())}");

                                        print(
                                            "start timeline - ${dateFormatter.format(timeStart)}, end timeline - ${dateFormatter.format(timeEnd)},");

                                        double totalMinutes =
                                            widget.timeline.length * 60;

                                        Duration differenceStart = workOrder
                                            .startDate
                                            .toDate()
                                            .difference(timeStart);

                                        int minutesStart =
                                            differenceStart.inMinutes;

                                        ///workOrder.startTime.minute;

                                        if (minutesStart < 0) {
                                          startPosition = 0;
                                        } else {
                                          startPosition =
                                              minutesStart / totalMinutes;
                                        }

                                        print(
                                            "timeStart diff - ${minutesStart}, position - ${startPosition}");

                                        Duration differenceEnd = workOrder
                                            .endDate
                                            .toDate()
                                            .difference(timeEnd);

                                        int minutesEnd =
                                            differenceEnd.inMinutes;

                                        ///workOrder.startTime.minute;

                                        if (minutesEnd > totalMinutes) {
                                          endPosition = 1;
                                        } else {
                                          endPosition =
                                              minutesEnd / totalMinutes;
                                          if (endPosition < 0) {
                                            endPosition = endPosition * -1;
                                          }
                                        }

                                        print(
                                            "timeEnd diff - ${minutesEnd}, position - ${endPosition}");

                                        print("### WORk ORDER END");

                                        bool isSelected = false;
                                        if (activeWorkOrder != null &&
                                            activeWorkOrder!.id ==
                                                workOrder.id) {
                                          isSelected = true;
                                        }

                                        Widget child = Container(
                                          color: isSelected
                                              ? Colors.lightBlueAccent
                                              : Color(0xFFC3F2EF),
                                          margin:
                                              EdgeInsets.symmetric(vertical: 1),
                                          child: Row(children: [
                                            VerticalDivider(
                                              width: 5,
                                              thickness: 5,
                                              color: Colors.black87,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 5),
                                                    //height: 50,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            child: Text(
                                                          workOrder.displayName,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Container(
                                                            child: Text(
                                                          workOrder.description,
                                                          //"total - $totalMinutes, minutesStart-$minutesStart, minutesEnd-$minutesEnd, start position-$startPosition, end position-$endPosition, start - ${workOrder.startTime.hour}:${workOrder.startTime.minute}, end - ${workOrder.endTime.hour}:${workOrder.endTime.minute}",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                      ],
                                                    )))
                                          ]),
                                        );

                                        double totalWidth =
                                            (widget.timeline.length) *
                                                cellWidth;

                                        double fromLeft =
                                            totalWidth * startPosition;
                                        double fromRight =
                                            totalWidth * endPosition;

                                        return Positioned(
                                            top: 0,
                                            left: fromLeft,
                                            right: fromRight,
                                            bottom: 0,
                                            child: RenderWidget(
                                                index: 0,
                                                technicianId:
                                                    workOrder.technicianId,
                                                time: workOrder.startDate
                                                    .toDate(),
                                                isWorkOrder: true,
                                                child: child,
                                                workOrder: workOrder));
                                      }),
                                    ]));
                              })),
                        ),
                      ),
                    ),
                  ],
                )));
  }
}

class MultiplicationTable extends StatefulWidget {
  final List<DateTime> timeline;
  final List<TimelineRow> timelineRows;

  MultiplicationTable({required this.timeline, required this.timelineRows});

  @override
  _MultiplicationTableState createState() => _MultiplicationTableState();
}

class _MultiplicationTableState extends State<MultiplicationTable> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _headController;
  late ScrollController _bodyController;

  DateFormat textFormatter = DateFormat('h a');

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _headController = _controllers.addAndGet();
    _bodyController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _headController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableHead(
          scrollController: _headController,
          cellWidth: 50.0,
          headerList:
              widget.timeline.map((e) => "${textFormatter.format(e)}").toList(),
          title: Text(
            "Field Technicians",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: TableBody(
              scrollController: _bodyController,
              timeline: widget.timeline,
              timelineRows: widget.timelineRows),
        ),
      ],
    );
  }
}

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

class TabletLayout extends StatefulWidget {
  final Function incrementDate;
  final Function decrementDate;
  final Function selectDate;
  final DateTime selectedDate;

  const TabletLayout(
      {Key? key,
      required this.selectDate,
      required this.selectedDate,
      required this.decrementDate,
      required this.incrementDate})
      : super(key: key);

  @override
  _TabletLayoutState createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);

  final List<Widget> timesHeader = List.generate(14, (index) {
    if (index + 6 > 12) {
      return Expanded(
          flex: 1,
          child: Center(
            child: Text(
              '${index + 6 - 12}PM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ));
    }
    return Expanded(
        flex: 1,
        child: Center(
          child: Text(
            index + 6 == 12 ? '${index + 6}PM' : '${index + 6}AM',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ));
  });
  late ScheduleProvider scheduleProvider;
  late SettingsProvider settingsProvider;
  bool gotTechnicians = false;

  @override
  void initState() {
    super.initState();
    this.scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    this.settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ScheduleProvider scheduleProvider = Provider.of<ScheduleProvider>(context, listen: true);
    // if(scheduleProvider.technicians.isNotEmpty && !gotTechnicians) {
    //   technicians = scheduleProvider.technicians;
    //   print('done?');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              NavBar(
                selectedDate: this.widget.selectedDate,
                selectDate: this.widget.selectDate,
                decrementDate: this.widget.decrementDate,
                incremenDate: this.widget.incrementDate,
              ),
              if (scheduleProvider.isLoading)
                Expanded(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )),
                ),
              if (!scheduleProvider.isLoading)
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      height: double.infinity,
                      width: double.infinity,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Column(
                            children: [
                              TechRowHeader(timesHeader: timesHeader),
                              Expanded(
                                child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue, width: 1),
                                    ),
                                    child: RawScrollbar(
                                      controller: _scrollController,
                                      isAlwaysShown: true,
                                      thumbColor: Colors.grey[700],
                                      radius: Radius.circular(10),
                                      thickness: 10,
                                      child: ListView.builder(
                                          controller: _scrollController,
                                          itemCount: scheduleProvider
                                              .schedule.rows.length,
                                          itemBuilder: (_, int index) {
                                            TechnicianRow row = scheduleProvider
                                                .schedule.rows[index];
                                            return TechRow(technicianRow: row);
                                          }),
                                    )),
                              )
                            ],
                          ))),
                )
            ],
          )),
    );
  }
}

class TechRow extends StatefulWidget {
  final TechnicianRow technicianRow;

  const TechRow({Key? key, required this.technicianRow}) : super(key: key);

  @override
  _TechRowState createState() => _TechRowState();
}

class _TechRowState extends State<TechRow> {
  int maxRows = 1;
  double rowHeight = 75.0;
  List<Widget> timeSlots = [];
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    this.widget.technicianRow.timeSlots!.forEach((e) {
      // var numberOfThisWorkOrder = this.widget.technicianRow.timeSlots!.where((timeSlot) => timeSlot.workOrder?.id == e.workOrder?.id);

      if (e.workOrder == null) {
        timeSlots.add(Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red, width: 1),
              ),
            )));
      }

      if (e.workOrder != null) {
        var status = settingsProvider
            .localSettings['workOrderCustomStatusTypes']
            .singleWhere((status) => status['id'] == e.workOrder!.statusId);

        // get all the workorder, determine how many rows it takes up

        timeSlots.add(Expanded(
            flex: 1,
            child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${status['color']}')),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.workOrder!.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ))));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: rowHeight * maxRows,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: maxRows,
                  itemBuilder: (_, int index) {
                    return Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: this.widget.technicianRow.color,
                                    child: Text(
                                        this.widget.technicianRow.techName))),
                            ...timeSlots
                          ],
                        ));
                  }),
            )
          ],
        ));
  }
}

class TechRowHeader extends StatelessWidget {
  final List<Widget> timesHeader;

  const TechRowHeader({Key? key, required this.timesHeader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[400]!))),
      height: 40,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 3,
              child: Container(
                child: Text(
                  'Field Technicians',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )),
          ...timesHeader
        ],
      ),
    );
  }
}

/*
 *  NavBar For Tablet
 */

class NavBar extends StatefulWidget {
  final Function incremenDate;
  final Function decrementDate;
  final Function selectDate;
  final DateTime selectedDate;

  const NavBar(
      {Key? key,
      required this.selectDate,
      required this.selectedDate,
      required this.incremenDate,
      required this.decrementDate})
      : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late ScheduleProvider scheduleProvider;
  DateFormat textFormatter = DateFormat('yMMMMd');

  @override
  void initState() {
    super.initState();
    scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[300]!))),
        width: double.infinity,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(width: 20),
                IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () => this.widget.selectDate(context)),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => this.widget.decrementDate(),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => this.widget.incremenDate(),
                ),
                SizedBox(width: 20),
                Text(textFormatter.format(this.widget.selectedDate)),
                SizedBox(width: 50),
                StatusKeyDropdown(),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 20),
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Icon(Icons.swap_horiz)),
                SizedBox(width: 10),
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Icon(Icons.today)),
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Icon(Icons.event_note)),
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: Icon(Icons.event)),
                SizedBox(width: 20),
              ],
            )
          ],
        ));
  }
}

/*
 *
 * Phone Layout
 *
 */

class PhoneLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.green,
        title: Center(child: Text('Schedule')),
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
        actions: [SizedBox(width: 50)],
      ),
      drawer: Drawer(
        child: LeftDrawer(),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
            children: [
              ListTile(
                title: Text('Schedule #1'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailedView())),
              ),
              Divider(height: 4),
              ListTile(
                title: Text('Schedule #2'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailedView())),
              ),
              Divider(height: 4),
              ListTile(
                title: Text('Schedule #3'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailedView())),
              ),
              Divider(height: 4),
              ListTile(
                title: Text('Schedule #4'),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailedView())),
              ),
              Divider(height: 4),
            ],
          )),
        ],
      ),
    );
  }
}

class DetailedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.green,
      ),
      body: Center(
        child: Text('Schedule Data Here'),
      ),
    );
  }
}
