import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/Screens/Incharge/upload_warehouse_screen/upload_warehouse_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_service.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
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
  Map<String, List<DispatchInchargeModel>> groupedData = {};

  int? userType;

  @override
  void initState() {
    super.initState();
    getUserType();
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

      if (!mounted) return;
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

        Navigator.pop(context);
        if (!mounted) return;

        if (response?.status == true) {
          setState(() {
            diapatchInchargeList = response?.data ?? [];
            groupData(); // 🚀 Grouping call
          });
        } else {
          showErrorToast(response?.error ?? 'Something went wrong');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  /// 🚀 GROUPING FUNCTION
  void groupData() {
    groupedData = {};
    for (var item in diapatchInchargeList) {
      final key = item.dispatch_id?.toString() ?? 'Unknown';
      groupedData.putIfAbsent(key, () => []);
      groupedData[key]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = groupedData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(userType == 13 ? "Accepted Records" : "Dispatch Records"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: searchBar(),
          ),

          /// 📌 GROUPED LIST
          Expanded(
            child: groupedData.isEmpty
                ? Center(child: Text("No Records Found"))
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final groupKey = keys[index];
                      final items = groupedData[groupKey]!;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            "Dispatch ID: $groupKey",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            "Items: ${items.length}",
                            style: TextStyle(fontSize: 13),
                          ),
                          tilePadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          childrenPadding: EdgeInsets.all(16),

                          /// 🔽 Expanded list items
                          children: items.map((details) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 5,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  InformationRow(
                                      title: "Lot no.",
                                      subtitle: "${details.lotNo ?? 'NA'}"),
                                  InformationRow(
                                      title: "Registration no.",
                                      subtitle: details.farmerRegId ?? 'NA'),
                                  InformationRow(
                                      title: "Purchase Center",
                                      subtitle:
                                          details.purchaseCenterKendra ?? 'NA'),
                                  if (details.transctionDate != null)
                                    InformationRow(
                                        title: "Purchase Date",
                                        subtitle:
                                            DateFormatter.formatDateToDDMMMYYYY(
                                                details.transctionDate ?? '')),
                                  if (details.dispatchDateTime != null)
                                    InformationRow(
                                        title: "Dispatch Date",
                                        subtitle:
                                            DateFormatter.formatDateToDDMMMYYYY(
                                                details.dispatchDateTime ??
                                                    '')),
                                  if (details.receivedDateTime != null)
                                    InformationRow(
                                        title: "Received Date",
                                        subtitle:
                                            DateFormatter.formatDateToDDMMMYYYY(
                                                details.receivedDateTime ??
                                                    '')),
                                  InformationRow(
                                      title: "No. of Bardana",
                                      subtitle:
                                          "${details.noOfBardana ?? 'NA'}"),
                                  InformationRow(
                                      title: "Crop Type",
                                      subtitle: (details.cropEN ??
                                          details.crop_descEN ??
                                          'NA')),
                                  InformationRow(
                                      title: "Warehouse",
                                      subtitle: details.warehouseName ?? 'NA'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }

  /// 🔍 SEARCH BAR
  Widget searchBar() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              focusNode: _focusNode,
              controller: vehicleController,
              inputFormatters: [UpperCaseTextFormatter()],
              style: TextStyle(fontWeight: FontWeight.w600),
              maxLength: 12,
              decoration: InputDecoration(
                hintText: "Vehicle number",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter correct number";
                }
                if (value.trim().length < 8 || value.trim().length > 12) {
                  return "Please enter correct number";
                }
                return null;
              },
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: getDispatchedList,
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
