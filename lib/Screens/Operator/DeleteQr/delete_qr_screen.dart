import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class DeleteQrScreen extends StatefulWidget {
  const DeleteQrScreen({required this.savedQrIds, super.key});
  final List<SavedQrModel> savedQrIds;
  @override
  State<DeleteQrScreen> createState() => _DeleteQrScreenState();
}

class _DeleteQrScreenState extends State<DeleteQrScreen> {
  List<SavedQrModel> savedQrIds = [];
  List<String> selectedQr = [];
  bool isSelectAll = false;

  @override
  void initState() {
    savedQrIds = widget.savedQrIds;
    super.initState();
  }

  void deleteQrCodes() async {
    final dio = Dio();
    showLoadingDialog(context);
    print(
        "URL: https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/DeleteQRCodes/deleteqrcode");
    print("Body: $selectedQr");
    Response response;
    try {
      var token = await SharedPreferenceHelper.instance.getToken();
      response = await dio.post(
        'https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/DeleteQRCodes/deleteqrcode',
        data: jsonEncode(selectedQr),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );
      print("Response: $response");
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        showSuccessToast("Deleted Successfully");
        Navigator.pop(context);
        for (var item in selectedQr) {
          savedQrIds.removeWhere((obj) => obj.qrCode == item);
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete QR Code")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'SELECT ALL',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w600),
                ),
                Checkbox(
                    value: isSelectAll,
                    checkColor: isSelectAll ? Colors.white : Colors.black,
                    activeColor: Colors.green.shade400,
                    onChanged: (value) {
                      selectedQr.clear();
                      isSelectAll = value ?? false;
                      if (value == true) {
                        for (var item in savedQrIds) {
                          selectedQr.add(item.qrCode ?? '');
                        }
                      }
                      setState(() {});
                    })
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: savedQrIds.length,
                padding: EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  var isCheck = selectedQr.contains(savedQrIds[index].qrCode);
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 35,
                          child: Center(
                            child: Text((index + 1).toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              savedQrIds[index].qrCode ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ),
                        Checkbox(
                            value: isCheck,
                            checkColor: isCheck ? Colors.white : Colors.black,
                            activeColor: Colors.green.shade400,
                            onChanged: (value) {
                              if (isCheck) {
                                selectedQr.remove(savedQrIds[index].qrCode);
                              } else {
                                selectedQr.add(savedQrIds[index].qrCode ?? '');
                              }
                              setState(() {});
                            })
                      ],
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CommonButton(
                text: "DELETE SELECTED QR",
                bgColor: Colors.red.shade400,
                onPressed: () {
                  if (selectedQr.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Please select QR code to delete");
                    return;
                  }
                  showDeleteQRDialog(context, () {
                    deleteQrCodes();
                  });
                }),
          )
        ],
      ),
    );
  }

  void showDeleteQRDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete QR Code"),
          content:
              Text("Are you sure you want to delete all selected records?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.green.shade400),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm(); // Perform delete action
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
}
