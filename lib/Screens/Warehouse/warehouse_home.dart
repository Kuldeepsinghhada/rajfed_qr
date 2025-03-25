import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/Rejected/rejected_screen.dart';
import 'package:rajfed_qr/Screens/Incharge/dispatched/dispatched_screen.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Incharge/upload_warehouse_screen/upload_warehouse_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/custom_drawer.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/Screens/change_password/change_password.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/Screens/qr_scanner_screen/qr_code_screen.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/incharge_details.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
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

  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final FocusNode _focusNode = FocusNode();

  InchargeDetails? inchargeDetails;
  OperatorDetails? operatorDetails;

  List<SavedQrModel> scannedNumberList = [];
  List<SavedQrModel> savedQrIds = [];

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

  void getSavedQrCodes() async {
    savedQrIds.clear();
    scannedNumberList.clear();
    showLoadingDialog(context);
    try {
      var response = await OPHomeService.instance
          .farmerSavedList(operatorDetails?.farmerRegID ?? '');
      if (response?.status == true) {
        Navigator.pop(context);
        for (var item in response?.data) {
          if (item.status == 0) {
            savedQrIds.add(item);
          }
        }
        setState(() {});
      } else {
        Navigator.pop(context);
        showErrorToast(response?.error ?? 'Something went wrong');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  /// Action and Dialog
  void scanQrCode(BuildContext context, bool isBulk) async {
    var data = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );
    print("Scanned Barcode: $data");
    if (data != null) {
      if (isBulk == false) {
        if (scannedNumberList.contains(data)) {
          showErrorToast("Duplicate entry not allowed");
          return;
        }
        int remainingRecord =
            (operatorDetails?.transctionBardana ?? 0) - (savedQrIds.length);
        if (scannedNumberList.length <= remainingRecord) {
          scannedNumberList.add(data);
        } else {
          Fluttertoast.showToast(
              msg: "You can upload max $remainingRecord onwards");
        }
      } else {
        //qrController.text = data;
      }
      setState(() {});
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
            inchargeDetails = response?.data;
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

  void getOperatorDetails(String farmerId) async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      showLoadingDialog(context);
      try {
        var response = await OPHomeService.instance.operatorDetails(farmerId);
        if (response?.status == true) {
          Navigator.pop(context);
          setState(() {
            operatorDetails = response?.data;
          });
          getSavedQrCodes();
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

  void addQrCode(bool isAll) async {
    var purchaseCenterId =
        await SharedPreferenceHelper.instance.getPurchaseCenterId();
    if (isAll) {
      for (var item in savedQrIds) {
        if (item.qrCode != null &&
            !scannedNumberList.any((obj) => obj.qrCode == item.qrCode)) {
          var object = SavedQrModel();
          object.qrCode = item.qrCode;
          object.farmerRegId = operatorDetails?.farmerRegID;
          object.lotNo = operatorDetails?.lotId;
          object.cropId = inchargeDetails?.cropID;
          object.purchaseCenterId = purchaseCenterId;
          scannedNumberList.add(object);
        }
      }
    } else {
      if (!scannedNumberList
          .any((obj) => obj.qrCode == _searchController.text.trim())) {
        var object = SavedQrModel();
        object.qrCode = _searchController.text;
        object.farmerRegId = operatorDetails?.farmerRegID;
        object.lotNo = operatorDetails?.lotId;
        object.cropId = inchargeDetails?.cropID;
        object.purchaseCenterId = purchaseCenterId;
        scannedNumberList.add(object);
      }
    }
    setState(() {});
  }

  void navigateToUploadWareHouseScreen() async {
    var status = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UploadWarehouseScreen(qrCodeList: scannedNumberList)));
    if (status == true) {
      savedQrIds.clear();
      operatorDetails = null;
      inchargeDetails = null;
      _searchController.text = "";
      setState(() {});
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
    return operatorDetails != null
        ? Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              spacing: 10,
              children: [
                InformationView(details: operatorDetails),
                SizedBox(
                  height: operatorDetails != null ? 10 : 0,
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget radioButtonView() {
    return operatorDetails != null
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
                      Text("Accept"),
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
                      Text("Reject"),
                    ],
                  ),
                ],
              ),
              CommonButton(text: "Submit", onPressed: () {})
            ],
          )
        : SizedBox();
  }
}
