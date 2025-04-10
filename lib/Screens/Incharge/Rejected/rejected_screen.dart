import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Incharge/upload_warehouse_screen/upload_warehouse_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/utils/date_formatter.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class RejectedInchargeScreen extends StatefulWidget {
  const RejectedInchargeScreen({super.key});

  @override
  State<RejectedInchargeScreen> createState() => _RejectedInchargeScreenState();
}

class _RejectedInchargeScreenState extends State<RejectedInchargeScreen> {
  final TextEditingController vehicleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  List<DispatchInchargeModel> rejectedInchargeList = [];
  int? isReSubmit = -1;
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

  void getRejectedList() async {
    _focusNode.unfocus();
    var valid = _formKey.currentState?.validate();
    if (valid == true) {
      await Future.delayed(Duration(microseconds: 200));
      showLoadingDialog(context);
      try {
        dynamic response;
        var userType = await SharedPreferenceHelper.instance.getUserType();
        if (userType == 2) {
          response = await InchargeService.instance
              .rejectedInchargeList(vehicleController.text);
        } else {
          response = await WarehouseService.instance
              .rejectedWareHouseList(vehicleController.text);
        }
        if (response?.status == true) {
          Navigator.pop(context);
          setState(() {
            rejectedInchargeList = response?.data;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rejected Records"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: searchBar(),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: rejectedInchargeList.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  var details = rejectedInchargeList[index];
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
                        Row(
                          children: [
                            Expanded(
                              child: InformationRow(
                                  title: "Lot no.",
                                  subtitle: "${details.lotNo ?? ''}"),
                            ),
                            Visibility(
                              visible: userType != 5,
                              child: Checkbox(
                                  value: isReSubmit == index,
                                  onChanged: (value) {
                                    setState(() {
                                      if (isReSubmit == index) {
                                        isReSubmit = -1;
                                      } else {
                                        isReSubmit = index;
                                      }
                                    });
                                  }),
                            )
                          ],
                        ),
                        InformationRow(
                            title: "Registration no.",
                            subtitle: details.farmerRegId ?? ''),
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
                        isReSubmit == index
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: CommonButton(
                                    text: "ReSubmit",
                                    onPressed: () async {
                                      var status =
                                          _formKey.currentState!.validate();
                                      if (status != true) {
                                        return;
                                      }
                                      var purchaseCenterId =
                                          await SharedPreferenceHelper.instance
                                              .getPurchaseCenterId();
                                      var object = SavedQrModel();
                                      object.qrCode = details.qrCode;
                                      object.farmerRegId = details.farmerRegId;
                                      object.lotNo = details.lotNo;
                                      object.cropId = details.cropID;
                                      object.purchaseCenterId =
                                          purchaseCenterId;
                                      var data = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UploadWarehouseScreen(
                                                      qrCodeList: [object])));
                                      if (data == true) {
                                        getRejectedList();
                                      }
                                    }),
                              )
                            : SizedBox()
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
        children: [
          // Search Field
          Expanded(
            child: TextFormField(
              focusNode: _focusNode,
              controller: vehicleController,
              inputFormatters: [UpperCaseTextFormatter()],
              maxLength: 10,
              style: TextStyle(fontWeight: FontWeight.w600),
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
              getRejectedList();
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
