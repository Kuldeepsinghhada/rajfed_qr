import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen.dart';
import 'package:rajfed_qr/common_views/no_internet_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:developer';
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

  /// Rebuilt: Common function to handle API requests with improved error handling and clarity
  Future<APIResponse> apiCall(
    String endpoint,
    HttpRequestType method, // GET, POST, PUT, DELETE
    dynamic body,
  ) async {
    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      log("[API ERROR] No internet connection");
      // final context = navigatorKey.currentContext;
      // if (context != null) {
      //   await showNoInternetDialog(context, () async {
      //     // Retry the last request
      //     await apiCall(endpoint, method, body);
      //   });
      // }
      return APIResponse(false, null, "No internet connection");
    }

    final String url = "$baseUrl/$endpoint";
    final headers = await _buildHeaders();
    final encodedBody = _encodeBody(body);

    log("[API] $method $url\nBody: $body");
    http.Response response;
    try {
      response = await _makeRequest(url, method, headers, encodedBody);
    } catch (e) {
      log("[API ERROR] Network error: $e");
      return APIResponse(false, null, "Network error: $e");
    }

    log("[API] Response: ${response.statusCode} ${response.body}");
    final decoded = _decodeResponse(response.body);
    if (decoded == null) {
      return APIResponse(false, null, "Invalid response from server");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return APIResponse(true, decoded, "");
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Token expired or invalid
      await SharedPreferenceHelper.instance.clearData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => FarmerDeskScreen()),
        );
      });
      return APIResponse(false, null, "Token has expired or is invalid");
    } else {
      // Try to extract error message
      String errorMsg = "Unknown error";
      if (decoded is Map &&
          decoded['response'] != null &&
          decoded['response']['error_message'] != null) {
        errorMsg = decoded['response']['error_message'].toString();
      } else if (decoded['error'] != null) {
        errorMsg = decoded['error'].toString();
      }
      log("[API ERROR] $errorMsg");
      return APIResponse(false, null, errorMsg);
    }
  }

  // Helper to build headers
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{"Content-Type": "application/json"};
    final token = await SharedPreferenceHelper.instance.getToken();
    if (token != null) {
      headers['Authorization'] = "Bearer $token";
    }
    return headers;
  }

  // Helper to encode body
  String? _encodeBody(dynamic body) {
    if (body == null) return null;
    try {
      return jsonEncode(body);
    } catch (e) {
      log("[API ERROR] Body encoding failed: $e");
      return null;
    }
  }

  // Helper to make the HTTP call
  Future<http.Response> _makeRequest(String url, HttpRequestType method,
      Map<String, String> headers, String? body) async {
    switch (method) {
      case HttpRequestType.get:
        return await http.get(Uri.parse(url), headers: headers);
      case HttpRequestType.post:
        return await http.post(Uri.parse(url), headers: headers, body: body);
      case HttpRequestType.put:
        return await http.put(Uri.parse(url), headers: headers, body: body);
      case HttpRequestType.delete:
        return await http.delete(Uri.parse(url), headers: headers);
    }
  }

  // Helper to decode response
  dynamic _decodeResponse(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      log("[API ERROR] Response decoding failed: $e");
      return null;
    }
  }
}
