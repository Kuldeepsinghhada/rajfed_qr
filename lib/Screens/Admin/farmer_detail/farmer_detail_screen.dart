import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_services.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/crop_list_model.dart';
import 'package:rajfed_qr/models/farmer_details_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class FarmerDetailScreen extends StatefulWidget {
  const FarmerDetailScreen({super.key});

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  String? selectedCrop;
  List<String> cropItems = [];
  List<CropModel> cropList = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>(); // Key to track form state

  FarmerDetailsModel? data;
  var showFilter = true;

  int? purchaseCenterID;

  @override
  void initState() {
    getCropAPICall();
    super.initState();
  }

  void getCropAPICall() async {
    purchaseCenterID  = await SharedPreferenceHelper.instance.getPurchaseCenterId();
    if(DataManager.instance.cropList.isNotEmpty) {
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
          showErrorToast("Something went wrong");
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
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
        title: Text('Farmer Details'),
        actions: [
          purchaseCenterID == null ? IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Text('LOGIN',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16))) : SizedBox()
        ],
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
                          hintText: "Farmer Reg. number",
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
                          if (value?.trim().length != 8) {
                            return "Please enter correct registration number";
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                getFarmerDetails();
                              },
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
                // Farmer Details
                Visibility(
                  visible: data != null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    margin: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Shadow color
                          spreadRadius: 2, // Spread of shadow
                          blurRadius: 10, // Blur effect
                          offset: Offset(4, 4), // Shadow position
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRow('Farmer Reg. ID', data?.farmerRegID),
                            buildRow('Farmer Name', data?.farmerNameEN),
                            buildRow('Purchase Center', data?.purchaseCenterKendra),
                            buildRow('Crop', data?.cropDescEN),
                            const Divider(),
                            buildRow(
                                'Registration Date', formatDate(data?.regDate)),
                            buildRow('Date of Allotment',
                                formatDate(data?.dateAllotment)),
                            buildRow(
                                'Purchase Date', formatDate(data?.purchaseDate)),
                            buildRow('Girdawri Check Date',
                                formatDate(data?.girdawriCheckDate)),
                            buildRow('Order Sheet Date',
                                formatDate(data?.paymentTransOrderSheetDate)),
                            const Divider(),
                            buildRow('Quantity (Qtl)', '${data?.transctionQty}'),
                            buildRow('Amount (₹)',
                                '₹ ${data?.paymentTransTransferAmount}'),
                            const Divider(),
                            buildRow('Bank A/C No.', data?.bankAccNo?.trim()),
                            buildRow('IFSC Code', data?.ifsCCODE),
                            buildRow('UTR', data?.utr),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(onPressed: (){
                            setState(() {
                              showFilter = true;
                            });
                          }, icon: Icon(Icons.edit)),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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
