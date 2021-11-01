import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';

class RenderWidget extends SingleChildRenderObjectWidget {
  final String technicianId;
  final DateTime? time;
  final int index;

  final bool isWorkOrder;
  final WorkOrder? workOrder;
  final int row;

  RenderWidget(
      {required Widget child,
      this.technicianId = "",
      this.time,
      required this.isWorkOrder,
      this.workOrder,
      this.row = 0,
      this.index = 0})
      : super(child: child);

  @override
  RenderProxyWidget createRenderObject(BuildContext context) {
    return RenderProxyWidget(
        technicianId: technicianId, time: time, index: index, row: row);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderProxyWidget renderObject) {
    renderObject..technicianId = technicianId;
    renderObject..time = time;
    renderObject..index = index;

    renderObject..isWorkOrder = isWorkOrder;
    renderObject..workOrder = workOrder;
  }
}

class RenderProxyWidget extends RenderProxyBox {
  int index;
  String technicianId;
  DateTime? time;
  bool isWorkOrder;
  WorkOrder? workOrder;
  int row;

  RenderProxyWidget(
      {this.technicianId = "",
      this.time,
      this.index = 0,
      this.isWorkOrder = false,
      this.row = 0,
      this.workOrder});
}
