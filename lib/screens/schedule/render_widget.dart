import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';

class RenderWidget extends SingleChildRenderObjectWidget {
  final String technicianId;
  final DateTime? time;
  final int index;
  final int totalRow;

  final bool isWorkOrder;
  final WorkOrder? workOrder;
  final int row;
  final int techIndex;

  RenderWidget(
      {required Widget child,
      this.technicianId = "",
      this.time,
      required this.isWorkOrder,
      this.workOrder,
      this.row = 0,
      this.totalRow = 1,
      this.index = 0,
      this.techIndex = 0})
      : super(child: child);

  @override
  RenderProxyWidget createRenderObject(BuildContext context) {
    return RenderProxyWidget(
        technicianId: technicianId,
        time: time,
        index: index,
        row: row,
        totalRow: totalRow);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderProxyWidget renderObject) {
    renderObject..technicianId = technicianId;
    renderObject..time = time;
    renderObject..index = index;

    renderObject..isWorkOrder = isWorkOrder;
    renderObject..workOrder = workOrder;
    renderObject..techIndex = techIndex;
    renderObject..totalRow = totalRow;
  }
}

class RenderProxyWidget extends RenderProxyBox {
  int index;
  String technicianId;
  DateTime? time;
  bool isWorkOrder;
  WorkOrder? workOrder;
  int row;
  int totalRow;
  int techIndex;

  RenderProxyWidget(
      {this.technicianId = "",
      this.time,
      this.index = 0,
      this.isWorkOrder = false,
      this.row = 0,
      this.techIndex = 0,
      this.totalRow = 1,
      this.workOrder});
}
