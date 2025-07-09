import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Admin/total_purchase_screen.dart';
import 'package:rajfed_qr/Screens/Admin/total_registration_screen.dart';
import 'package:rajfed_qr/models/dashboard_data_model.dart';
import 'package:rajfed_qr/utils/utilities.dart';

class DataGridView extends StatefulWidget {
  const DataGridView({required this.dataModel, super.key});
  final DashboardDataModel? dataModel;
  @override
  State<DataGridView> createState() => _DataGridViewState();
}

class _DataGridViewState extends State<DataGridView> {
  List<Map<String, dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    updateList();
  }

  updateList() {
    items = [
      {
        "title": "Total Registration",
        "image": Icons.app_registration,
        'color': Color(0xFFAB47BC),
        'amount': widget.dataModel?.totalRegisteredFarmers
      },
      {
        "title": "Total Purchase",
        "image": Icons.shopping_cart_outlined,
        'color': Color(0xFF1CC88A),
        'amount': widget.dataModel?.purchaseTransactions
      },
      {
        "title": "Total Payment",
        "image": Icons.payment,
        'color': Color(0xFFFFC107),
        'amount': widget.dataModel?.paymentDoneFarmers
      },
      {
        "title": "QR Attached",
        "image": Icons.qr_code_2,
        'color': Color(0xFFFFC107),
        'amount': widget.dataModel?.qRGeneratedFarmers
      },
      {
        "title": "QR Remaining",
        "image": Icons.qr_code,
        'color': Color(0xFFF65A5B),
        'amount': (widget.dataModel?.totalRegisteredFarmers ?? 0) -
            (widget.dataModel?.qRGeneratedFarmers ?? 0)
      },
      {
        "title": "Dispatched",
        "image": Icons.local_shipping_outlined,
        'color': Color(0xFF36B9CC),
        'amount': widget.dataModel?.dispatchedFarmers
      }
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width to set column count
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : 4;

    return GridView.builder(
      padding: EdgeInsets.all(12),
      itemCount: items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.5),
      //scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.green.shade50,
          // decoration: BoxDecoration(
          //   color: Colors.green.shade50,
          //   borderRadius: BorderRadius.circular(12),
          //   border: Border.all(
          //     color: Colors.grey.shade600, // Ya koi bhi color
          //     width: 1.0, // Thickness of the border
          //   ),
          // ),
          //elevation: 4,
          //color: items[index]['color'],
          child: InkWell(
            onTap: () {
              if (index == 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TotalRegistrationScreen()));
              } else if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TotalPurchaseScreen()));
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 4,
                children: [
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(items[index]["image"]!,
                          size: 30, color: Colors.black),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 16,
                      )
                    ],
                  )),
                  Text(
                    items[index]["title"]!,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
                      items[index]["amount"] != null
                          ? Utilities.formatIndianNumber(items[index]["amount"])
                          : '0',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
