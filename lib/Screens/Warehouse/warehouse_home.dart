import 'dart:convert';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/Rejected/rejected_screen.dart';
import 'package:rajfed_qr/Screens/Incharge/dispatched/dispatched_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/custom_drawer.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/Screens/ChangePassword/change_password.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/Screens/QRScannerScreen/qr_code_screen.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class WarehouseHome extends StatefulWidget {
  const WarehouseHome({super.key});
  @override
  State<WarehouseHome> createState() => _WarehouseHomeState();
}

class _WarehouseHomeState extends State<WarehouseHome> {
  String userName = "";
  final _formKey = GlobalKey<FormState>(); // Key to track form state

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final FocusNode _focusNode = FocusNode();

  DispatchInchargeModel? qrCodeDetail;
  String _selectedOption = "Accept";

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode
    super.dispose();
  }

  void acceptOrRejectByWarehouse() async {
    final dio = Dio();
    showLoadingDialog(context);
    List<dynamic> list = [];
    if (_selectedOption == "Accept") {
      list = [
        {"qrCode": _searchController.text}
      ];
    } else {
      list = [
        {"qrCode": _searchController.text, "message": _commentController.text}
      ];
    }
    print(list);
    Response response;
    try {
      var token = await SharedPreferenceHelper.instance.getToken();
      response = await dio.post(
        _selectedOption == "Accept"
            ? "https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/ReceivedInWareHousePartially"
            : 'https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/RejectedInWareHousePartially',
        data: jsonEncode(list),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        showSuccessToast("Success");
        qrCodeDetail = null;
        _searchController.text = "";
        _commentController.text = "";
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        showErrorToast('Record Not updated');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast('Record Not updated');
    }
  }

  /// API CALLS
  void getUserDetails() async {
    userName = await SharedPreferenceHelper.instance.getUserName() ?? '';
    setState(() {});
  }

  void getQrCodeByScan() async {
    var data = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );
    if (data != null) {
      _searchController.text = data.toString();
      setState(() {});
    }
  }

  void logoutAPICall() async {
    showLoadingDialog(context);
    try {
      var data = await ApiService.instance
          .apiCall(APIEndPoint.logout, HttpRequestType.get, null);
      Navigator.pop(context);
      if (data.status == true) {
        SharedPreferenceHelper.instance.clearData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        showErrorToast(data.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 60), // Warning icon
              SizedBox(width: 10)
            ],
          ),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                logoutAPICall();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void getDetailsByQrCode() async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      showLoadingDialog(context);
      try {
        var response = await WarehouseService.instance
            .wareHouseDetails(_searchController.text);
        if (response?.status == true) {
          Navigator.pop(context);
          setState(() {
            qrCodeDetail = response?.data.length > 0 ? response?.data[0] : null;
          });
          // getOperatorDetails(inchargeDetails?.farmerRegId ?? '');
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: response?.error ?? 'Something went wrong');
        }
      } catch (e) {
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home'),
      ),
      drawer: CustomDrawer(
        userName: userName,
        callback: (value) {
          Navigator.pop(context);
          if (value == "Logout") {
            showLogoutDialog(context);
          } else if (value == "Change Password") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
          } else if (value == "Dispatched") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => DiapatchInchargeScreen()));
          } else if (value == "Rejected") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => RejectedInchargeScreen()));
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 0,
              children: [searchBar(), informationView(), radioButtonView()],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        Expanded(
          child: TextFormField(
            focusNode: _focusNode,
            controller: _searchController,
            keyboardType: TextInputType.number, // Numeric keyboard
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly, // Restricts to numbers only
            ],
            style: TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
                hintText: "Enter QR Code",
                hintStyle: TextStyle(fontWeight: FontWeight.w500),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                suffixIcon: IconButton(
                    onPressed: () {
                      getQrCodeByScan();
                    },
                    icon: Icon(Icons.qr_code_scanner))),
            validator: (value) {
              if (value != null && value.trim().isEmpty) {
                return "Please enter registration number";
              }
              return null;
            },
          ),
        ),

        SizedBox(width: 10), // Space between

        // Search Button
        GestureDetector(
          onTap: () {
            getDetailsByQrCode();
          },
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade50,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget informationView() {
    return qrCodeDetail != null
        ? Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              spacing: 10,
              children: [
                InformationView(details: null, model: qrCodeDetail),
                SizedBox(
                  height: qrCodeDetail != null ? 10 : 0,
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget radioButtonView() {
    return qrCodeDetail != null
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Accept Option
                  Row(
                    children: [
                      Radio<String>(
                        value: "Accept",
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                      Text(
                        "Accept",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(width: 20), // Space between buttons
                  // Reject Option
                  Row(
                    children: [
                      Radio<String>(
                        value: "Reject",
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                      Text(
                        "Reject",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                  visible: _selectedOption == "Reject",
                  child: TextField(
                    controller: _commentController,
                    maxLines: 3, // Allows multiple lines for comments
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded corners
                        borderSide:
                            BorderSide(color: Colors.grey), // Border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.blue, width: 2), // Highlighted border
                      ),
                      contentPadding:
                          EdgeInsets.all(15), // Padding inside TextField
                    ),
                  )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedOption == "Reject" &&
                      _commentController.text.trim().isEmpty) {
                    showErrorToast("Please add comment");
                    return;
                  }
                  acceptOrRejectByWarehouse();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Button size
                  backgroundColor: Colors.green, // Button color
                ),
                child: Text(
                  "        Submit       ",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            ],
          )
        : SizedBox();
  }
}
