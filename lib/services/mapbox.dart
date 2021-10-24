import 'dart:convert';
import 'package:http/http.dart' as http;

const ACCESS_TOKEN = 'pk.eyJ1IjoiYmxha2Vjb2RleiIsImEiOiJja2twemEyZ3ozMXZtMnVudzh6ajRkdG5wIn0.ZJ6dJHj6rJbOrDiBUuY2MA';
const BASE_URL = 'api.mapbox.com';

class MapBoxService {
  // final Uri uri = Uri.parse('https://api.mapbox.com/geocoding/v5/mapbox.places/');

  static Future<dynamic> getMapBoxURL(var addresses) async {
    String address = getAddress(addresses);
    var coordinates = await getMapCoordinates(address);
    var staticImageUrl = 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/pin-l-embassy+f74e4e(${coordinates[0]},${coordinates[1]})/${coordinates[0]},${coordinates[1]},12/600x300?access_token=$ACCESS_TOKEN';
    return staticImageUrl;
  }

  //--------------------------------------------------------------

  static getAddress(var addresses) {
    // addressTypeIds:  1 = Service || 0 = Billing
    Map address= addresses.firstWhere((element) => element['addressTypeId'] == "1", orElse: () => null );
    late String addressLine1;
    late String addressLine2;

    if(address.containsKey('city')) {
      addressLine1 = address['addressLine1'];
      addressLine2 = '${address['city']}, ${address['state']} ${address['zip']}';
      return '$addressLine1 $addressLine2';

    } else if (!address.containsKey('city')) {
      return '${address['addressLine1']} ${address['addressLine2']}';
    }
  }

  static getMapCoordinates(String address) async {
    var queryParameters = {
      'access_token': ACCESS_TOKEN,
    };
    var url = Uri.https(BASE_URL, '/geocoding/v5/mapbox.places/$address.json', queryParameters);
    var response = await http.get(url);
    var coordinates = jsonDecode(response.body)['features'][0]['center'];
    return coordinates;
  }
}
