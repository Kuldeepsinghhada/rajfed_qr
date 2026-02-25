import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_detail_screen.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_search_qr_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/contact_us_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/crop_calculate/crop_calculater_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen/farmer_desk_service.dart';
import 'package:rajfed_qr/Screens/OpenSource/msp_rate_screen.dart';
import 'package:rajfed_qr/Screens/Registration/screens/information_page.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/update_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class FarmerDeskScreen extends StatefulWidget {
  const FarmerDeskScreen({super.key});

  @override
  State<FarmerDeskScreen> createState() => _FarmerDeskScreenState();
}

class _FarmerDeskScreenState extends State<FarmerDeskScreen> {
  /// List of Item
  final List<DeviceItem> items = const [
    DeviceItem(
      title: "Search Farmer",
      icon: Icons.search,
      color: Color(0xFF42A5F5), // Light Blue
    ),
    DeviceItem(
      title: "Search QR",
      icon: Icons.search,
      color: Color(0xFFAB47BC), // Light Blue
    ),
    DeviceItem(
      title: "MSP Rate 2025",
      icon: Icons.price_change_outlined,
      color: Color(0xFF66BB6A), // Light Green
    ),
    DeviceItem(
      title: "Crop Calculator",
      icon: Icons.calculate,
      color: Color(0xFFFFA726), // Orange
    ),
    DeviceItem(
      title: "Help",
      icon: Icons.help_outline,
      color: Color(0xFF5C6BC0), // Purple
    ),
    DeviceItem(
      title: "Login",
      icon: Icons.login,
      color: Color(0xFF26A69A), // Teal
    ),
    DeviceItem(
      title: "Registration",
      icon: Icons.how_to_reg,
      color: Color(0xFF26A69A), // Teal
    ),
  ];

  List<UpdateModel> newsList = [];
  @override
  void initState() {
    getNewsAPICall();
    super.initState();
  }

  void getNewsAPICall() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await FarmerDeskService.instance.getLatestNews();
      if (!mounted) return;
      Navigator.pop(context);
      if (response.status) {
        newsList = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('images/banner.jpg'),
            newsList.isNotEmpty
                ? Container(
                    height: 50,
                    color: Colors.green,
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Center(
                      child: Marquee(
                        text: newsList
                            .map((item) => "${item.listName} : ${item.message}")
                            .join(", "),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 100.0,
                        // pauseAfterRound: Duration(seconds: 1),
                        //startPadding: 10.0,
                        // accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        //decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  )
                : SizedBox(),
            // Grid
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.5),
                //scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Card(
                    color: items[index].color,
                    child: InkWell(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FarmerDetailScreen()));
                        } else if (index == 1) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FarmerSearchByQR()));
                        } else if (index == 2) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MspRateScreen()));
                        } else if (index == 3) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CropCalculaterScreen()));
                        } else if (index == 4) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactUsScreen()));
                        } else if (index == 5) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        } else if (index == 6) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InformationPage()));
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(items[index].icon,
                                    size: 36, color: Colors.white),
                                SizedBox(height: 12),
                                Text(
                                  items[index].title,
                                  //textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   height: 100,
      //   //color: Colors.green,
      //   child: Marquee(
      //     text: 'Some sample text that takes some space.',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //     scrollAxis: Axis.horizontal,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     blankSpace: 20.0,
      //     velocity: 100.0,
      //    // pauseAfterRound: Duration(seconds: 1),
      //     startPadding: 10.0,
      //     // accelerationDuration: Duration(seconds: 1),
      //     accelerationCurve: Curves.linear,
      //     //decelerationDuration: Duration(milliseconds: 500),
      //     decelerationCurve: Curves.easeOut,
      //   ),
      // ),
    );
  }
}

/// DeviceItem Model
class DeviceItem {
  final String title;
  final IconData icon;
  final Color color;

  const DeviceItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}
