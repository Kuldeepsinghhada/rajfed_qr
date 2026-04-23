import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/utils/location_service.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class WarehouseCapacityScreen extends StatefulWidget {
  const WarehouseCapacityScreen({super.key});

  @override
  State<WarehouseCapacityScreen> createState() =>
      _WarehouseCapacityScreenState();
}

class _WarehouseCapacityScreenState extends State<WarehouseCapacityScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDistrictValue;
  List<DistrictModel> districtList = [];
  List<String> districtStringList = [];

  String? selectedWarehouse;
  List<WareHouseModel> warehouseList = [];
  List<String> warehouseStringList = [];

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDistricts();
    _getCurrentLocation();
  }

  void _getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getDistrictList();
      if (!mounted) return;
      Navigator.pop(context);

      if (response?.status == true) {
        districtList = response?.data ?? [];
        districtStringList = districtList
            .where((item) => item.districtNameEN != null)
            .map((item) => item.districtNameEN!)
            .toList();
        setState(() {});
      } else {
        showErrorToast(response?.error ?? "Failed to load districts");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void _getWarehouses(String districtCode) async {
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getWareHouseList(
        districtCode,
      );
      if (!mounted) return;
      Navigator.pop(context);

      if (response?.status == true) {
        warehouseList = response?.data ?? [];
        warehouseStringList = warehouseList
            .where((item) => item.wareHouseName != null)
            .map((item) => item.wareHouseName!)
            .toList();
        setState(() {
          selectedWarehouse = null;
        });
      } else {
        showErrorToast(response?.error ?? "Failed to load warehouses");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorToast("Something went wrong");
    }
  }

  void _getCurrentLocation() async {
    Position? position = await LocationService.instance.getLocation(context);
    if (position != null) {
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(5);
        _longController.text = position.longitude.toStringAsFixed(5);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog(context);
      try {
        var warehouse = warehouseList.firstWhere(
          (element) => element.wareHouseName == selectedWarehouse,
        );

        Map<String, dynamic> body = {
          "wareHouseId": warehouse.wareHouseId ?? 0,
          "wareHouseName": warehouse.wareHouseName ?? "",
          "districT_CODE": warehouse.districTCODE ?? "",
          "lat": double.tryParse(_latController.text) ?? 0.0,
          "long": double.tryParse(_longController.text) ?? 0.0,
          "capacity": double.tryParse(_capacityController.text) ?? 0.0,
        };

        final response = await InchargeService.instance.updateWarehouseMaster(
          body,
        );
        if (!mounted) return;
        Navigator.pop(context);

        if (response?.status == true) {
          showSuccessToast("Warehouse details updated successfully");
          Navigator.pop(context);
        } else {
          showErrorToast(
            response?.error ?? "Failed to update warehouse details",
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        showErrorToast("Something went wrong");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Warehouse Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            children: [
              districtDropdown(),
              wareHouseDropdown(),
              locationFields(),
              capacityField(),
              const SizedBox(height: 10),
              CommonButton(text: "Submit", onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget districtDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistrictValue,
      hint: const Text("Select District"),
      items: districtStringList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedDistrictValue = newValue;
          selectedWarehouse = null;
          warehouseStringList = [];
        });
        if (newValue != null) {
          var index = districtStringList.indexOf(newValue);
          _getWarehouses(districtList[index].district ?? '');
        }
      },
      validator: (value) => value == null ? 'Please select district' : null,
      decoration: _inputDecoration("District"),
    );
  }

  Widget wareHouseDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedWarehouse,
      hint: const Text("Select Warehouse"),
      items: warehouseStringList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedWarehouse = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select warehouse' : null,
      decoration: _inputDecoration("Warehouse"),
    );
  }

  Widget locationFields() {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: TextFormField(
            controller: _latController,
            readOnly: true,
            decoration: _inputDecoration("Latitude").copyWith(
              suffixIcon: IconButton(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location, color: Colors.green),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required";
              }
              return null;
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _longController,
            readOnly: true,
            decoration: _inputDecoration("Longitude"),
            style: const TextStyle(fontWeight: FontWeight.w600),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget capacityField() {
    return TextFormField(
      controller: _capacityController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration("Capacity (MT)"),
      style: const TextStyle(fontWeight: FontWeight.w600),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter capacity";
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
