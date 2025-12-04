import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/Screens/Incharge/upload_warehouse_screen/upload_warehouse_screen.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';

class VerifyVehicleLoadScreen extends StatefulWidget {
  const VerifyVehicleLoadScreen({super.key});

  @override
  State<VerifyVehicleLoadScreen> createState() =>
      _VerifyVehicleLoadScreenState();
}

class _VerifyVehicleLoadScreenState extends State<VerifyVehicleLoadScreen> {
  Map<String, List<SavedQrModel>> farmerGroups = {};
  Set<String> expandedGroups = {}; // store expanded tiles
  List<SavedQrModel> qrCodeList = [];
  @override
  void initState() {
    super.initState();
    qrCodeList = DataManager.instance.savedGadiItems;
    farmerGroups = groupByFarmer(qrCodeList);
  }

  Map<String, List<SavedQrModel>> groupByFarmer(List<SavedQrModel> list) {
    Map<String, List<SavedQrModel>> map = {};

    for (var item in list) {
      final key = item.farmerRegId ?? "Unknown";

      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(item);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("गाड़ी में लोड माल की पुष्टि"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP SUMMARY
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Text(
              "${qrCodeList.length} बोरियों का डेटा स्कैन हो चुका है, ये बोरियाँ गाड़ी में जाएँगी",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade400)),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: Colors.green.shade400,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        // Icon(
                        //   Icons.qr_code_scanner,
                        //   color: Colors.white,
                        // ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              "Registration Number",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        // Checkbox(
                        //   value: selectedNumberList.length ==
                        //       scannedNumberList.length &&
                        //       scannedNumberList.isNotEmpty,
                        //   checkColor: Colors.green,
                        //   activeColor: Colors.white,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       if (value == true) {
                        //         selectedNumberList =
                        //             List.from(scannedNumberList);
                        //       } else {
                        //         selectedNumberList.clear();
                        //       }
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(12),
                      children: farmerGroups.entries.map((entry) {
                        final farmerId = entry.key;
                        final list = entry.value;
                        final isExpanded = expandedGroups.contains(farmerId);
                        return Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              // TILE HEADER
                              ListTile(
                                title: Text(
                                  farmerId,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                subtitle:
                                    Text("बोरियाँ : ${list.length.toString()}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Delete Group Button
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text("Delete Group?"),
                                            content: Text(
                                                "क्या आप इस किसान की सभी QR एंट्री डिलीट करना चाहते हैं?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: Text("Delete"),
                                                onPressed: () {
                                                  setState(() {
                                                    qrCodeList.removeWhere(
                                                        (e) =>
                                                            e.farmerRegId ==
                                                            farmerId);
                                                    farmerGroups =
                                                        groupByFarmer(
                                                            qrCodeList);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    // Expand/Collapse Arrow
                                    Icon(isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      expandedGroups.remove(farmerId);
                                    } else {
                                      expandedGroups.add(farmerId);
                                    }
                                  });
                                },
                              ),

                              // EXPANDED LIST
                              if (isExpanded)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Column(
                                    children: list.map((qr) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                qr.qrCode ?? "",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ADD MORE Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Navigate back or your Add More logic
                    Navigator.pop(context);
                  },
                  child: Text(
                    "नया जोड़ें",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // PROCEED Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UploadWarehouseScreen(qrCodeList: qrCodeList)));
                  },
                  child: Text(
                    "रवाना करें",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
