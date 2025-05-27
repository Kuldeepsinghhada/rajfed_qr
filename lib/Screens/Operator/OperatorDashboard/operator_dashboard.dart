import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Operator/DataScreen/data_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/HomeScreen.dart';
import 'package:rajfed_qr/Screens/Operator/Profile/profile_screen.dart';
import 'package:rajfed_qr/Screens/Operator/rejected_screen/rejected_screen.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              DataScreen(),
              MyHomePage(),
              RejectedScreen(),
              ProfileScreen()
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_rounded), label: 'Add QR'),
            BottomNavigationBarItem(
                icon: Icon(Icons.blinds_closed_rounded), label: 'Rejected'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ));
  }
}
