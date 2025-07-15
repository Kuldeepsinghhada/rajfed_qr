import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';
import 'package:dio/dio.dart';

class UploadWarehouseScreen extends StatefulWidget {
  const UploadWarehouseScreen({required this.qrCodeList, super.key});
  final List<SavedQrModel> qrCodeList;
  @override
  State<UploadWarehouseScreen> createState() => _UploadWarehouseScreenState();
}

class _UploadWarehouseScreenState extends State<UploadWarehouseScreen> {
  String? selectedDistrictValue;
  List<DistrictModel> districtList = [];
  List<String> districtStringList = [];

  String? selectedWarehouse;
  List<WareHouseModel> wareHouseList = [];
  List<String> warehouseStringList = [];

  final List<SavedQrModel> qrCodeList = [];
  var truckController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getDistrictAPICall();
    super.initState();
  }

  void getDistrictAPICall() async {
    await Future.delayed(Duration(microseconds: 200));
    showLoadingDialog(context);
    try {
      var response = await InchargeService.instance.getDistrictList();
      Navigator.pop(context);
      if (response?.status == true) {
        districtList = response?.data ?? [];
        for (var item in districtList) {
          if (item.districtNameEN != null) {
            districtStringList.add(item.districtNameEN!);
          }
        }
        setState(() {});
      } else {
        showErrorToast(response?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void getWareHouseAPICall() async {
    await Future.delayed(Duration(microseconds: 200));
    if (selectedDistrictValue == null) {
      Fluttertoast.showToast(msg: 'Please select district first');
      return;
    }
    var index = districtStringList.indexOf(selectedDistrictValue!);
    showLoadingDialog(context);
    try {
      var response = await InchargeService.instance
          .getWareHouseList(districtList[index].district ?? '');
      Navigator.pop(context);
      if (response?.status == true) {
        wareHouseList = response?.data ?? [];
        warehouseStringList.clear();
        for (var item in wareHouseList) {
          if (item.wareHouseName != null) {
            warehouseStringList.add(item.wareHouseName!);
          }
        }
        setState(() {});
      } else {
        showErrorToast(response?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void dispatchedToWarehouse() async {
    final dio = Dio();
    showLoadingDialog(context);
    List<dynamic> list = [];
    for (var item in qrCodeList) {
      var obj = {
        "lotNo": item.lotNo,
        "farmerRegId": item.farmerRegId,
        "qrCode": item.qrCode,
        "purchaseCenterId": item.purchaseCenterId,
        "cropId": item.cropId,
        "wareHouseId": item.wareHouseId,
        "vehicleNo": item.vehicleNo
      };
      list.add(obj);
    }

    Response response;
    try {
      var token = await SharedPreferenceHelper.instance.getToken();
      response = await dio.post(
        'https://rajfed.rajasthan.gov.in/rajfed_API/QrScanner/DispatchedToWareHouse',
        data: jsonEncode(list),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        ),
      );
      Navigator.pop(context);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        showSuccessToast("Record sent to warehouse successfully");
        Navigator.pop(context, true);
      } else {
        showErrorToast('Record Not updated');
      }
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            children: [
              districtDropdown(),
              wareHouseDropdown(),
              truckNumberField(),
              CommonButton(
                  text: "Send To Warehouse",
                  onPressed: () {
                    var status = _formKey.currentState!.validate();
                    if (status == true) {
                      qrCodeList.clear();
                      var index =
                          warehouseStringList.indexOf(selectedWarehouse ?? '');
                      for (var item in widget.qrCodeList) {
                        item.wareHouseId = wareHouseList[index].wareHouseId;
                        item.vehicleNo = truckController.text;
                        qrCodeList.add(item);
                      }
                      dispatchedToWarehouse();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget districtDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistrictValue,
      hint: Text("Select a District"),
      items: districtStringList
          .map((String value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: (newValue) {
        selectedWarehouse = null;
        setState(() {
          selectedDistrictValue = newValue;
        });
        getWareHouseAPICall();
      },
      validator: (value) {
        if (value == null) {
          return 'Please select district';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "District",
        labelStyle: TextStyle(color: Colors.green.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded border
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget wareHouseDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedWarehouse,
      hint: Text("Select a Warehouse"),
      items: warehouseStringList
          .map((String value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedWarehouse = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select warehouse';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Warehouse",
        labelStyle: TextStyle(color: Colors.green.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded border
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget truckNumberField() {
    return TextFormField(
      controller: truckController,
      validator: (value) {
        if (value != null && value.trim().isEmpty) {
          return 'Please enter vehicle number';
        } else if ((value ?? '').trim().length < 10) {
          return 'Please enter correct number';
        }
        return null;
      },
      inputFormatters: [UpperCaseTextFormatter()],
      decoration: InputDecoration(
        labelText: "Vehicle Number",
        labelStyle: TextStyle(color: Colors.green.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
