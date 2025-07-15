import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/main.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/utils/enums.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl =
      "https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner"; // Change this

  // Common function to handle API requests
  Future<APIResponse> apiCall(
    String endpoint,
    HttpRequestType method, // GET, POST, PUT, DELETE
    dynamic body,
  ) async {
    final String url = "$baseUrl/$endpoint";

    Map<String, String>? headers = {"Content-Type": "application/json"};

    var token = await SharedPreferenceHelper.instance.getToken();
    if (token != null) {
      headers['Authorization'] = "Bearer $token";
    }

    print("URL: $url\n APIType: $method\n Body: $body");

    try {
      http.Response response;

      // Handle different HTTP methods
      switch (method) {
        case HttpRequestType.get:
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case HttpRequestType.post:
          response = await http.post(Uri.parse(url),
              headers: headers, body: jsonEncode(body));
          break;
        case HttpRequestType.put:
          response = await http.put(Uri.parse(url),
              headers: headers, body: jsonEncode(body));
          break;
        case HttpRequestType.delete:
          response = await http.delete(Uri.parse(url), headers: headers);
          break;
      }
      print("Response: ${response.body}");
      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(jsonDecode(response.body));
        var data = jsonDecode(response.body);
        return APIResponse(true, data, "error");
      } else if(response.statusCode == 401 || response.statusCode == 403){
        SharedPreferenceHelper.instance.clearData();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
        );
        var data = jsonDecode(response.body);
        return APIResponse(false, null,
            data['response']['error_message']);
      } else {
        var data = jsonDecode(response.body);
        print(data['response']['error_message']);
        return APIResponse(false, null,
            data['response']['error_message']);
      }
    } catch (e) {
      throw APIResponse(false, null, "API Call Failed: $e");
    }
  }
}
