import 'package:flutter/material.dart';

class MultiplicationTableCell extends StatelessWidget {
  final Color color;
  final Widget child;
  final double cellWidth;
  final double cellHeight;

  MultiplicationTableCell(
      {required this.child,
      required this.color,
      required this.cellWidth,
      this.cellHeight = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      height: cellHeight,
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
