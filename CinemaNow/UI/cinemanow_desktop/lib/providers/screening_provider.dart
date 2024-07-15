import 'dart:convert';
import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ScreeningProvider<T> {
  static String? _baseUrl;

  ScreeningProvider() {
    _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://localhost:7102/");
  }

  Future<List<Screening>> get() async {
    var url = "${_baseUrl}Screening?IsMovieIncluded=true";
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = List<Screening>.from(
        data["resultList"].map((x) => Screening.fromJson(x)),
      );
      return result;
    } else {
      throw Exception("Unknown exception");
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Something bad happened, please try again.");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username!;
    String password = AuthProvider.password!;

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }
}
