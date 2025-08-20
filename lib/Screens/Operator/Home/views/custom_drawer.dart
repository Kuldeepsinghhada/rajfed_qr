import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/utils/location_service.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer(
      {required this.userName, required this.callback, super.key});
  final String userName;
  final Function(String) callback;

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int? userType;

  @override
  void initState() {
    getUserType();
    getPackageDetail();
    super.initState();
  }

  String buildNumber = "";

  getPackageDetail() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buildNumber = "Version: ${packageInfo.version}(${packageInfo.buildNumber})";
    setState(() {});
  }

  getUserType() async {
    var type = await SharedPreferenceHelper.instance.getUserType();
    userType = type;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Profile Header
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0] : '',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),
          ),
          // Drawer Items
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              widget.callback("Home"); // Close Drawer
            },
          ),
          Visibility(
            visible: userType == 10,
            child: ListTile(
              leading: Icon(Icons.notes_outlined),
              title: Text("Warehouse Rejected"),
              onTap: () {
                widget.callback("Warehouse Rejected");
              },
            ),
          ),
          Visibility(
            visible: (userType == 2) || (userType == 13),
            child: ListTile(
              leading: Icon(Icons.send_time_extension_outlined),
              title: Text(userType == 13 ? "Accepted" : "Dispatched"),
              onTap: () {
                widget.callback("Dispatched");
              },
            ),
          ),
          Visibility(
            visible: (userType == 2) || (userType == 13),
            child: ListTile(
              leading: Icon(Icons.do_not_disturb_alt_sharp),
              title: Text("Rejected"),
              onTap: () {
                widget.callback("Rejected");
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.lock_reset),
            title: Text("Change Password"),
            onTap: () {
              widget.callback("Change Password");
            },
          ),
          Visibility(
            visible: true,
            child: ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text("Update Location"),
              onTap: () {
                saveLocation();
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              widget.callback("Logout");
            },
          ),
          Spacer(), // Pushes the bottom section down
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              buildNumber,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void saveLocation() async {
    if (!mounted) return;
    showLoadingDialog(context);
    Position? position = await LocationService.instance.getLocation(context);
    if (position == null) {
      if (!mounted) return;
    Navigator.pop(context);
      return;
    }
    try {
      var data = await OPHomeService.instance.operatorSaveLocation(position);
      if (!mounted) return;
    Navigator.pop(context);
      if (data?.status == true) {
        showSuccessToast("Location updated successfully");
      } else {
        showErrorToast(data?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      if (!mounted) return;
    Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }
}
