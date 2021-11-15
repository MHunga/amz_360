import 'package:http/http.dart' as http;

class ApiService {
  create(String url) async {
    var body = {};
    final response = await http.post(Uri.parse(url), body: body);
  }
}
