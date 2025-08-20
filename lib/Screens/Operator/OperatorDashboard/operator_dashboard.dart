import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Admin/admin_home_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/HomeScreen.dart';
import 'package:rajfed_qr/Screens/Operator/Profile/profile_screen.dart';
import 'package:rajfed_qr/Screens/Operator/rejected_screen/rejected_screen.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  int selectedIndex = 1;
  var pageController = PageController(initialPage: 1, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          top: false,
          child: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              AdminHomeScreen(),
              MyHomePage(),
              RejectedScreen(),
              ProfileScreen()
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          currentIndex: selectedIndex,
          onTap: (int index) {
            selectedIndex = index;
            setState(() => pageController.jumpToPage(index));
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined), label: 'Data'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_rounded), label: 'Add QR'),
            BottomNavigationBarItem(
                icon: Icon(Icons.blinds_closed_rounded), label: 'Rejected'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ));
  }
}
