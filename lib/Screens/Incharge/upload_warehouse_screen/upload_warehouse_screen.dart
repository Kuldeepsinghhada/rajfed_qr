import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_dashboard/incharge_dashboard_screen.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/models/vehicle_model.dart';
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
  String? selectedVehicle;
  List<VehicleModel> vehicleList = [];
  List<String> vehicleStringList = [];

  // Warehouse lists
  List<WareHouseModel> wareHouseList = [];
  List<String> warehouseStringList = [];
  List<int?> warehouseIdList = [];

  final List<SavedQrModel> qrCodeList = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getDistrictAPICall();
    getVehicleAPICall();
    super.initState();
  }

  void getDistrictAPICall() async {
    await Future.delayed(Duration(microseconds: 200));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await InchargeService.instance.getDistrictList();
      if (!mounted) return;
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
      if (!mounted) return;
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
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await InchargeService.instance.getWareHouseList(
        districtList[index].district ?? '',
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (response?.status == true) {
        // populate local lists and keep indices aligned
        wareHouseList = response?.data ?? [];
        warehouseStringList.clear();
        warehouseIdList.clear();
        for (var item in wareHouseList) {
          final name = (item.wareHouseName ?? '').trim();
          if (name.isNotEmpty) {
            warehouseStringList.add(name);
            warehouseIdList.add(item.wareHouseId);
          }
        }
        // Log parsed warehouse ids and names for debugging
        log(
          'getWareHouseAPICall parsed warehouses (all): ' +
              wareHouseList
                  .map(
                    (w) => '{id: ${w.wareHouseId}, name: ${w.wareHouseName}}',
                  )
                  .join(', '),
        );
        log(
          'getWareHouseAPICall display list: ' +
              warehouseStringList
                  .asMap()
                  .entries
                  .map(
                    (e) =>
                        '{index: ${e.key}, id: ${warehouseIdList[e.key]}, name: ${e.value}}',
                  )
                  .join(', '),
        );
        setState(() {});
      } else {
        showErrorToast(response?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void getVehicleAPICall() async {
    await Future.delayed(Duration(microseconds: 200));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await InchargeService.instance.getVehicleDetail();
      if (!mounted) return;
      Navigator.pop(context);
      if (response?.status == true) {
        vehicleList = response?.data ?? [];
        for (var item in vehicleList) {
          if (item.truckNo != null) {
            vehicleStringList.add(item.truckNo!);
          }
        }
        setState(() {});
      } else {
        showErrorToast(response?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void dispatchedToWarehouse() async {
    final dio = Dio();
    if (!mounted) return;
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
        "vehicleNo": item.vehicleNo,
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
            "Content-Type": "application/json",
          },
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        DataManager.instance.savedGadiItems = [];
        showSuccessToast("Record sent to warehouse successfully");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => InchargeDashboard()),
          (route) => false,
        );
      } else {
        showErrorToast('Record Not updated');
      }
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
      log("Error: ${e.toString()}");
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
              vehicleDropdown(),
              CommonButton(
                text: "Send To Warehouse",
                onPressed: () {
                  var status = _formKey.currentState!.validate();
                  if (status == true) {
                    qrCodeList.clear();
                    if (selectedWarehouse == null) {
                      Fluttertoast.showToast(msg: 'Please select warehouse');
                      return;
                    }
                    var index = warehouseStringList.indexOf(selectedWarehouse!);
                    if (index < 0 || index >= warehouseIdList.length) {
                      // log and show error
                      log(
                        'Invalid warehouse selection: selected="$selectedWarehouse", index=$index, warehouseIdListLength=${warehouseIdList.length}, wareHouseListLength=${wareHouseList.length}',
                      );
                      Fluttertoast.showToast(
                        msg: 'Please select a valid warehouse',
                      );
                      return;
                    }
                    final selectedId = warehouseIdList[index];
                    if (selectedId == null) {
                      log('Selected warehouse id is null for index $index');
                      Fluttertoast.showToast(
                        msg: 'Selected warehouse has no valid id',
                      );
                      return;
                    }
                    // Log warehouse selected id
                    log(
                      'Selected warehouse id: $selectedId, name: ${warehouseStringList[index]}',
                    );
                    for (var item in widget.qrCodeList) {
                      item.wareHouseId = selectedId;
                      item.vehicleNo = selectedVehicle;
                      qrCodeList.add(item);
                    }
                    // Log payload being sent
                    log(
                      'Dispatch payload: ' +
                          jsonEncode(
                            qrCodeList.map((e) => e.toJson()).toList(),
                          ),
                    );
                    dispatchedToWarehouse();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget districtDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDistrictValue,
      hint: Text("Select a District"),
      items: districtStringList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
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

  Widget vehicleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedVehicle,
      hint: Text("Select Vehicle"),
      items: vehicleStringList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedVehicle = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select vehicle';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Vehicle",
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
      initialValue: selectedWarehouse,
      hint: Text("Select a Warehouse"),
      items: warehouseStringList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
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
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
