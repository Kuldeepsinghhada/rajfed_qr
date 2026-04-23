import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Incharge/Rejected/rejected_screen.dart';
import 'package:rajfed_qr/Screens/Incharge/dispatched/dispatched_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Profile/profile_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_home.dart';

class WareHouseDashboard extends StatefulWidget {
  const WareHouseDashboard({super.key});

  @override
  State<WareHouseDashboard> createState() => _WareHouseDashboardState();
}

class _WareHouseDashboardState extends State<WareHouseDashboard> {
  int selectedIndex = 0;
  var pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          top: false,
          child: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              WarehouseHome(),
              DiapatchInchargeScreen(),
              RejectedInchargeScreen(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.transit_enterexit), label: 'Accepted'),
            BottomNavigationBarItem(
                icon: Icon(Icons.not_interested), label: 'Rejected'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ));
  }
}
