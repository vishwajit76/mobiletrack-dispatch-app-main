import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RenderWidget extends SingleChildRenderObjectWidget {
  final String technicianId;
  final DateTime time;
  final int index;

  RenderWidget(
      {required Widget child,
      required this.technicianId,
      required this.time,
      required this.index})
      : super(child: child);

  @override
  RenderProxyWidget createRenderObject(BuildContext context) {
    return RenderProxyWidget(
        technicianId: technicianId, time: time, index: index);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderProxyWidget renderObject) {
    renderObject..technicianId = technicianId;
    renderObject..time = time;
    renderObject..index = index;
  }
}

class RenderProxyWidget extends RenderProxyBox {
  int index;
  String technicianId;
  DateTime? time;

  RenderProxyWidget({this.technicianId = "", this.time, this.index = 0});
}
