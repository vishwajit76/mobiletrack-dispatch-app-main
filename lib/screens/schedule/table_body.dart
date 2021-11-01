import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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

  //final List<TimelineRow> timelineRows;
  final List<DateTime> timeline;

  TableBody({
    required this.timeline,
    required this.scrollController,
    //required this.timelineRows,
  });

  @override
  _TableBodyState createState() => _TableBodyState();
}

class _TableBodyState extends State<TableBody>
    with AfterLayoutMixin<TableBody> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _firstColumnController;
  late ScrollController _restColumnsController;

  late double cellWidth = 75.0;

  final key = GlobalKey();

  //final Set<RenderProxyWidget> selectedTimes = Set<RenderProxyWidget>();
  final List<RenderProxyWidget> selectedTimes = [];
  final Set<RenderProxyWidget> _trackTaped = Set<RenderProxyWidget>();

  DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  bool activeSelection = false;
  bool activeDrag = false;
  WorkOrder? activeWorkOrder;
  int timeDiffInMinutes = 0;

  DateTime? activeDateTime;
  String activeTechId = "";

  //late ScheduleProvider scheduleProvider;

  WorkOrder? activeWorkOrder2;
  int activeRow = 0;

  //late ScheduleProvider scheduleProvider;

  @override
  void initState() {
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();

    // this.scheduleProvider =
    //     Provider.of<ScheduleProvider>(context, listen: false);

    //startFilter(shouldUpdate: false);

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    startFilter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //scheduleProvider = context.watch()<ScheduleProvider>();
    //scheduleProvider = Provider.of<ScheduleProvider>(context, listen: true);
    // startFilter();
  }

  //filter all work orders
  Future<void> startFilter({bool shouldUpdate: true}) async {
    DateTime start = widget.timeline.first;
    DateTime end = widget.timeline.last.add(Duration(hours: 1));
    await Provider.of<ScheduleProvider>(context, listen: false)
        .filterWorkOrder(start, end, shouldUpdate: shouldUpdate);
  }

  @override
  void dispose() {
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    super.dispose();
  }

  //convert color hex text to color
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

  //detect tap on work order and time range section e.g 06:00 to 06:15 at the same time
  _detectTapedItem(PointerEvent event) {
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final result = BoxHitTestResult();

    Offset local = box.globalToLocal(event.position);

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is RenderProxyWidget &&
            !_trackTaped.contains(target) &&
            activeSelection) {
          _trackTaped.add(target);
          _selectTime(target);
        }
      }
    } else {}
  }

  //manage tapped time range
  _selectTime(RenderProxyWidget time) async {
    if (time.isWorkOrder && selectedTimes.isEmpty) {
      activeWorkOrder = time.workOrder;
      activeRow = time.row;
      activeTechId = time.technicianId;
      activeDateTime = activeWorkOrder!.startDate.toDate();

      //init activated order
      activeWorkOrder2 = WorkOrder(
          technicianId: time.workOrder!.technicianId,
          id: time.workOrder!.id,
          description: time.workOrder!.description,
          created: time.workOrder!.created,
          displayName: time.workOrder!.displayName,
          endDate: time.workOrder!.endDate,
          endTime: time.workOrder!.endTime,
          modified: time.workOrder!.modified,
          serviceRequestId: time.workOrder!.serviceRequestId,
          startDate: time.workOrder!.startDate,
          startTime: time.workOrder!.startTime,
          statusId: time.workOrder!.statusId,
          customId: time.workOrder!.customId,
          dates: time.workOrder!.dates,
          deleted: time.workOrder!.deleted,
          invoicingMemo: time.workOrder!.invoicingMemo);

      setState(() {
        //calculate selected work order time in minutes
        timeDiffInMinutes = activeWorkOrder!.endDate
            .toDate()
            .difference(activeWorkOrder!.startDate.toDate())
            .inMinutes;

        activeDrag = true;
      });
    }

    //if you drag same time then remove last time range
    bool exist = selectedTimes.contains(time);
    if (exist) {
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
      //find start time and end time range
      RenderProxyWidget firstItem =
          selectedTimes.firstWhere((element) => element.isWorkOrder == false);

      RenderProxyWidget lastItem =
          selectedTimes.lastWhere((element) => element.isWorkOrder == false);

      DateTime firstDate = firstItem.time!; //selectedTimes.first.time!;
      DateTime lastDate = lastItem.time!; //selectedTimes.last.time!;

      //get last time range start time diiference in minutes
      final diff = activeDrag
          ? activeWorkOrder!.startDate.toDate().difference(lastDate)
          : firstDate.difference(lastDate);

      //get scroll offset for auto scroll
      double offset = (widget.scrollController.position.maxScrollExtent /
          widget.timeline.length);

      if (diff.inMinutes != 0) {
        if (diff.inMinutes > 0) {
          //move scroll right
          widget.scrollController.animateTo(
              widget.scrollController.offset -
                  (offset * (activeDrag ? 1.2 : 1.2)),
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn);
        } else {
          //move scroll left
          widget.scrollController.animateTo(
              widget.scrollController.offset +
                  (offset * (activeDrag ? 1.2 : 1.2)),
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn);
        }
      }

      //if last drag is time rage and not selected work order
      if (activeDrag &&
          !time.isWorkOrder &&
          !(activeTechId == time.technicianId &&
              activeDateTime!.hour == time.time!.hour &&
              activeDateTime!.minute == time.time!.minute)) {
        /*scheduleProvider.timelineRows.forEach((e) => e.workOrders
            .removeWhere((element) => element.id == activeWorkOrder!.id));*/

        //remove work order from technicians list
        Provider.of<ScheduleProvider>(context, listen: false)
            .clearWorkOrder(activeWorkOrder!.id);

        DateTime t1 = lastDate;
        DateTime t2 = lastDate.add(Duration(minutes: timeDiffInMinutes));

        print(
            "new Start Date - ${dateFormatter.format(t1)}, End Date - ${dateFormatter.format(t2)}");

        //add work order to new technician

        activeWorkOrder!.startDate = Timestamp.fromDate(t1);
        activeWorkOrder!.endDate = Timestamp.fromDate(t2);
        activeWorkOrder!.technicianId = selectedTimes.last.technicianId;

        /* TimelineRow timelineRow2 = scheduleProvider.timelineRows.singleWhere(
            (element) =>
                element.technician.id == selectedTimes.last.technicianId);

        timelineRow2.workOrders.add(activeWorkOrder!);*/

        print("vishwa - ${selectedTimes.last.technicianId}");

        // Provider.of<ScheduleProvider>(context, listen: false)
        //     .addWorkOrder(selectedTimes.last.technicianId, activeWorkOrder!);

        context
            .read<ScheduleProvider>()
            .addWorkOrder(selectedTimes.last.technicianId, activeWorkOrder!);

        //Provider.of<ScheduleProvider>(context, listen: false).updateList();
      }
    }

    setState(() {
      Provider.of<ScheduleProvider>(context, listen: false).notifyListeners();
    });
  }

  //clear all dragged items
  void _clearSelection(PointerUpEvent event) {
    // else{
    _trackTaped.clear();
    setState(() {
      activeWorkOrder = null;
      activeWorkOrder2 = null;
      activeTechId = "";
      activeRow = 0;

      //if selected item is not work order
      if (selectedTimes.length > 1 && !activeDrag) {
        List list = selectedTimes.toList();
        list.sort((a, b) => a.time!.compareTo(b.time!));

        DateTime first = list.first.time!;
        DateTime last = list.last.time!;

        DateTime start = DateTime.utc(
            first.year, first.month, first.day, first.hour, first.minute);

        DateTime end = DateTime.utc(
            last.year, last.month, last.day, last.hour, last.minute + 15);

        //open new service range with selected time range
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewServiceRequest(
                date: widget.timeline.first, startTime: start, endTime: end)));
      } else {
        //filter technicians list
        startFilter();
      }

      selectedTimes.clear();
      activeDrag = false;
    });
  }

  //current active drag work orderbb
  Widget draggedWidget(int row, int techIndex) {
    if (activeWorkOrder2 != null &&
        activeWorkOrder2!.technicianId ==
            Provider.of<ScheduleProvider>(context, listen: false)
                .timelineRows[techIndex]
                .technician
                .id &&
        activeRow == row) {
      WorkOrder workOrder = activeWorkOrder2!;

      double startPosition = 0;
      double endPosition = 1;

      DateTime timeStart = widget.timeline.first;
      DateTime timeEnd = widget.timeline.last;
      timeEnd = timeEnd.add(Duration(hours: 1));

      double totalMinutes = widget.timeline.length * 60;

      Duration differenceStart =
          workOrder.startDate.toDate().difference(timeStart);

      int minutesStart = differenceStart.inMinutes;

      if (minutesStart < 0) {
        startPosition = 0;
      } else {
        startPosition = minutesStart / totalMinutes;
      }

      Duration differenceEnd = workOrder.endDate.toDate().difference(timeEnd);
      int minutesEnd = differenceEnd.inMinutes;

      ///workOrder.startTime.minute;

      if (minutesEnd > totalMinutes) {
        endPosition = 0;
      } else {
        endPosition = minutesEnd / totalMinutes;
        if (endPosition < 0) {
          endPosition = endPosition * -1;
        }
      }

      bool isInFullTimeline = (minutesStart < 0 && minutesEnd > 0);

      Widget child = Container(
        decoration: isInFullTimeline
            ? ShapeDecoration(
                color: Color(0xFFC3F2EF),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ))
            : BoxDecoration(
                color: Color(0xFFC3F2EF),
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
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  //height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(
                        //"${workOrder.technicianId},${scheduleProvider.timelineRows[techIndex].technician.id} " +
                        workOrder.displayName,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                          child: Text(
                        workOrder.description,
                        //"total - $totalMinutes, minutesStart-$minutesStart, minutesEnd-$minutesEnd, start position-$startPosition, end position-$endPosition, start - ${workOrder.startTime.hour}:${workOrder.startTime.minute}, end - ${workOrder.endTime.hour}:${workOrder.endTime.minute}",
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                    ],
                  )))
        ]),
      );

      double totalWidth = (widget.timeline.length) * cellWidth;

      double fromLeft = totalWidth * startPosition;
      double fromRight = totalWidth * endPosition;

      return Positioned(
          top: 0,
          bottom: 0,
          left: isInFullTimeline ? 0 : fromLeft,
          right: isInFullTimeline ? 0 : fromRight,
          child: child);
    } else {
      return Positioned.fill(child: SizedBox());
    }
  }

  @override
  Widget build(BuildContext context) {
    //return Consumer<ScheduleProvider>(builder: (_, sp, __) {
    //final provider = Provider.of<ProviderInterface>(context);

    // final scheduleProvider = context
    //     .read()<ScheduleProvider>(); // Provider.of<ScheduleProvider>(context);

    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        if (child != null) return child;
        return bodyWidget(scheduleProvider);
      },
      //child: bodyWidget(context.watch<ScheduleProvider>()),
    );
  }

  Widget bodyWidget(ScheduleProvider scheduleProvider) {
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
                  child: ListView.builder(
                      //key: UniqueKey(),
                      controller: _firstColumnController,
                      physics: ClampingScrollPhysics(),
                      itemCount: scheduleProvider.timelineRows.length,
                      itemBuilder: (context, index) {
                        Technician technician = context
                            .watch<ScheduleProvider>()
                            .timelineRows[index]
                            .technician;

                        return MultiplicationTableCell(
                          color: getColorFromHex(technician.color),
                          cellWidth: 100,
                          cellHeight: scheduleProvider.timelineRows[index]
                                  .filteredWorkOrders.length *
                              50,
                          child: Text(
                            "${technician.firstName} ${technician.lastName}",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
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
                      child: ListView.builder(
                          key: key,
                          controller: _restColumnsController,
                          physics:
                              (selectedTimes.isNotEmpty && activeSelection) ||
                                      activeDrag
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                          itemCount: scheduleProvider.timelineRows.length,
                          itemBuilder: (context, y) {
                            return SizedBox(
                                width: (widget.timeline.length) * cellWidth,
                                height: scheduleProvider.timelineRows[y]
                                        .filteredWorkOrders.length *
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
                                      // DateTime newTime = widget.timeline[x]
                                      //     .add(Duration(minutes: index * 15));

                                      DateTime currentDate = widget.timeline[x];

                                      DateTime newTime = DateTime(
                                          scheduleProvider.selectedDate.year,
                                          scheduleProvider.selectedDate.month,
                                          scheduleProvider.selectedDate.day,
                                          currentDate.hour,
                                          currentDate.minute);
                                      newTime
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
                                                          scheduleProvider
                                                              .timelineRows[y]
                                                              .technician
                                                              .id)) !=
                                              -1
                                          ? true
                                          : false;

                                      int weekDay = newTime.weekday == 7
                                          ? 1
                                          : newTime.weekday + 1;

                                      Day workingDay = scheduleProvider
                                          .timelineRows[y]
                                          .technician
                                          .schedule
                                          .days
                                          .firstWhere((element) =>
                                              element.id == weekDay);

                                      bool isWorkHour = false;

                                      DateTime start = DateTime(
                                          newTime.year,
                                          newTime.month,
                                          newTime.day,
                                          workingDay.start.hour,
                                          workingDay.start.minute);

                                      DateTime end = DateTime(
                                          newTime.year,
                                          newTime.month,
                                          newTime.day,
                                          workingDay.end.hour,
                                          workingDay.end.minute);

                                      if (workingDay.isWorkday &&
                                          newTime.isAfter(start) &&
                                          newTime.isBefore(end)) {
                                        isWorkHour = true;
                                      }

                                      return Expanded(
                                          child: RenderWidget(
                                        isWorkOrder: false,
                                        index: x,
                                        technicianId: scheduleProvider
                                            .timelineRows[y].technician.id,
                                        time: newTime,
                                        child: Container(
                                          color: checked && !activeDrag
                                              ? Colors.green
                                              : isWorkHour
                                                  ? Colors.transparent
                                                  : Colors.grey
                                                      .withOpacity(0.2),
                                        ),
                                      ));
                                    }))));
                                  })),
                                  Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                          scheduleProvider
                                              .timelineRows[y]
                                              .filteredWorkOrders
                                              .length, (fWIndex) {
                                        return Container(
                                          height: 50,
                                          child: Stack(
                                            fit: StackFit.loose,
                                            clipBehavior: Clip.hardEdge,
                                            children: [
                                              if (activeWorkOrder2 != null &&
                                                  activeDrag &&
                                                  activeTechId ==
                                                      scheduleProvider
                                                          .timelineRows[y]
                                                          .technician
                                                          .id)
                                                draggedWidget(
                                                  fWIndex,
                                                  y,
                                                ),
                                              ...List.generate(
                                                  scheduleProvider
                                                      .timelineRows[y]
                                                      .filteredWorkOrders[
                                                          fWIndex]
                                                      .length, (x) {
                                                WorkOrder workOrder =
                                                    scheduleProvider
                                                            .timelineRows[y]
                                                            .filteredWorkOrders[
                                                        fWIndex][x];

                                                double startPosition = 0;
                                                double endPosition = 1;

                                                DateTime timeStart =
                                                    widget.timeline.first;
                                                DateTime timeEnd =
                                                    widget.timeline.last;
                                                timeEnd = timeEnd
                                                    .add(Duration(hours: 1));

                                                print("### WORk ORDER START");
                                                print(
                                                    "TID - ${workOrder.technicianId}, ${workOrder.displayName} - ${workOrder.description}");

                                                print(
                                                    "work start - ${dateFormatter.format(workOrder.startDate.toDate())} , end - ${dateFormatter.format(workOrder.endDate.toDate())}");

                                                print(
                                                    "start timeline - ${dateFormatter.format(timeStart)}, end timeline - ${dateFormatter.format(timeEnd)},");

                                                double totalMinutes =
                                                    widget.timeline.length * 60;

                                                Duration differenceStart =
                                                    workOrder.startDate
                                                        .toDate()
                                                        .difference(timeStart);

                                                int minutesStart =
                                                    differenceStart.inMinutes;

                                                if (minutesStart < 0) {
                                                  startPosition = 0;
                                                } else {
                                                  startPosition = minutesStart /
                                                      totalMinutes;
                                                }

                                                print(
                                                    "timeStart diff - ${minutesStart}, position - ${startPosition}");

                                                Duration differenceEnd =
                                                    workOrder.endDate
                                                        .toDate()
                                                        .difference(timeEnd);

                                                int minutesEnd =
                                                    differenceEnd.inMinutes;

                                                ///workOrder.startTime.minute;

                                                if (minutesEnd > totalMinutes) {
                                                  endPosition = 0;
                                                } else {
                                                  endPosition =
                                                      minutesEnd / totalMinutes;
                                                  if (endPosition < 0) {
                                                    endPosition =
                                                        endPosition * -1;
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

                                                bool isInFullTimeline =
                                                    (minutesStart < 0 &&
                                                        minutesEnd > 0);

                                                Widget child = Container(
                                                  decoration: isInFullTimeline
                                                      ? ShapeDecoration(
                                                          color: isSelected
                                                              ? Color(0xFFC3F2EF)
                                                                  .withOpacity(
                                                                      0.5)
                                                              : Color(
                                                                  0xFFC3F2EF),
                                                          shape:
                                                              BeveledRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ))
                                                      : ShapeDecoration(
                                                          color: isSelected
                                                              ? Color(0xFFC3F2EF)
                                                                  .withOpacity(
                                                                      0.5)
                                                              : Color(
                                                                  0xFFC3F2EF),
                                                          shape:
                                                              BeveledRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      minutesEnd >
                                                                              0
                                                                          ? 25
                                                                          : 0),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      minutesEnd >
                                                                              0
                                                                          ? 25
                                                                          : 0),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      minutesStart <=
                                                                              0
                                                                          ? 25
                                                                          : 0),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      minutesStart <=
                                                                              0
                                                                          ? 25
                                                                          : 0),
                                                            ),
                                                          ),
                                                        ) /*BoxDecoration(
                                                            color: isSelected
                                                                ? Color(0xFFC3F2EF)
                                                                    .withOpacity(
                                                                        0.5)
                                                                : Color(
                                                                    0xFFC3F2EF),
                                                          )*/
                                                  ,
                                                  margin: isInFullTimeline
                                                      ? EdgeInsets.symmetric(
                                                          horizontal: 25,
                                                          vertical: 1)
                                                      : EdgeInsets.symmetric(
                                                          vertical: 1),
                                                  child: Row(children: [
                                                    isInFullTimeline
                                                        ? SizedBox(
                                                            width: 15,
                                                          )
                                                        : VerticalDivider(
                                                            width: 5,
                                                            thickness: 5,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        5),
                                                            //height: 50,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    child: Text(
                                                                  workOrder
                                                                      .displayName,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                )),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Container(
                                                                    child: Text(
                                                                  workOrder
                                                                      .description,
                                                                  //"total - $totalMinutes, minutesStart-$minutesStart, minutesEnd-$minutesEnd, start position-$startPosition, end position-$endPosition, start - ${workOrder.startTime.hour}:${workOrder.startTime.minute}, end - ${workOrder.endTime.hour}:${workOrder.endTime.minute}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                  overflow:
                                                                      TextOverflow
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
                                                    //top: x * 50,
                                                    // bottom: (scheduleProvider.timelineRows[y]
                                                    //     .workOrders.length -
                                                    //     (x + 1)) *
                                                    //     50,
                                                    top: 0,
                                                    bottom: 0,
                                                    left: isInFullTimeline
                                                        ? 0
                                                        : fromLeft,
                                                    right: isInFullTimeline
                                                        ? 0
                                                        : fromRight,
                                                    child: isInFullTimeline
                                                        ? child
                                                        : RenderWidget(
                                                            index: 0,
                                                            row: fWIndex,
                                                            technicianId:
                                                                workOrder
                                                                    .technicianId,
                                                            time: workOrder
                                                                .startDate
                                                                .toDate(),
                                                            isWorkOrder: true,
                                                            child: child,
                                                            workOrder:
                                                                workOrder));
                                              })
                                            ],
                                          ),
                                        );
                                      })),
                                ]));
                          }),
                    ),
                  ),
                ),
              ],
            )));
  }
}
