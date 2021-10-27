import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobiletrack_dispatch_flutter/models/technician_model.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/schedule_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/multiplication_table_cell.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/new_service_request.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/render_widget.dart';
import 'package:provider/provider.dart';

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

  late double cellWidth = 75.0;

  final key = GlobalKey();

  //final Set<RenderProxyWidget> selectedTimes = Set<RenderProxyWidget>();
  final List<RenderProxyWidget> selectedTimes = [];
  final Set<RenderProxyWidget> _trackTaped = Set<RenderProxyWidget>();

  DateFormat dateFormatter = DateFormat('dd/mm/yyyy HH:MM');

  bool activeSelection = false;
  bool activeDrag = false;
  WorkOrder? activeWorkOrder;
  int timeDiffInMinutes = 0;

  DateTime? activeDateTime;
  String activeTechId = "";

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

  _selectTime(RenderProxyWidget time) {
    if (time.isWorkOrder && selectedTimes.isEmpty) {
      activeWorkOrder = time.workOrder;
      activeDateTime = activeWorkOrder!.startDate.toDate();
      activeTechId = activeWorkOrder!.technicianId;

      setState(() {
        timeDiffInMinutes = activeWorkOrder!.endDate
            .toDate()
            .difference(activeWorkOrder!.startDate.toDate())
            .inMinutes;
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

    if (selectedTimes
        .where((element) => element.isWorkOrder == false)
        .isNotEmpty) {
      RenderProxyWidget firstItem =
          selectedTimes.firstWhere((element) => element.isWorkOrder == false);

      RenderProxyWidget lastItem =
          selectedTimes.lastWhere((element) => element.isWorkOrder == false);

      DateTime firstDate = firstItem.time!; //selectedTimes.first.time!;
      DateTime lastDate = lastItem.time!; //selectedTimes.last.time!;

      final diff = activeDrag
          ? activeWorkOrder!.startDate.toDate().difference(lastDate)
          : firstDate.difference(lastDate);

      double offset = (widget.scrollController.position.maxScrollExtent /
          widget.timeline.length);

      if (diff.inMinutes != 0) {
        if (diff.inMinutes > 0) {
          //move right
          widget.scrollController.animateTo(
              widget.scrollController.offset -
                  (offset * (activeDrag ? 1.2 : 1.2)),
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn);
        } else {
          //move left
          widget.scrollController.animateTo(
              widget.scrollController.offset +
                  (offset * (activeDrag ? 1.2 : 1.2)),
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn);
        }
      }

      if (activeDrag &&
          !time.isWorkOrder &&
          !(activeTechId == time.technicianId &&
              activeDateTime!.hour == time.time!.hour &&
              activeDateTime!.minute == time.time!.minute)) {
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

        DateTime end = DateTime.utc(
            last.year, last.month, last.day, last.hour, last.minute + 15);

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
    return GestureDetector(
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
                        cellHeight:
                            widget.timelineRows[index].workOrders.length * 50,
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
                    physics: (selectedTimes.isNotEmpty && activeSelection) ||
                            activeDrag
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: (widget.timeline.length) * cellWidth,
                      child: ListView(
                          key: key,
                          controller: _restColumnsController,
                          physics:
                              (selectedTimes.isNotEmpty && activeSelection) ||
                                      activeDrag
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                          children:
                              List.generate(widget.timelineRows.length, (y) {
                            return SizedBox(
                                width: (widget.timeline.length) * cellWidth,
                                height:
                                    widget.timelineRows[y].workOrders.length *
                                        50,
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
                                  ...List.generate(widget.timeline.length, (x) {
                                    return Positioned(
                                      bottom: 0,
                                      top: 0,
                                      left: 0,
                                      right: cellWidth * x,
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 1),
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
                                    return Expanded(
                                        child: Container(
                                            child: Row(
                                                children:
                                                    List.generate(4, (index) {
                                      DateTime newTime = widget.timeline[x]
                                          .add(Duration(minutes: index * 15));

                                      bool timeInRange = false;
                                      if (selectedTimes.isNotEmpty &&
                                          ((newTime.isAfter(selectedTimes
                                                      .first.time!) &&
                                                  newTime.isBefore(selectedTimes
                                                      .last.time!)) ||
                                              (((newTime.isAfter(selectedTimes
                                                      .last.time!) &&
                                                  newTime.isBefore(selectedTimes
                                                      .first.time!)))))) {
                                        timeInRange = true;
                                      }

                                      bool checked = selectedTimes
                                                  .map((e) => e)
                                                  .toList()
                                                  .indexWhere((element) => ((element
                                                                  .time!
                                                                  .difference(
                                                                      newTime)
                                                                  .inMinutes ==
                                                              0 ||
                                                          timeInRange) &&
                                                      element.technicianId ==
                                                          widget
                                                              .timelineRows[y]
                                                              .technician
                                                              .id)) !=
                                              -1
                                          ? true
                                          : false;

                                      return Expanded(
                                          child: RenderWidget(
                                        isWorkOrder: false,
                                        index: x,
                                        technicianId: widget
                                            .timelineRows[y].technician.id,
                                        time: newTime,
                                        child: Container(
                                          color: checked && !activeDrag
                                              ? Colors.green
                                              : Colors.transparent,
                                        ),
                                      ));
                                    }))));
                                  })),
                                  ...List.generate(
                                      widget.timelineRows[y].workOrders.length,
                                      (x) {
                                    WorkOrder workOrder =
                                        widget.timelineRows[y].workOrders[x];

                                    double startPosition = 0;
                                    double endPosition = 1;

                                    DateTime timeStart = widget.timeline.first;
                                    DateTime timeEnd = widget.timeline.last;
                                    timeEnd = timeEnd.add(Duration(hours: 1));

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

                                    if (minutesStart < 0) {
                                      startPosition = 0;
                                    } else {
                                      startPosition =
                                          minutesStart / totalMinutes;
                                    }

                                    print(
                                        "timeStart diff - ${minutesStart}, position - ${startPosition}");

                                    Duration differenceEnd = workOrder.endDate
                                        .toDate()
                                        .difference(timeEnd);

                                    int minutesEnd = differenceEnd.inMinutes;

                                    ///workOrder.startTime.minute;

                                    if (minutesEnd > totalMinutes) {
                                      endPosition = 1;
                                    } else {
                                      endPosition = minutesEnd / totalMinutes;
                                      if (endPosition < 0) {
                                        endPosition = endPosition * -1;
                                      }
                                    }

                                    print(
                                        "timeEnd diff - ${minutesEnd}, position - ${endPosition}");

                                    print("### WORk ORDER END");

                                    bool isSelected = false;
                                    if (activeWorkOrder != null &&
                                        activeWorkOrder!.id == workOrder.id) {
                                      isSelected = true;
                                    }

                                    bool isInFullTimeline =
                                        (minutesStart < 0 && minutesEnd > 0);

                                    Widget child = Container(
                                      decoration: isInFullTimeline
                                          ? ShapeDecoration(
                                              color: isSelected
                                                  ? Colors.lightBlueAccent
                                                  : Color(0xFFC3F2EF),
                                              shape: BeveledRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ))
                                          : BoxDecoration(
                                              color: isSelected
                                                  ? Colors.lightBlueAccent
                                                  : Color(0xFFC3F2EF),
                                            ),
                                      margin: EdgeInsets.symmetric(vertical: 1),
                                      child: Row(children: [
                                        isInFullTimeline
                                            ? SizedBox(
                                                width: 15,
                                              )
                                            : VerticalDivider(
                                                width: 5,
                                                thickness: 5,
                                                color: Colors.black87,
                                              ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 5),
                                                //height: 50,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                      workOrder.displayName,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    )),
                                                  ],
                                                )))
                                      ]),
                                    );

                                    double totalWidth =
                                        (widget.timeline.length) * cellWidth;

                                    double fromLeft =
                                        totalWidth * startPosition;
                                    double fromRight = totalWidth * endPosition;

                                    return Positioned(
                                        top: x * 50,
                                        left: isInFullTimeline ? 0 : fromLeft,
                                        right: isInFullTimeline ? 0 : fromRight,
                                        bottom: (widget.timelineRows[y]
                                                    .workOrders.length -
                                                (x + 1)) *
                                            50,
                                        child: isInFullTimeline
                                            ? child
                                            : RenderWidget(
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
