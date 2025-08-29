import 'package:flutter/material.dart';
import 'package:rajfed_qr/APIService/data_manager.dart';
import 'package:rajfed_qr/Screens/Operator/Home/op_home_service.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/crop_list_model.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class MspRateScreen extends StatefulWidget {
  const MspRateScreen({super.key});

  @override
  State<MspRateScreen> createState() => _MspRateScreenState();
}

class _MspRateScreenState extends State<MspRateScreen> {
  List<CropModel> cropList = [];
  List<String> cropItems = [];
  @override
  void initState() {
    getCropAPICall();
    super.initState();
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
        title: Text('MSP Rate'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cropList.length,
        itemBuilder: (context, index) {
          final crop = cropList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                crop.cropDescEN ?? 'Unknown Crop',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "MSP Rate: ₹${crop.rM_Rate}",
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  Text("Government Target: ${crop.target} MT",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                ],
              ),
              leading: const Icon(
                Icons.agriculture_outlined,
                color: Colors.green,
                size: 36,
              ),
            ),
          );
        },
      ),
    );
  }
}
