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
import 'package:rajfed_qr/Screens/ChangePassword/change_password.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/Screens/QRScannerScreen/qr_code_screen.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/incharge_details.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class InchargeHome extends StatefulWidget {
  const InchargeHome({super.key});
  @override
  State<InchargeHome> createState() => _InchargeHomeState();
}

class _InchargeHomeState extends State<InchargeHome> {
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

  void showDeleteQRDialog(
      BuildContext context, bool isAllDelete, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete QR Code"),
          content: Text(isAllDelete
              ? "Are you sure you want to delete all records?"
              : "Are you sure you want to delete this QR code?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(); // Perform delete action
                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                "Delete",
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
        var response = await InchargeService.instance
            .inchargeDetails(_searchController.text);
        if (response?.status == true) {
          Navigator.pop(context);
          setState(() {
            inchargeDetails = response?.data;
          });
          getOperatorDetails(inchargeDetails?.farmerRegId ?? '');
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
              children: [searchBar(), informationView()],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Row(
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
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Add All',
                        onPressed: () {
                          addQrCode(true);
                        },
                      ),
                    ),
                    Expanded(
                      child: CommonButton(
                        text: 'Add This',
                        onPressed: () {
                          addQrCode(false);
                        },
                      ),
                    )
                  ],
                ),
                qrCodeList(),
              ],
            ),
          )
        : SizedBox();
  }

  Widget qrCodeList() {
    return scannedNumberList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade400)),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      color: Colors.green.shade400,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                "QR Codes",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                showDeleteQRDialog(context, true, () {
                                  setState(() {
                                    scannedNumberList.clear();
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                    ListView.builder(
                        itemCount: scannedNumberList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                  child: Center(
                                    child: Text((index + 1).toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      scannedNumberList[index].qrCode ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      showDeleteQRDialog(context, false, () {
                                        setState(() {
                                          scannedNumberList.removeAt(index);
                                        });
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
              SizedBox(height: 10),
              CommonButton(
                text: 'Proceed',
                onPressed: () {
                  navigateToUploadWareHouseScreen();
                },
              )
            ],
          )
        : SizedBox();
  }
}
