import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mobiletrack_dispatch_flutter/providers/schedule_provider.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/table_body.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/table_head.dart';

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
          cellWidth: 75.0,
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
