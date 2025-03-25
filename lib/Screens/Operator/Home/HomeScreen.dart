import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/custom_drawer.dart';
import 'package:rajfed_qr/Screens/Operator/rejected_screen/rejected_screen.dart';
import 'package:rajfed_qr/Screens/change_password/change_password.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/Screens/qr_scanner_screen/qr_code_screen.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userName = "";
  final _formKey = GlobalKey<FormState>(); // Key to track form state
  final _formQrCodeKey = GlobalKey<FormState>();
  final _formMultiQrCodeKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController qrController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final FocusNode _focusNode = FocusNode();

  OperatorDetails? operatorDetails;

  List<String> scannedNumberList = [];
  List<SavedQrModel> savedQrIds = [];

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
        getSavedQrCodes();
      } else {
        showErrorToast(data?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void getSavedQrCodes() async {
    showLoadingDialog(context);
    try {
      var response = await OPHomeService.instance
          .farmerSavedList(operatorDetails?.farmerRegID ?? '');
      if (response?.status == true) {
        Navigator.pop(context);
        setState(() {
          savedQrIds = response?.data;
        });
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
        qrController.text = data;
      }
      setState(() {});
    }
  }

  void showQRCodeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formQrCodeKey,
          child: AlertDialog(
            title: Text("Enter QR Code"),
            content: TextFormField(
              controller: qrController,
              keyboardType: TextInputType.number, // Numeric keyboard
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly, // Restricts to numbers only
              ],
              decoration: InputDecoration(
                hintText: "Enter QR Code",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.trim().isEmpty) {
                  return "Please enter code";
                } else if (scannedNumberList.contains(value)) {
                  return "Duplicate entry not allowed";
                }
                return null;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  var status = _formQrCodeKey.currentState?.validate();
                  if (status == true) {
                    int remainingRecord =
                        (operatorDetails?.transctionBardana ?? 0) -
                            (savedQrIds.length);
                    if (scannedNumberList.length <= remainingRecord) {
                      scannedNumberList.add(qrController.text);
                    } else {
                      Fluttertoast.showToast(
                          msg: "You can upload max $remainingRecord onwards");
                    }
                    qrController.text = "";
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                ),
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {});
  }

  void showBulkQRCodeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formMultiQrCodeKey,
          child: AlertDialog(
            title: Text("Enter QR Code"),
            actionsAlignment: MainAxisAlignment.center,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qrController,
                      keyboardType: TextInputType.number, // Numeric keyboard
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts to numbers only
                      ],
                      decoration: InputDecoration(
                        hintText: "Enter Code",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isEmpty) {
                          return "Please enter code";
                        } else if (scannedNumberList.contains(value)) {
                          return "Duplicate entry not allowed";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Icon(Icons.close),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: countController,
                      keyboardType: TextInputType.number, // Numeric keyboard
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Restricts to numbers only
                      ],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Count",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isEmpty) {
                          return "Please enter code";
                        } else if (scannedNumberList.contains(value)) {
                          return "Duplicate entry not allowed";
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  scanQrCode(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                ),
                child: Text(
                  "Scan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  var status = _formMultiQrCodeKey.currentState?.validate();
                  if (status == true) {
                    try {
                      var code = int.parse(qrController.text);
                      var count = int.parse(countController.text);
                      int remainingRecord =
                          (operatorDetails?.transctionBardana ?? 0) -
                              (savedQrIds.length);
                      for (var i = 0; i < count; i++) {
                        if (scannedNumberList.length <= remainingRecord) {
                          scannedNumberList.add("${code + i}");
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  "You can upload max $remainingRecord records onwards");
                        }
                      }
                      qrController.text = "";
                      countController.text = "";
                      Navigator.pop(context);
                    } catch (e) {
                      showErrorToast("Invalid value");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                ),
                child: Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {});
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

  void getOperatorDetails() async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      showLoadingDialog(context);
      try {
        var response = await OPHomeService.instance
            .operatorDetails(_searchController.text);
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
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => RejectedScreen()));
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
              hintText: "Farmer Reg. number",
              hintStyle: TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
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
            getOperatorDetails();
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
                        text: 'Scan',
                        onPressed: () {
                          scanQrCode(context, false);
                        },
                      ),
                    ),
                    Expanded(
                      child: CommonButton(
                        text: 'Manual',
                        onPressed: () {
                          showQRCodeDialog(context);
                        },
                      ),
                    )
                  ],
                ),
                CommonButton(
                  text: 'Bulk Entry',
                  onPressed: () {
                    showBulkQRCodeDialog(context);
                  },
                ),
                savedCodeList(),
                qrCodeList(),
              ],
            ),
          )
        : SizedBox();
  }

  Widget savedCodeList() {
    return savedQrIds.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonButton(
                  text: 'Saved Stocks',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(left: 20, right: 10),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Saved Stock",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: savedQrIds.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 35,
                                            child: Center(
                                              child: Text(
                                                  (index + 1).toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16)),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 20),
                                              child: Text(
                                                savedQrIds[index].qrCode ?? '',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ],
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
                text: 'Save',
                onPressed: () {
                  saveQrAPICall();
                },
              )
            ],
          )
        : SizedBox();
  }
}
