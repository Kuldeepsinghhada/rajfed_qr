import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/Screens/Operator/DataScreen/data_services.dart';
import 'package:rajfed_qr/Screens/Operator/DataScreen/views/data_gridview.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/crop_list_model.dart';
import 'package:rajfed_qr/models/dashboard_data_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  DashboardDataModel? dataModel;

  String? selectedCrop;
  DateTime? startDate;
  DateTime? endDate;

  String? startStringDate;
  String? endStringDate;

  List<String> cropItems = [];
  List<CropModel> cropList = [];
  final dateFormat = DateFormat('dd/MM/yyyy');

  Future<bool> selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
    return true;
  }

  @override
  void initState() {
    getCropList();
    getDashboardAPICall();
    super.initState();
  }

  getCropList() {
    cropItems = DataManager.instance.cropStringList;
    if (cropItems.isEmpty) {
      getCropAPICall();
    }
  }

  void getCropAPICall() async {
    await Future.delayed(Duration(milliseconds: 100));
    showLoadingDialog(context);
    try {
      var response = await OPHomeService.instance.getCropList();
      Navigator.pop(context);
      if (response.status == true) {
        cropList = response.data;
        cropList.removeWhere((obj) => obj.cropID == 0);
        for (var item in cropList) {
          if (item.cropDescEN != null) {
            cropItems.add(item.cropDescEN!);
          }
        }
        DataManager.instance.cropList = cropList;
        DataManager.instance.cropStringList = cropItems;
        setState(() {});
      } else {
        showErrorToast(response.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void getDashboardAPICall() async {
    await Future.delayed(Duration(milliseconds: 100));
    showLoadingDialog(context);
    try {
      int? cropId;
      var index =
          DataManager.instance.cropStringList.indexOf(selectedCrop ?? '');
      if (index != -1) {
        cropId = DataManager.instance.cropList[index].cropID;
      }
      var response = await DataService.instance.dashboardDataList(
          startDate != null ? dateFormat.format(startDate!) : null,
          endDate != null ? dateFormat.format(endDate!) : null,
          cropId: cropId);
      Navigator.pop(context);
      if (response.status == true) {
        if (response.data is List && response.data.isNotEmpty) {
          dataModel = response.data[0];
        }
        setState(() {});
      } else {
        showErrorToast(response.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  Widget filterView() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return SafeArea(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets, // for keyboard safety
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedCrop = null;
                            startDate = null;
                            endDate = null;
                          });
                          Navigator.pop(context);
                          getDashboardAPICall();
                        },
                        child: Text(
                          'CLEAR FILTER',
                          style: TextStyle(color: Colors.green),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCrop,
                  decoration: const InputDecoration(
                    labelText: 'Select Crop',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                  ),
                  items: cropItems.map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setModalState(() {
                      selectedCrop = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    await selectDate(context, true);
                    setModalState(() {});
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                    child: Text(startDate != null
                        ? dateFormat.format(startDate!)
                        : 'Select date'),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    await selectDate(context, false);
                    setModalState(() {});
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                    child: Text(endDate != null
                        ? dateFormat.format(endDate!)
                        : 'Select date'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (startDate == null && endDate == null) {
                      } else if (startDate != null && endDate != null) {
                        endStringDate = dateFormat.format(endDate!);
                        startStringDate = dateFormat.format(startDate!);
                      } else {
                        Fluttertoast.showToast(msg: "Select Start & End Date");
                        return;
                      }
                      Navigator.pop(context);
                      getDashboardAPICall();
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text('Apply Filter',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // ✅ Green background
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Portal",
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    selectedCrop != null
                        ? Text(
                            selectedCrop ?? '',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          )
                        : Container(
                            color: Colors.green,
                          ),
                    SizedBox(width: selectedCrop != null ? 12 : 0),
                    Text(
                      "${startStringDate ?? ""} - ${endStringDate ?? ""}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    )
                  ],
                )),
                TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // for full-height behavior
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => filterView(),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Filter',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                  fontSize: 16),
                            ),
                            SizedBox(
                                width: (selectedCrop != null ||
                                        startDate != null ||
                                        endDate != null)
                                    ? 12
                                    : 0),
                          ],
                        ),
                        Visibility(
                            visible: (selectedCrop != null ||
                                startDate != null ||
                                endDate != null),
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.redAccent,
                            ))
                      ],
                    )),
              ],
            ),
          ),
          dataModel != null ? DataGridView(dataModel: dataModel) : SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey.shade300),
          )
        ],
      ),
    );
  }
}
