import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_services.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/OpenSource/crop_calculate/crop_calculate_service.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/crop_list_model.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/farmer_details_model.dart';
import 'package:rajfed_qr/models/yield_master.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class CropCalculaterScreen extends StatefulWidget {
  const CropCalculaterScreen({super.key});

  @override
  State<CropCalculaterScreen> createState() => _CropCalculaterScreenState();
}

class _CropCalculaterScreenState extends State<CropCalculaterScreen> {
  String? selectedCrop;
  List<String> cropItems = [];
  List<CropModel> cropList = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>(); // Key to track form state

  FarmerDetailsModel? data;
  var showFilter = true;

  int? purchaseCenterID;

  String? selectedDistrictValue;
  List<DistrictModel> districtList = [];
  List<String> districtStringList = [];

  @override
  void initState() {
    getCropAPICall();
    getDistrictAPICall();
    super.initState();
  }

  void getCropAPICall() async {
    purchaseCenterID =
        await SharedPreferenceHelper.instance.getPurchaseCenterId();
    if (DataManager.instance.cropList.isNotEmpty) {
      cropList = DataManager.instance.cropList;
      cropItems = DataManager.instance.cropStringList;
      setState(() {});
      return;
    }

    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await OPHomeService.instance.getCropList();
      if (!mounted) return;
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
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
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

  void getFarmerDetails() async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    var index = cropItems.indexOf(selectedCrop ?? '');
    if (index < 0) {
      showErrorToast("Crop not found");
      return;
    }
    if (valid == true) {
      if (!mounted) return;
      showLoadingDialog(context);
      try {
        var response = await FarmerService.instance
            .farmerDetails(_searchController.text, cropList[index].cropID ?? 0);
        if (response?.status == true) {
          if (!mounted) return;
          Navigator.pop(context);
          setState(() {
            data = response?.data;
            showFilter = false;
          });
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          showErrorToast(response?.error ?? 'Something Went wrong');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  void onSearchYield() async {
    _focusNode.unfocus();
    if (_formKey.currentState?.validate() != true) return;
    int cropId = 0;
    String? districtId;
    for (var crop in cropList) {
      if (crop.cropDescEN == selectedCrop) {
        cropId = crop.cropID ?? 0;
        break;
      }
    }

    for (var district in districtList) {
      if (district.districtNameEN == selectedDistrictValue) {
        districtId = district.district ?? '';
        break;
      }
    }

    showLoadingDialog(context);
    try {
      final response = await CropCalculateService.instance.getYield(
        districtId ?? '',
        cropId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (response.status) {
        // Handle success (show result, update UI, etc.)
        YieldMaster? yieldMaster = response.data;
        double? maxSell =
            (yieldMaster?.yieldRate ?? 0) * int.parse(_searchController.text);
        maxSell = (maxSell > 40 ? 40 : maxSell);
        var hectare = int.parse(_searchController.text);
        showMaxSellDialog(context, maxSell);
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: Text(
        //       'आपकी अधिकतम तुलन क्षमता ${maxSell?.toInt()} QTL है',
        //       style: TextStyle(fontSize: 18),
        //       textAlign: TextAlign.center,
        //     ),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.of(context).pop(),
        //         child: Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
      } else {
        showErrorToast(response.error ?? "Failed to fetch yield");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Error: $e");
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Visibility(
                  visible: showFilter,
                  child: Column(
                    children: [
                      districtDropdown(),
                      SizedBox(
                        height: 16,
                      ),
                      cropDropDown(),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        focusNode: _focusNode,
                        controller: _searchController,
                        keyboardType: TextInputType.number, // Numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Restricts to numbers only
                        ],
                        maxLength: 8,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: "Enter hectare",
                          hintStyle: TextStyle(fontWeight: FontWeight.w500),
                          filled: true,
                          counter: Text(''),
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter hectare";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onSearchYield,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                "Search".toUpperCase(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget districtDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonFormField<String>(
        value: selectedDistrictValue,
        icon: Icon(Icons.arrow_drop_down),
        hint: Text(
          'Select a District',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        isExpanded: true,
        items: districtStringList
            .map((String value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (newValue) {
          setState(() {
            selectedDistrictValue = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select district';
          }
          return null;
        },
        decoration: InputDecoration(
          fillColor: Colors.grey[100],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.transparent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget cropDropDown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      // decoration: BoxDecoration(
      //   color: Colors.grey[100],
      //   //border: Border.all(color: Colors.deepPurple),
      //   borderRadius: BorderRadius.circular(30), // Rounded corners
      // ),
      child: DropdownButtonFormField<String>(
        value: selectedCrop,
        icon: Icon(Icons.arrow_drop_down),
        hint: Text(
          'Please select crop',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        isExpanded: true,
        decoration: InputDecoration(
          fillColor: Colors.grey[100],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.transparent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (String? newValue) {
          setState(() {
            selectedCrop = newValue!;
          });
        },
        validator: (value) {
          if (value == null) {
            return "Please select value";
          }
          setState(() {
            selectedCrop = value;
          });
          return null;
        },
        items: cropItems.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRow(String title, String? value) {
    if (value == null || value == "") {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: Text('$title:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 6,
              child: Text(value.trim(),
                  style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

/// Call this function where आप dialog दिखाना चाहते हैं:
/// showMaxSellDialog(context, maxSell);
Future<void> showMaxSellDialog(BuildContext context, double? maxSell) {
  final message = "आपकी अधिकतम तुलन क्षमता ${maxSell?.toInt()} QTL है";

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MaxSellDialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: _ModernDialogContent(message: message),
      );
    },
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curved = Curves.easeOutBack.transform(anim1.value);
      return Transform.scale(
        scale: curved,
        child: Opacity(opacity: anim1.value, child: child),
      );
    },
  );
}

class _ModernDialogContent extends StatelessWidget {
  final String message;
  const _ModernDialogContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            // gradient: const LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [Color(0xFF0F172A), Color(0xFF122036)],
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon + title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(Icons.trending_up,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'जानकारी',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        // Close X
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Message
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Buttons
                    Row(
                      children: [
                        // Expanded(
                        //   child: ElevatedButton.icon(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.transparent,
                        //       side: BorderSide(color: Colors.white24),
                        //       elevation: 0,
                        //       padding: const EdgeInsets.symmetric(
                        //           vertical: 12, horizontal: 12),
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10)),
                        //     ),
                        //     icon: const Icon(Icons.copy, size: 18),
                        //     label: const Text('Copy'),
                        //     onPressed: () async {
                        //       await Clipboard.setData(ClipboardData(text: message));
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(content: Text('Copied to clipboard')),
                        //       );
                        //     },
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
