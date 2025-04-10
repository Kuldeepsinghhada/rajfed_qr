import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Incharge/upload_warehouse_screen/upload_warehouse_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/utils/date_formatter.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class DiapatchInchargeScreen extends StatefulWidget {
  const DiapatchInchargeScreen({super.key});

  @override
  State<DiapatchInchargeScreen> createState() => _DiapatchInchargeScreenState();
}

class _DiapatchInchargeScreenState extends State<DiapatchInchargeScreen> {
  final TextEditingController vehicleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  List<DispatchInchargeModel> diapatchInchargeList = [];
  int? userType;
  @override
  void initState() {
    getUserType();
    super.initState();
  }

  getUserType() async {
    userType = await SharedPreferenceHelper.instance.getUserType();
    setState(() {});
  }

  void getDispatchedList() async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      diapatchInchargeList.clear();
      await Future.delayed(Duration(microseconds: 200));
      showLoadingDialog(context);
      try {
        dynamic response;
        if (userType == 2) {
          response = await InchargeService.instance
              .sentInchargeList(vehicleController.text);
        } else {
          response = await WarehouseService.instance
              .acceptedWarehouseList(vehicleController.text);
        }
        if (response?.status == true) {
          Navigator.pop(context);
          setState(() {
            diapatchInchargeList = response?.data;
          });
        } else {
          Navigator.pop(context);
          showErrorToast(response?.error ?? 'Something went wrong');
        }
      } catch (e) {
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userType == 5 ? "Accepted Records" : "Dispatch Records"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: searchBar(),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: diapatchInchargeList.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  var details = diapatchInchargeList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(4), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Shadow color
                          spreadRadius: 2, // Spread of shadow
                          blurRadius: 5, // Blur effect
                          offset: Offset(2, 2), // Shadow position
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        InformationRow(
                            title: "Lot no.",
                            subtitle: "${details.lotNo ?? 'NA'}"),
                        InformationRow(
                            title: "Registration no.",
                            subtitle: details.farmerRegId ?? 'NA'),
                        InformationRow(
                            title: "QR Code", subtitle: details.qrCode ?? 'NA'),
                        InformationRow(
                            title: "Purchase Center",
                            subtitle: details.purchaseCenterKendra ?? 'NA'),
                        Visibility(
                            visible: details.transctionDate != null,
                            child: InformationRow(
                                title: "Purchase Date",
                                subtitle: DateFormatter.formatDateToDDMMMYYYY(
                                    details.transctionDate ?? 'NA'))),
                        Visibility(
                            visible: details.dispatchDateTime != null,
                            child: InformationRow(
                                title: "Dispatch Date",
                                subtitle: DateFormatter.formatDateToDDMMMYYYY(
                                    details.dispatchDateTime ?? 'NA'))),
                        Visibility(
                            visible: details.receivedDateTime != null,
                            child: InformationRow(
                                title: "Received Date",
                                subtitle: DateFormatter.formatDateToDDMMMYYYY(
                                    details.receivedDateTime ?? 'NA'))),
                        InformationRow(
                            title: "Quantity(Qtl)",
                            subtitle: (details.qtl ?? 'NA').toString()),
                        InformationRow(
                            title: "No. of Bardana",
                            subtitle: (details.noOfBardana ?? 'NA').toString()),
                        InformationRow(
                            title: "Crop Type",
                            subtitle: (details.cropEN ??
                                details.crop_descEN ??
                                'NA')),
                        InformationRow(
                            title: "Warehouse Name",
                            subtitle: (details.warehouseName ?? 'NA')),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          Expanded(
            child: TextFormField(
              focusNode: _focusNode,
              controller: vehicleController,
              inputFormatters: [UpperCaseTextFormatter()],
              style: TextStyle(fontWeight: FontWeight.w600),
              maxLength: 10,
              decoration: InputDecoration(
                hintText: "Vehicle number",
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
                  return "Please enter correct number";
                } else if ((value ?? '').trim().length != 10) {
                  return "Please enter correct number";
                }
                return null;
              },
            ),
          ),

          SizedBox(width: 10), // Space between

          // Search Button
          GestureDetector(
            onTap: () {
              getDispatchedList();
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
      ),
    );
  }
}
