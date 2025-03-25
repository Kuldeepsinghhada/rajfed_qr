import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Operator/Home/views/Information_row.dart';
import 'package:rajfed_qr/Screens/Operator/rejected_screen/rejected_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/rejected_model.dart';
import 'package:rajfed_qr/utils/date_formatter.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class RejectedScreen extends StatefulWidget {
  const RejectedScreen({super.key});

  @override
  State<RejectedScreen> createState() => _RejectedScreenState();
}

class _RejectedScreenState extends State<RejectedScreen> {
  List<RejectedModel> rejectedList = [];

  @override
  void initState() {
    getOperatorDetails();
    super.initState();
  }

  void getOperatorDetails() async {
    await Future.delayed(Duration(microseconds: 200));
    showLoadingDialog(context);
    try {
      var response = await RejectedService.instance.operatorRejectedList();
      if (response?.status == true) {
        Navigator.pop(context);
        setState(() {
          rejectedList = response?.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rejected Records"),
      ),
      body: ListView.builder(
          itemCount: rejectedList.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            var details = rejectedList[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(4), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Shadow color
                    spreadRadius: 2, // Spread of shadow
                    blurRadius: 10, // Blur effect
                    offset: Offset(2, 2), // Shadow position
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  InformationRow(
                      title: "Lot no.", subtitle: "${details.lotNo ?? 'NA'}"),
                  InformationRow(
                      title: "Registration no.",
                      subtitle: details.farmerRegId ?? 'NA'),
                  InformationRow(
                      title: "QR Code", subtitle: details.qrCode ?? 'NA'),
                  InformationRow(
                      title: "Purchase Center",
                      subtitle: details.purchaseCenterKendra ?? 'NA'),
                  InformationRow(
                      title: "Rejected Date",
                      subtitle: DateFormatter.formatDateToDDMMMYYYY(
                          details.rejectedDate ?? 'NA')),
                  // InformationRow(
                  //     title: "Quantity(Qtl)",
                  //     subtitle: (details. ?? 'NA').toString()),
                  // InformationRow(
                  //     title: "No. of Bardana",
                  //     subtitle: (details. ?? 'NA').toString()),
                  // InformationRow(
                  //     title: "Crop Type",
                  //     subtitle: (details.cropEN ?? 'NA')),
                  // InformationRow(
                  //     title: "Warehouse Name",
                  //     subtitle: (details.warehouseName ?? 'NA')),
                ],
              ),
            );
          }),
    );
  }
}
