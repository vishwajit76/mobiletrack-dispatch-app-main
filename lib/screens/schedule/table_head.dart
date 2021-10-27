import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/screens/schedule/multiplication_table_cell.dart';

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
