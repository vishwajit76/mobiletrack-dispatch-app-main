import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobiletrack_dispatch_flutter/models/work_order_model.dart';

class RenderWidget2 extends SingleChildRenderObjectWidget {
  final WorkOrder workOrder;

  RenderWidget2({required Widget child, required this.workOrder})
      : super(child: child);

  @override
  RenderProxyWidget2 createRenderObject(BuildContext context) {
    return RenderProxyWidget2(workOrder: workOrder);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderProxyWidget2 renderObject) {
    renderObject..workOrder = workOrder;
  }
}

class RenderProxyWidget2 extends RenderProxyBox {
  WorkOrder? workOrder;

  RenderProxyWidget2({required this.workOrder});
}
