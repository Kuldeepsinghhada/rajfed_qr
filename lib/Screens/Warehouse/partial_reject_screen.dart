import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/Screens/QRScannerScreen/qr_code_screen.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/utils/enums.dart';
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
  final TextEditingController countController = TextEditingController();
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final FocusNode _focusNode = FocusNode();

  OperatorDetails? operatorDetails;

  List<String> scannedNumberList = [];
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

  void saveQrAPICall() async {
    showLoadingDialog(context);
    try {
      var data = await OPHomeService.instance.saveFarmerQrCode(
          operatorDetails?.farmerRegID ?? "",
          scannedNumberList,
          (operatorDetails?.lotId ?? "").toString());
      Navigator.pop(context);
      if (data?.status == true) {
        scannedNumberList.clear();
        showSuccessToast('Record Saved Successfully');
      } else {
        showErrorToast(data?.error ?? 'Something Went wrong');
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
      if (!scannedNumberList.contains(_searchController.text)) {
        if (data.toString().trim().isNotEmpty) {
          scannedNumberList.add(data.toString());
        }
      }
      setState(() {});
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
            if ((!scannedNumberList.contains(_searchController.text) &&
                _searchController.text.trim().isNotEmpty)) {
              scannedNumberList.add(_searchController.text);
              setState(() {});
            }
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
                                        scannedNumberList[index],
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
                    saveQrAPICall();
                  },
                )
              ],
            ),
          )
        : SizedBox();
  }
}
