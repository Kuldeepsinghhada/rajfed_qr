import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/Screens/Admin/admin_home_screen.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/crop_list_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class BardanaScreen extends StatefulWidget {
  const BardanaScreen({super.key});

  @override
  State<BardanaScreen> createState() => _BardanaScreenState();
}

class _BardanaScreenState extends State<BardanaScreen> {
  String? selectedCrop;
  List<String> cropItems = [];
  List<CropModel> cropList = [];

  @override
  void initState() {
    getCropList();
    super.initState();
  }

  getCropList() {
    cropItems = DataManager.instance.cropStringList;
    if (cropItems.isEmpty) {
      getCropAPICall();
    }
  }

  void getCropAPICall() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      var response = await OPHomeService.instance.getCropList();
      if (!mounted) return;
      Navigator.pop(context);
      if (response.status == true) {
        cropList = response.data;
        cropList.removeWhere((obj) => obj.cropID == 0);
        for (var item in cropList) {
          if (item.cropDescEN != null) {
            cropItems.add(item.cropDescEN!);
          }
        }
        DataManager.instance.cropList = cropList;
        DataManager.instance.cropStringList = cropItems;
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
      appBar: AppBar(
        title: Text('Bardana'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.1),
        //       blurRadius: 10,
        //       offset: Offset(0, -2),
        //     ),
        //   ],
        //),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Select Crop',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ),
              items: cropItems.map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCrop = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            infoCard("Total", "100", Colors.blueAccent),
            infoCard("Remaining", "80", Colors.green),
            infoCard("Used", "20", Colors.redAccent),
          ],
        ),
      ),
    );
  }
}
