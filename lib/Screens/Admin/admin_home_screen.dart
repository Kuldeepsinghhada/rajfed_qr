import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_detail_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/all_warehouse_data_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/contact_us_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/crop_calculate/crop_calculater_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen/farmer_desk_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/msp_rate_screen.dart';
import 'package:rajfed_qr/Screens/Operator/DataScreen/data_screen.dart';
import 'package:rajfed_qr/Screens/Operator/DataScreen/data_services.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/dashboard_data_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  DashboardDataModel? dataModel;

  List<GridModel> items = [];
  int? userType;
  @override
  void initState() {
    getUserType();
    getDashboardAPICall();
    super.initState();
  }

  void getUserType() async {
    userType = await SharedPreferenceHelper.instance.getUserType();
    setState(() {});
  }

  void getDashboardAPICall() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      int? cropId;

      var response = await DataService.instance.dashboardDataList(
        null,
        null,
        cropId: cropId,
      );
      if (!mounted) return;
      if (!mounted) return;
      Navigator.pop(context);
      if (response.status == true) {
        dataModel = response.data;
        addSectionList();
      } else {
        showErrorToast(response.error);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void addSectionList() {
    items = [
      GridModel(
        title: "Total Registration",
        image: Icons.how_to_reg,
        color: Color(0xFFE1F5FE),
        value: double.parse(
          "${dataModel?.totalRegisteredFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Date Allocated",
        image: Icons.event,
        color: Color(0xFFF3E5F5),
        value: double.parse(
          "${dataModel?.totalDateAllotedFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Total Purchase",
        image: Icons.shopping_cart_outlined,
        color: Color(0xFFE8F5E9),
        value: double.parse(
          "${dataModel?.purchaseTransactionsFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Total Payment",
        image: Icons.payment,
        color: Color(0xFFFFFDE7),
        value: double.parse(
          "${dataModel?.paymentDoneFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Warehouse Receipt",
        image: Icons.receipt_outlined,
        color: Color(0xFFFFF3E0),
        value: ("${dataModel?.wrdatAMT ?? 0} (MT)").toString(),
      ),
      GridModel(
        title: "Used Bardana",
        image: Icons.shopping_bag_outlined,
        color: Color(0xFFFFEBEE),
        value: double.parse(
          "${dataModel?.purchaseBardana ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "QR Generated",
        image: Icons.qr_code_scanner,
        color: Color(0xFFEDE7F6),
        value: double.parse(
          "${dataModel?.qRGeneratedFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Total Dispatched",
        image: Icons.local_shipping_outlined,
        color: Color(0xFFE0F2F1),
        value: double.parse(
          "${dataModel?.dispatchedFarmers ?? 0}",
        ).toInt().toString(),
      ),
      GridModel(
        title: "Search",
        image: Icons.search,
        color: Color(0xFFF1F8E9),
        value: '',
      ),
      GridModel(
        title: "MSP Rate",
        image: Icons.price_change_outlined,
        color: Color(0xFFFFF3E0),
        value: '',
      ),
      GridModel(
        title: "Crop Calculater",
        image: Icons.calculate,
        color: Color(0xFFFFFDE7),
        value: '',
      ),
      if (userType == 13 || userType == 7)
        GridModel(
          title: "All Warehouse Data",
          image: Icons.list_alt_rounded,
          color: Color(0xFFF3E5F5),
          value: '',
        ),
      GridModel(
        title: "Help",
        image: Icons.help_outline,
        color: Color(0xFFF1F8E9),
        value: '',
      ),
    ];
    setState(() {});
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 60), // Warning icon
              SizedBox(width: 10),
            ],
          ),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                logoutAPICall();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void logoutAPICall() async {
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var data = await ApiService.instance.apiCall(
        APIEndPoint.logout,
        HttpRequestType.get,
        null,
      );
      if (!mounted) return;
      Navigator.pop(context);
      if (data.status == true) {
        SharedPreferenceHelper.instance.clearData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FarmerDeskScreen()),
        );
      } else {
        showErrorToast(data.error);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : 4;
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              showLogoutDialog(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getDashboardAPICall();
        },
        child: GridView.builder(
          padding: EdgeInsets.all(12),
          itemCount: items.length,
          // shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5,
          ),
          //scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: item.color,
              child: InkWell(
                onTap: () {
                  if (item.title == "Total Registration") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DataScreen()),
                    );
                  } else if (item.title == "Search") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmerDetailScreen(),
                      ),
                    );
                  } else if (item.title == "MSP Rate") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MspRateScreen()),
                    );
                  } else if (item.title == "Crop Calculater") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropCalculaterScreen(),
                      ),
                    );
                  } else if (item.title == "All Warehouse Data") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllWareHouseDataScreen(),
                      ),
                    );
                  } else if (item.title == "Help") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactUsScreen(),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              items[index].image,
                              size: 30,
                              color: Colors.black,
                            ),
                            Text(
                              items[index].title,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  items[index].value,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                                (items[index].title == "Total Registration" ||
                                        items[index].title == "Search" ||
                                        items[index].title == "MSP Rate" ||
                                        items[index].title ==
                                            "Crop Calculater" ||
                                        items[index].title == "Help")
                                    ? Icon(Icons.arrow_forward_ios, size: 17)
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showModernBardanaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "QR Code",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              infoCard("Total", "100", Colors.blueAccent),
              infoCard("Remaining", "80", Colors.green),
              infoCard("Used", "20", Colors.redAccent),
            ],
          ),
        );
      },
    );
  }
}

Widget infoCard(String title, String value, Color color) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.black87)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class GridModel {
  final String title;
  final IconData image;
  final Color color;
  final String value;
  GridModel({
    required this.title,
    required this.image,
    required this.color,
    required this.value,
  });
}
