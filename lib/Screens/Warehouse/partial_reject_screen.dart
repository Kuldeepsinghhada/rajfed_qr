import 'dart:convert';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/QRScannerScreen/qr_code_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/incharge_details.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class PartialRejectScreen extends StatefulWidget {
  const PartialRejectScreen({super.key});
  @override
  State<PartialRejectScreen> createState() => _PartialRejectScreenState();
}

class _PartialRejectScreenState extends State<PartialRejectScreen> {
  String userName = "";
  final _formKey = GlobalKey<FormState>(); // Key to track form state

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController qrController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final FocusNode _focusNode = FocusNode();

  OperatorDetails? operatorDetails;

  List<ScanModel> scannedNumberList = [];
  bool isShowSavedStock = false;

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
        scannedNumberList.add(data);
      } else {
        qrController.text = data;
      }
      setState(() {});
    }
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

  void getQrCodeByScan() async {
    var data = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );
    if (data != null) {
      _searchController.text = data.toString();
      getDetailsByQrCode();
    }
  }

  void showRejectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: TextField(
            maxLines: 3,
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Rejection reason...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_commentController.text.trim().isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter rejection reason");
                  return;
                }
                Navigator.pop(context);
                acceptOrRejectByWarehouse();
              },
              child: Text("Confirm",
                  style: TextStyle(color: Colors.red, fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  void acceptOrRejectByWarehouse() async {
    final dio = Dio();
    showLoadingDialog(context);
    List<dynamic> list = [];
    for (var item in scannedNumberList) {
      list.add({
        "lotNo": item.lotNo,
        "status": "R",
        "message": _commentController.text,
        "qrCode": item.qrCode
      });
    }
    print(
        "URL: https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/ReceivedInWareHouseLotWise");
    print("Body: $list");
    Response response;
    try {
      var token = await SharedPreferenceHelper.instance.getToken();
      response = await dio.post(
        'https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/ReceivedInWareHouseLotWise',
        data: jsonEncode(list),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );
      print("Response: $response");
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        showSuccessToast("Rejected Successfully");
        Navigator.pop(context);
        Navigator.pop(context, true);
        setState(() {});
      } else {
        Navigator.pop(context);
        showErrorToast('Something wend wrong');
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      Navigator.pop(context);
      showErrorToast('Something wend wrong');
    }
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
          InchargeDetails? inchargeDetails =
              response?.data.isNotEmpty ? response?.data[0] : null;
          bool exists = scannedNumberList
              .any((warehouse) => warehouse.qrCode == _searchController.text);
          if (inchargeDetails != null) {
            if ((!exists && _searchController.text.trim().isNotEmpty)) {
              scannedNumberList.add(ScanModel(_searchController.text,
                  (inchargeDetails.lotNo ?? 0).toString()));
              setState(() {});
            }
          } else {
            showErrorToast("Record not found");
          }
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
        title: Text('Partially Reject'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 0,
              children: [searchBar(), qrCodeList()],
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
            maxLength: 12,
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
                return "Please enter correct code";
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
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget qrCodeList() {
    return scannedNumberList.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
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
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        scannedNumberList[index].qrCode,
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
                  text: 'Reject All',
                  bgColor: Colors.red,
                  onPressed: () {
                    showRejectedDialog(context);
                  },
                )
              ],
            ),
          )
        : SizedBox();
  }
}

class ScanModel {
  String qrCode;
  String lotNo;
  ScanModel(this.qrCode, this.lotNo);
}
