import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/ChangePassword/change_password.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/Screens/login/login_screen.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/location_service.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userType;
  String? userName;
  int? purchaseCenterId;
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
    userName = await SharedPreferenceHelper.instance.getUserName() ?? '';
    purchaseCenterId = await SharedPreferenceHelper.instance.getPurchaseCenterId();
    var typeId = await SharedPreferenceHelper.instance.getUserType();
    if(typeId == 10){
      userType = "Operator";
    }else if(typeId == 2){
      userType = "Incharge";
    }else{
      userType = "Warehouse";
    }
    setState(() {});
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 60), // Warning icon
              SizedBox(width: 10)
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
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void saveLocation() async {
    showLoadingDialog(context);
    Position? position = await LocationService.instance.getLocation(context);
    if (position == null) {
      Navigator.pop(context);
      return;
    }
    try {
      var data = await OPHomeService.instance.operatorSaveLocation(position);
      Navigator.pop(context);
      if (data?.status == true) {
        showSuccessToast("Location updated successfully");
      } else {
        showErrorToast(data?.error ?? 'Something Went wrong');
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void logoutAPICall() async {
    showLoadingDialog(context);
    try {
      var data = await ApiService.instance
          .apiCall(APIEndPoint.logout, HttpRequestType.get, null);
      Navigator.pop(context);
      if (data.status == true) {
        SharedPreferenceHelper.instance.clearData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        showErrorToast(data.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  child: Image.asset('images/profile.png'),
                ),
                Text(
                  "Kuldeep Singh" ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                Text((userType ?? '').toUpperCase(),style: TextStyle(color: Colors.teal,fontWeight: FontWeight.w600),),
                Text("Purchase Center ID : ${purchaseCenterId ?? ''}",style: TextStyle(color: Colors.teal,fontWeight: FontWeight.w600),)
              ],
            ),
            SizedBox(height: 20,),
            Divider(
              height: 0,
            ),
            // Drawer Items
            ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text("Change Password"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
              },
              trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Colors.grey,),
            ),
            Divider(
              height: 0,
            ),
            Visibility(
              visible: true,
              child: ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text("Update Location"),
                onTap: () {
                  saveLocation();
                },
                trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Colors.grey,),
              ),
            ),
            Divider(
              height: 0,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                showLogoutDialog(context);
              },
              trailing: Icon(Icons.arrow_forward_ios,size: 16,color: Colors.grey,),
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
      ),
    );
  }
}
