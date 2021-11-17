import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobiletrack_dispatch_flutter/models/technician_model.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';
import 'package:mobiletrack_dispatch_flutter/providers/schedule_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/multiplication_table_cell.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/render_widget.dart';
import 'package:provider/provider.dart';

class TableBody extends StatefulWidget {
  final ScrollController scrollController;
  final List<DateTime> timeline;

  TableBody({
    required this.timeline,
    required this.scrollController,
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

  DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return bodyWidget(
          scheduleProvider,
        );
      },
    );
  }

  Widget bodyWidget(ScheduleProvider scheduleProvider) {
    return Row(
      children: [
        SizedBox(
            width: 100,
            child: ListView(
              controller: _firstColumnController,
              physics: ClampingScrollPhysics(),
              children:
                  List.generate(scheduleProvider.timelineRows.length, (index) {
                Technician technician =
                    scheduleProvider.timelineRows[index].technician;

                return MultiplicationTableCell(
                  color: getColorFromHex(technician.color),
                  cellWidth: 100,
                  cellHeight: scheduleProvider
                          .timelineRows[index].filteredWorkOrders.length *
                      50,
                  child: Text(
                    "${technician.firstName} ${technician.lastName}",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            )),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: (widget.timeline.length) * cellWidth,
              child: ListView(
                  key: key,
                  controller: _restColumnsController,
                  physics: const ClampingScrollPhysics(),
                  children:
                      List.generate(scheduleProvider.timelineRows.length, (y) {
                    return SizedBox(
                        width: (widget.timeline.length) * cellWidth,
                        height: scheduleProvider
                                .timelineRows[y].filteredWorkOrders.length *
                            50,
                        child: Stack(children: [
                          Positioned(
                            bottom: 0,
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
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
                                margin: EdgeInsets.symmetric(vertical: 1),
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
                              children:
                                  List.generate(widget.timeline.length, (x) {
                            return Expanded(
                                child: Container(
                                    child: Row(
                                        children:
                                            //15 minute interval
                                            List.generate(4, (index) {
                              DateTime currentDate = widget.timeline[x];

                              DateTime newTime = DateTime(
                                  scheduleProvider.selectedDate.year,
                                  scheduleProvider.selectedDate.month,
                                  scheduleProvider.selectedDate.day,
                                  currentDate.hour,
                                  (currentDate.minute + (index * 15) + 1));

                              int weekDay = newTime.weekday == 7
                                  ? 1
                                  : newTime.weekday + 1;

                              Day workingDay = scheduleProvider
                                  .timelineRows[y].technician.schedule.days
                                  .firstWhere(
                                      (element) => element.id == weekDay);

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

                              if (weekDay == 1 ||
                                  weekDay == 7 ||
                                  (workingDay.isWorkday &&
                                      newTime.isAfter(start) &&
                                      newTime.isBefore(end))) {
                                isWorkHour = true;
                              }

                              return Expanded(
                                  child: RenderWidget(
                                isWorkOrder: false,
                                index: x,
                                row: y,
                                techIndex: y,
                                technicianId: scheduleProvider
                                    .timelineRows[y].technician.id,
                                time: newTime,
                                child: Container(
                                  color: isWorkHour
                                      ? Colors.transparent
                                      : Colors.grey.withOpacity(0.2),
                                ),
                              ));
                            }))));
                          })),
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  scheduleProvider.timelineRows[y]
                                      .filteredWorkOrders.length, (fWIndex) {
                                return Container(
                                  height: 50,
                                  child: Stack(
                                    fit: StackFit.loose,
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      ...List.generate(
                                          scheduleProvider
                                              .timelineRows[y]
                                              .filteredWorkOrders[fWIndex]
                                              .length, (x) {
                                        WorkOrder workOrder = scheduleProvider
                                            .timelineRows[y]
                                            .filteredWorkOrders[fWIndex][x];

                                        //calculate start time and end time different
                                        double startPosition = 0;
                                        double endPosition = 1;

                                        DateTime timeStart =
                                            widget.timeline.first;
                                        DateTime timeEnd = widget.timeline.last;
                                        timeEnd =
                                            timeEnd.add(Duration(hours: 1));

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

                                        Duration differenceEnd = workOrder
                                            .endDate
                                            .toDate()
                                            .difference(timeEnd);

                                        int minutesEnd =
                                            differenceEnd.inMinutes;

                                        if (minutesEnd > totalMinutes) {
                                          endPosition = 0;
                                        } else {
                                          endPosition =
                                              minutesEnd / totalMinutes;
                                          if (endPosition < 0) {
                                            endPosition = endPosition * -1;
                                          }
                                        }

                                        bool isInFullTimeline =
                                            (minutesStart < 0 &&
                                                minutesEnd > 0);

                                        bool showArrowLeft = minutesStart <= 60;
                                        bool showArrowRight = minutesEnd > -60;

                                        Widget child = Container(
                                          decoration: isInFullTimeline
                                              ? ShapeDecoration(
                                                  color: Color(0xFFC3F2EF),
                                                  shape: BeveledRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ))
                                              : ShapeDecoration(
                                                  color: Color(0xFFC3F2EF),
                                                  shape: BeveledRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight: Radius.circular(
                                                          showArrowRight
                                                              ? 25
                                                              : 0),
                                                      bottomRight:
                                                          Radius.circular(
                                                              showArrowRight
                                                                  ? 25
                                                                  : 0),
                                                      topLeft: Radius.circular(
                                                          showArrowLeft
                                                              ? 25
                                                              : 0),
                                                      bottomLeft:
                                                          Radius.circular(
                                                              showArrowLeft
                                                                  ? 25
                                                                  : 0),
                                                    ),
                                                  ),
                                                ),
                                          margin: isInFullTimeline
                                              ? EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 1)
                                              : EdgeInsets.only(
                                                  top: 1,
                                                  bottom: 1,
                                                  right:
                                                      showArrowRight ? 25 : 0,
                                                  left: showArrowLeft ? 25 : 0),
                                          child: Row(children: [
                                            isInFullTimeline || showArrowLeft
                                                ? SizedBox(
                                                    width: 15,
                                                  )
                                                : RenderWidget(
                                                    //index: y,
                                                    totalRow: scheduleProvider
                                                        .timelineRows[y]
                                                        .filteredWorkOrders
                                                        .length,
                                                    techIndex: y,
                                                    row: fWIndex,
                                                    technicianId:
                                                        scheduleProvider
                                                            .timelineRows[y]
                                                            .technician
                                                            .id,
                                                    time: workOrder.startDate
                                                        .toDate(),
                                                    isWorkOrder: true,
                                                    child: VerticalDivider(
                                                      width: 10,
                                                      thickness: 10,
                                                      color: Colors.black87,
                                                    ),
                                                    workOrder: workOrder),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 20),
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

                                        double fromRight = minutesEnd > 60
                                            ? (cellWidth / 3)
                                            : totalWidth * endPosition;
                                        return Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: isInFullTimeline ||
                                                    showArrowLeft
                                                ? (cellWidth / 3)
                                                : fromLeft,
                                            right: isInFullTimeline ||
                                                    showArrowRight
                                                ? (cellWidth / 3)
                                                : fromRight,
                                            child: isInFullTimeline
                                                ? child
                                                : child);
                                      })
                                    ],
                                  ),
                                );
                              })),
                        ]));
                  })),
            ),
          ),
        ),
      ],
    );
  }
}
