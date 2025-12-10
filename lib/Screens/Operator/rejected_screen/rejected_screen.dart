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
  Map<String, List<RejectedModel>> groupedData = {};

  @override
  void initState() {
    super.initState();
    getOperatorDetails();
  }

  void getOperatorDetails() async {
    await Future.delayed(const Duration(microseconds: 200));
    if (!mounted) return;

    showLoadingDialog(context);
    try {
      var response = await RejectedService.instance.operatorRejectedList();

      Navigator.pop(context);
      if (!mounted) return;

      if (response?.status == true) {
        setState(() {
          rejectedList = response?.data ?? [];
          groupByFarmer();
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

  /// 🔹 GROUPING
  void groupByFarmer() {
    groupedData = {};
    for (var item in rejectedList) {
      final key = item.farmerRegId ?? 'Unknown';
      groupedData.putIfAbsent(key, () => []);
      groupedData[key]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerKeys = groupedData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rejected Records"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: farmerKeys.length,
        itemBuilder: (context, index) {
          final farmerId = farmerKeys[index];
          final items = groupedData[farmerId]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              title: Text(
                "Farmer Reg ID: $farmerId",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "Rejected Items: ${items.length}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              children: items.map((details) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InformationRow(
                          title: "Lot No.",
                          subtitle: "${details.lotNo ?? 'NA'}"),
                      InformationRow(
                          title: "QR Code", subtitle: details.qrCode ?? 'NA'),
                      InformationRow(
                          title: "Purchase Center",
                          subtitle: details.purchaseCenterKendra ?? 'NA'),
                      InformationRow(
                          title: "Rejected Date",
                          subtitle: DateFormatter.formatDateToDDMMMYYYY(
                              details.rejectedDate ?? 'NA')),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
