import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen/farmer_desk_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/all_warehouse_data_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/warehouse_capacity_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class WarehouseManagerScreen extends StatefulWidget {
  const WarehouseManagerScreen({super.key});

  @override
  State<WarehouseManagerScreen> createState() => _WarehouseManagerScreenState();
}

class _WarehouseManagerScreenState extends State<WarehouseManagerScreen> {
  int _selectedIndex = 0;
  final GlobalKey<AllWareHouseDataScreenState> _allWarehouseKey = GlobalKey();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const WarehouseCapacityScreen(showAppBar: false),
      AllWareHouseDataScreen(key: _allWarehouseKey, showAppBar: false),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      _allWarehouseKey.currentState?.fetchData();
    }
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

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 60),
              SizedBox(width: 10),
            ],
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                logoutAPICall();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? "Warehouse Details" : "All Warehouse Data"),
        actions: [
          IconButton(
            onPressed: () => showLogoutDialog(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Add Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'All Data',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
