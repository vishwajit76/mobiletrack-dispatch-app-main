import 'package:flutter/material.dart';
import 'package:mobiletrack_dispatch_flutter/services/mapbox.dart';

class MapBox extends StatefulWidget {
  final addresses;

  const MapBox({Key? key, this.addresses}) : super(key: key);
  @override
  _MapBoxState createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  String mapUrl = '';
  bool mapUploaded = false;
  late var addresses;

  @override
  void initState() {
    addresses = widget.addresses;
    getMap(addresses);
    super.initState();
  }

  getMap(addresses) async {
    String url = await MapBoxService.getMapBoxURL(addresses);
    setState(() {
      mapUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: mapUrl.isEmpty
          ? CircularProgressIndicator()
          : Image.network(
              mapUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
    );
  }
}
