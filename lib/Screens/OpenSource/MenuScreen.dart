import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Admin/farmer_detail/farmer_detail_screen.dart';
import 'package:rajfed_qr/Screens/OpenSource/contact_us_screen.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// List of devices
  final List<DeviceItem> items = const [
    DeviceItem(
      title: "Farmer Search",
      subtitle: "",
      icon: Icons.search,
      color: Color(0xFF42A5F5), // Light Blue
    ),
    DeviceItem(
      title: "MSP Rate 2025",
      subtitle: "",
      icon: Icons.price_change_outlined,
      color: Color(0xFF66BB6A), // Light Green
    ),
    DeviceItem(
      title: "Help",
      subtitle: "Warm light",
      icon: Icons.help_outline,
      color: Color(0xFFAB47BC), // Light Purple
    ),
    DeviceItem(
      title: "Login",
      subtitle: "Warm light",
      icon: Icons.login,
      color: Color(0xFFFFA726), // Light Orange
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('images/banner.jpg'),
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
                        } else if (index == 2) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactUsScreen()));
                        } else if (index == 3) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
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
    );
  }
}

/// DeviceItem Model
class DeviceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DeviceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
