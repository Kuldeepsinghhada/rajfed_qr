import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_home.dart';
import 'package:rajfed_qr/Screens/Operator/Home/HomeScreen.dart';
import 'package:rajfed_qr/Screens/Operator/OperatorDashboard/operator_dashboard.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_home.dart';
import 'package:rajfed_qr/Screens/login/login_service.dart';
import 'package:crypto/crypto.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Key to track form state
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  bool _obscureText = true;

  String buildNumber = "";

  getPackageDetail() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildNumber = "Version: ${packageInfo.version}(${packageInfo.buildNumber})";
    setState(() {});
  }

  @override
  void initState() {
    getPackageDetail();
    super.initState();
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  onLoginPressed() async {
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      showLoadingDialog(context);
      try {
        var response = await LoginService.instance.loginUser(
            _usernameController.text, convertSHA256(_passwordController.text));
        if (response?.status == true) {
          var userType = await SharedPreferenceHelper.instance.getUserType();
          if (userType == 10) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => OperatorDashboard()),
                (route) => false);
          } else if (userType == 2) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => InchargeHome()),
                (route) => false);
          } else if (userType == 13) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WarehouseHome()),
                (route) => false);
          }
        } else {
          Navigator.pop(context);
          showErrorToast(response?.error ?? 'Something went wrong');
        }
      } catch (e) {
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  String convertSHA256(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center align everything
                      children: [
                        // Logo
                        Image.asset("images/satya.png", height: 120),
                        SizedBox(height: 30),
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            label: Text("UserName",
                                style: TextStyle(color: Colors.black)),
                            fillColor: Colors.grey[200],
                            contentPadding:
                                EdgeInsets.only(left: 20, right: 20),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2), // Blue border on focus
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2), // Red border for errors
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().isEmpty) {
                              return "Please enter username";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),

                        // Password Field
                        TextFormField(
                          obscureText: !_obscureText,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            //hintText: "Password",
                            label: Text(
                              "Password",
                              style: TextStyle(color: Colors.black),
                            ),
                            filled: true,
                            contentPadding:
                                EdgeInsets.only(left: 20, right: 20),
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 2), // Blue border on focus
                              borderRadius: BorderRadius.circular(30),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2), // Red border for errors
                              borderRadius: BorderRadius.circular(30),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: _toggleVisibility,
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.trim().isEmpty) {
                              return "Please enter password";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        // Login Button
                        SizedBox(
                          width: double.infinity, // Make button full width
                          child: ElevatedButton(
                            onPressed: () {
                              onLoginPressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30), // Rounded button
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child:
                                Text("Login", style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(buildNumber),
            )
          ],
        ),
      ),
    );
  }
}
