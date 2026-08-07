import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/OpenSource/farmer_desk_screen/farmer_desk_screen.dart';
import 'package:rajfed_qr/Screens/Packs/packs_list_screen.dart';
import 'package:rajfed_qr/Screens/Warehouse/all_warehouse_data_screen.dart';
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
  final GlobalKey<PacksListScreenState> _packsListKey = GlobalKey();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AllWareHouseDataScreen(key: _allWarehouseKey, showAppBar: false),
      PacksListScreen(key: _packsListKey, showAppBar: false),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _allWarehouseKey.currentState?.fetchData();
    } else if (index == 1) {
      _packsListKey.currentState?.fetchData();
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
      showErrorToast("कुछ गलत हो गया");
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
          content: const Text("क्या आप निश्चित रूप से लॉगआउट करना चाहते हैं?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("रद्द करें", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                logoutAPICall();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("लॉगआउट", style: TextStyle(color: Colors.white)),
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
        title: Text(_selectedIndex == 0 ? "वेयरहाउस डेटा" : "पैक्स सूची"),
        actions: [
          IconButton(
            onPressed: () => showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            tooltip: "लॉगआउट",
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
            icon: Icon(Icons.store),
            label: 'वेयरहाउस',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'पैक्स',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade800,
        onTap: _onItemTapped,
      ),
    );
  }
}
