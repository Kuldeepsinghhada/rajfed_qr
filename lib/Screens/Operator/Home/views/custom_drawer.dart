import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';

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
}
