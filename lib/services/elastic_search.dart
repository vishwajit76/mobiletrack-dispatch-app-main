import 'dart:convert';
import 'package:http/http.dart' as http;
class ElasticSearch {
  

  static Future<List<dynamic>> search(query, config) async {    
    var searchQuery = handleSearchQuery(query);
    return await sendSearchRequest(searchQuery, config);
    
  }

  static Future sendSearchRequest(searchQuery, config) async{
    Uri url = Uri.parse('https://8ad2206de10c414fa676bbfd43d5b397.us-central1.gcp.cloud.es.io:9243/${config['table']}/_search');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic ZWxhc3RpYzplRnNYUnJMZkJvSTRsZGFNUVFYTFk1cVQ='
    };
    Map post = {
      'query': {
        'query_string': {'query': searchQuery, 'fields': config['fields']}
      },
      'sort': config['sort'],
      'size': 10
    };
    var body = jsonEncode(post);
    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['hits']['hits'];
    } else
      return false;
  }

  static handleSearchQuery(query){
    var searchQuery = '';
    var searchArray = [];
    int i = 0;

    if (query.isNotEmpty) searchArray = query.split(' ');
    if (searchArray.isNotEmpty) {
      searchArray.forEach((term) {
        if (i > 0) {
          searchQuery += ' AND ';
        }
        searchQuery += '((*' + term.toLowerCase() + '*) OR (*' + term[0].toUpperCase() + term.substring(1) + '*))';
        i++;
      });
    }
    if (searchQuery == '') searchQuery = '(*)';
    return searchQuery;
  }

}
