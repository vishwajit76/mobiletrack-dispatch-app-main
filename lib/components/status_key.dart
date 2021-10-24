import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class StatusKeyDropdown extends StatefulWidget {
  const StatusKeyDropdown({ Key? key }) : super(key: key);

  @override
  _StatusKeyDropdownState createState() => _StatusKeyDropdownState();
}

class _StatusKeyDropdownState extends State<StatusKeyDropdown> {
  late GlobalKey actionKey;
  bool isOpen = false;
  late double height, width, xPosition, yPosition;
  OverlayEntry? floatingDropdown;

  @override
  void initState() {
    super.initState();
    actionKey = LabeledGlobalKey('Custom Dropdown');

  }

  void _findDropdownPosition() {
    RenderBox renderbox = actionKey.currentContext!.findRenderObject() as RenderBox;
    height = renderbox.size.height;
    width = renderbox.size.width;
    Offset offset = renderbox.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
    print(height);
    print(width);
    print(xPosition);
    print(yPosition);
  }

  OverlayEntry _createDropdownOverlay() {
    return OverlayEntry(
      builder: (context) => 
      Positioned(
        left: xPosition,
        width: 350,
        top: yPosition + height,
        height: 618,
        child: Container(
          color: Colors.transparent,
          transform: Matrix4.translationValues(-120, 0, 0),
          child: DropDown(
            itemHeight: height
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOpen = !isOpen;
          if(!isOpen) {
            floatingDropdown!.remove();
          } else {
            _findDropdownPosition();
            floatingDropdown = _createDropdownOverlay();
            Overlay.of(context)!.insert(floatingDropdown!);
          }
        });
      },
      child: Container(
        key: actionKey,
        height: 50,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1
          ),
        ),
        child: Row(
          children: [
            Container(
              height: double.infinity,
              width: 4,
              color: Colors.green
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text('Status Key')
            )
          ],
        )
      )
    );
  }
}

class DropDown extends StatelessWidget {
  
  final double itemHeight;

  const DropDown({ Key? key, required this.itemHeight }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    final ScrollController _controller = new ScrollController();
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 5),
            ClipPath(
              clipper: ArrowClipper(),
              child: Container(
                height: 10,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.black
                ),
              ),
            ),
            Container(
              height: 600,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                  width: 1
                ),
              ),
              child: Scrollbar(
                controller: _controller,
                isAlwaysShown: true,
                child: ListView.builder(
                  controller: _controller,
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  scrollDirection: Axis.vertical,
                  itemCount: settingsProvider.parentStatusTypes.length,
                  itemBuilder: (_, int index) {
                    ParentStatusType parent = settingsProvider.parentStatusTypes[index];
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                            color: Colors.grey,
                            child: Text(
                              parent.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            scrollDirection: Axis.vertical,
                            itemCount: parent.childStatusTypes.length,
                            itemBuilder: (_, int index) {
                              CustomStatusType child = parent.childStatusTypes[index];
                              return Container(
                                margin: EdgeInsets.only(top: 2, bottom: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        child.name
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      width: 20,
                                      height: 20,
                                      color: child.color,
                                    ),
                                  ],
                                ),
                              );
                            }
                          )
                        ]
                      ),
                    );
                  },
                ),
              )
            )
            // CustomPaint(
            //   painter: BorderPainter(),
            //   child: Container(
            //     color: Colors.green,
            //     height: 15,
            //     width: 20 
            //   )
            // )
          ],
        ),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = Colors.grey;

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.moveTo(0, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}

class ArrowClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    
    Path path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

}