import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/models/block_model.dart';
import 'package:rajfed_qr/utils/location_service.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class WarehouseCapacityScreen extends StatefulWidget {
  final bool showAppBar;
  const WarehouseCapacityScreen({super.key, this.showAppBar = true});

  @override
  State<WarehouseCapacityScreen> createState() =>
      _WarehouseCapacityScreenState();
}

class _WarehouseCapacityScreenState extends State<WarehouseCapacityScreen> {
  final _formKey = GlobalKey<FormState>();

  int? userType;
  int? assignedWarehouseId;
  String? loginDistrictCode;
  bool isDistrictFixed = false;

  String? selectedDistrictValue;
  List<DistrictModel> districtList = [];
  List<String> districtStringList = [];

  String? selectedAgencyValue;
  final List<String> agencyList = ["RAJFED", "COOPERATIVE"];

  String? selectedWarehouse;
  List<WareHouseModel> warehouseList = [];
  List<String> warehouseStringList = [];
  // parallel list to track warehouse ids for each displayed name
  List<int?> warehouseIdList = [];

  // Block related
  List<BlockModel> blockList = [];
  List<String> blockStringList = [];
  String? selectedBlockValue;
  int? selectedBlockId;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _extraGodamController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  String? selectedConstructionYear;
  final List<String> yearList = [];

  String? selectedWarehouseCondition;
  final List<String> conditionList = ["Usable", "Unusable"];

  @override
  void initState() {
    super.initState();
    _initYearList();
    _initUserAndData();
    _getCurrentLocation();
  }

  void _initYearList() {
    int currentYear = DateTime.now().year;
    for (int i = currentYear; i >= 1950; i--) {
      yearList.add(i.toString());
    }
  }

  Future<void> _initUserAndData() async {
    userType = await SharedPreferenceHelper.instance.getUserType();
    assignedWarehouseId = await SharedPreferenceHelper.instance
        .getPurchaseCenterId();
    loginDistrictCode = await SharedPreferenceHelper.instance.getDistrictCode();
    _getDistricts();
  }

  void _getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getDistrictList();
      if (!mounted) return;
      // Safely dismiss loading dialog if still present
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response?.status == true) {
        districtList = response?.data ?? [];
        districtStringList = districtList
            .where((item) => item.districtNameEN != null)
            .map((item) => item.districtNameEN!)
            .toList();

        if (loginDistrictCode != null) {
          try {
            final district = districtList.firstWhere(
              (d) =>
                  d.district?.toString().trim() ==
                  loginDistrictCode?.toString().trim(),
            );
            selectedDistrictValue = district.districtNameEN;
            isDistrictFixed = true;
          } catch (e) {}
        }

        // If warehouse user, auto-fetch their specific data
        if (userType == 13 && assignedWarehouseId != null) {
          _fetchExistingDetails();
        } else {
          if (!mounted) return;
          setState(() {});
        }
      } else {
        showErrorToast(response?.error ?? "Failed to load districts");
      }
    } catch (e) {
      if (!mounted) return;
      // Safely dismiss loading dialog and show error if still mounted
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("Something went wrong");
    }
  }

  void _fetchExistingDetails() async {
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getAllWarehouseData();
      if (!mounted) return;
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response?.status == true) {
        final List<WareHouseModel> allData = response?.data ?? [];

        // Find my warehouse safely
        WareHouseModel? myWarehouse;
        try {
          myWarehouse = allData.firstWhere(
            (w) => w.wareHouseId == assignedWarehouseId,
          );
        } catch (e) {
          myWarehouse = null;
        }

        if (myWarehouse != null) {
          isAlreadyUpdated = myWarehouse.status?.toLowerCase() == "updated";
          if (!mounted) return;
          setState(() {
            // Find and set district
            try {
              final district = districtList.firstWhere(
                (d) => d.district == myWarehouse?.districTCODE,
              );
              selectedDistrictValue = district.districtNameEN;
            } catch (e) {
              selectedDistrictValue = null;
            }

            // Set warehouse list and selection
            warehouseList = [myWarehouse!];
            warehouseStringList = [myWarehouse.wareHouseName ?? "Unknown"];
            warehouseIdList = [myWarehouse.wareHouseId];
            selectedWarehouse = myWarehouse.wareHouseName;

            // Pre-fill existing values
            if (myWarehouse.lat != null) {
              _latController.text = myWarehouse.lat!.toStringAsFixed(5);
            }
            if (myWarehouse.long != null) {
              _longController.text = myWarehouse.long!.toStringAsFixed(5);
            }
            if (myWarehouse.capacity != null) {
              _capacityController.text = myWarehouse.capacity!
                  .toInt()
                  .toString();
            }
            if (myWarehouse.extraGodam != null) {
              _extraGodamController.text = myWarehouse.extraGodam!.toString();
            }
            selectedConstructionYear = myWarehouse.constructionYear;
            _ownerNameController.text = myWarehouse.ownerName ?? "";
            if (myWarehouse.warehouseCondtion != null &&
                conditionList.contains(myWarehouse.warehouseCondtion)) {
              selectedWarehouseCondition = myWarehouse.warehouseCondtion;
            } else {
              selectedWarehouseCondition = null;
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  void _getWarehouses(String districtCode) async {
    // Keep compatibility: if agency is RAJFED and no block selected, pass 0
    int? blockIdParam = selectedBlockId;
    if (selectedAgencyValue == "RAJFED" && blockIdParam == null) {
      blockIdParam = 0;
    }
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getWareHouseListUser8(
        districtCode,
        agency: selectedAgencyValue,
        blockId: blockIdParam,
      );
      if (!mounted) return;
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response?.status == true) {
        warehouseList = response?.data ?? [];
        // build display list and parallel id list to avoid matching by name
        warehouseStringList = [];
        warehouseIdList = [];
        for (var item in warehouseList) {
          final name = (item.wareHouseName ?? '').trim();
          if (name.isNotEmpty) {
            warehouseStringList.add(name);
            // keep id as-is (may be null) to preserve index alignment
            warehouseIdList.add(item.wareHouseId);
          }
        }
        if (!mounted) return;
        setState(() {
          selectedWarehouse = null;
        });
      } else {
        showErrorToast(response?.error ?? "Failed to load warehouses");
      }
    } catch (e) {
      if (!mounted) return;
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("Something went wrong");
    }
  }

  Future<void> _getBlocks(String districtCode) async {
    // Fetch blocks for selected district and current agency
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getBlockMaster(
        districtCode,
        agency: selectedAgencyValue,
      );
      // safely dismiss loading dialog if widget still mounted
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (response?.status == true) {
        blockList = response?.data ?? [];
        blockStringList = blockList
            .where((b) => b.blocKENG != null)
            .map((b) => b.blocKENG!)
            .toList();
        if (!mounted) return;
        setState(() {
          selectedBlockValue = null;
          selectedBlockId = null;
          // Clear warehouses until block is selected
          warehouseList = [];
          warehouseStringList = [];
        });
      } else {
        showErrorToast(response?.error ?? "Failed to load blocks");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("Something went wrong");
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
        // Prefer selecting warehouse by matching the selected name to our list
        WareHouseModel? warehouse;
        if (selectedWarehouse != null) {
          try {
            warehouse = warehouseList.firstWhere(
              (w) =>
                  (w.wareHouseName ?? '').trim() == selectedWarehouse!.trim(),
            );
          } catch (e) {
            warehouse = null;
          }
        }
        if (warehouse == null || warehouse.wareHouseId == null) {
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
          showErrorToast('Please select a valid warehouse');
          return;
        }

        var disCode = "";
        if (selectedDistrictValue != null) {
          final district = districtList.firstWhere(
            (d) => d.districtNameEN == selectedDistrictValue,
          );
          disCode = district.district ?? "";
        }

        Map<String, dynamic> body = {
          "wareHouseId": warehouse.wareHouseId,
          "wareHouseName": warehouse.wareHouseName ?? "",
          "districT_CODE": disCode,
          "lat": "${double.tryParse(_latController.text) ?? 0.0}",
          "long": "${double.tryParse(_longController.text) ?? 0.0}",
          "capacity": double.tryParse(_capacityController.text) ?? 0.0,
          "ExtraGodam": int.tryParse(_extraGodamController.text) ?? 0,
          "constructionYear": selectedConstructionYear,
          "ownerName": _ownerNameController.text.trim(),
          "construction_year": selectedConstructionYear,
          "owner_name": _ownerNameController.text.trim(),
          "warehouseCondtion": selectedWarehouseCondition,
        };

        final response = await InchargeService.instance.updateWarehouseMaster(
          body,
        );
        if (!mounted) return;
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);

        if (response?.status == true) {
          showSuccessToast("Warehouse details updated successfully");
          // Navigator.pop(context);
        } else {
          showErrorToast(
            response?.error ?? "Failed to update warehouse details",
          );
        }
      } catch (e) {
        if (!mounted) return;
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        if (mounted) showErrorToast("Something went wrong");
      }
    }
  }

  bool isAlreadyUpdated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text("Warehouse Details"))
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            children: [
              districtDropdown(),
              agencyDropdown(),
              blockDropdown(),
              wareHouseDropdown(),
              locationFields(),
              capacityField(),
              extraGodamField(),
              ownerNameField(),
              constructionYearDropdown(),
              warehouseConditionDropdown(),
              if (isAlreadyUpdated)
                const Text(
                  "Information already updated.",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 10),
              if (!isAlreadyUpdated)
                CommonButton(text: "Submit", onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget districtDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedDistrictValue,
      hint: const Text("Select District"),
      items: districtStringList
          .map(
            (String value) => DropdownMenuItem(
              value: value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      isDense: true,
      onChanged: (userType == 13 || isDistrictFixed)
          ? null
          : (newValue) {
              setState(() {
                selectedDistrictValue = newValue;
                selectedWarehouse = null;
                warehouseStringList = [];
                // clear blocks when district changes
                blockList = [];
                blockStringList = [];
                selectedBlockValue = null;
                selectedBlockId = null;
              });
              // If agency already selected, fetch blocks for new district
              if (selectedAgencyValue != null && newValue != null) {
                var index = districtStringList.indexOf(newValue);
                _getBlocks(districtList[index].district ?? '');
              }
            },
      validator: (value) => value == null ? 'Please select district' : null,
      decoration: _inputDecoration(
        "District",
      ).copyWith(enabled: !(userType == 13 || isDistrictFixed)),
    );
  }

  Widget agencyDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedAgencyValue,
      hint: const Text("Select Agency"),
      items: agencyList
          .map(
            (String value) => DropdownMenuItem(
              value: value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      isDense: true,
      onChanged: (userType == 13)
          ? null
          : (newValue) async {
              setState(() {
                selectedAgencyValue = newValue;
                selectedWarehouse = null;
                warehouseStringList = [];
                // clear blocks when agency changes
                blockList = [];
                blockStringList = [];
                selectedBlockValue = null;
                selectedBlockId = null;
              });
              if (selectedDistrictValue != null && newValue != null) {
                var index = districtStringList.indexOf(selectedDistrictValue!);
                final districtCode = districtList[index].district ?? '';
                await _getBlocks(districtCode);
                // If RAJFED, backend expects BLOCK_ID=0 to fetch warehouses
                if (newValue == "RAJFED") {
                  _getWarehouses(districtCode);
                }
              }
            },
      validator: (value) {
        if (userType == 13) return null;
        return value == null ? 'Please select agency' : null;
      },
      decoration: _inputDecoration("Agency").copyWith(enabled: userType != 13),
    );
  }

  Widget blockDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedBlockValue,
      hint: const Text("Select Block"),
      items: blockStringList
          .map(
            (String value) => DropdownMenuItem(
              value: value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      isDense: true,
      onChanged: (userType == 13)
          ? null
          : (newValue) {
              setState(() {
                selectedBlockValue = newValue;
                selectedWarehouse = null;
                warehouseStringList = [];
                // map selected block name to id
                try {
                  final idx = blockStringList.indexOf(newValue!);
                  selectedBlockId = blockList[idx].blocKID;
                } catch (e) {
                  selectedBlockId = null;
                }
              });
              // fetch warehouses for selected block
              if (selectedDistrictValue != null && newValue != null) {
                var index = districtStringList.indexOf(selectedDistrictValue!);
                _getWarehouses(districtList[index].district ?? '');
              }
            },
      validator: (value) {
        return null;
      },
      decoration: _inputDecoration("Block"),
    );
  }

  Widget wareHouseDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      itemHeight: null,
      initialValue: selectedWarehouse,
      hint: const Text("Select Warehouse/GSS"),
      items: warehouseStringList
          .map(
            (String value) => DropdownMenuItem(
              value: value,
              child: Row(children: [Expanded(child: Text(value))]),
            ),
          )
          .toList(),
      isDense: false,
      onChanged: (userType == 13)
          ? null
          : (newValue) {
              if (newValue == null) return;
              // Determine index of selection to map to ID safely
              final idx = warehouseStringList.indexOf(newValue);
              int? selectedId;
              WareHouseModel? warehouseObj;
              if (idx != -1) {
                // if warehouseIdList shorter than names, fallback to searching in warehouseList
                if (idx < warehouseIdList.length) {
                  selectedId = warehouseIdList[idx];
                }
                // try to find object by id first
                if (selectedId != null) {
                  try {
                    warehouseObj = warehouseList.firstWhere(
                      (w) => w.wareHouseId == selectedId,
                    );
                  } catch (e) {
                    warehouseObj = null;
                  }
                }
              }
              // fallback: try to find by name in warehouseList
              if (warehouseObj == null) {
                try {
                  warehouseObj = warehouseList.firstWhere(
                    (w) => (w.wareHouseName ?? '').trim() == newValue.trim(),
                  );
                  selectedId = warehouseObj.wareHouseId;
                } catch (e) {
                  warehouseObj = null;
                }
              }

              setState(() {
                selectedWarehouse = newValue;
                if (warehouseObj != null) {
                  isAlreadyUpdated =
                      warehouseObj.status?.toLowerCase() == "updated";
                  if (warehouseObj.lat != null) {
                    _latController.text = warehouseObj.lat!.toStringAsFixed(5);
                  }
                  if (warehouseObj.long != null) {
                    _longController.text = warehouseObj.long!.toStringAsFixed(
                      5,
                    );
                  }
                  if (warehouseObj.capacity != null) {
                    _capacityController.text = warehouseObj.capacity!
                        .toInt()
                        .toString();
                  }
                  if (warehouseObj.extraGodam != null) {
                    _extraGodamController.text = warehouseObj.extraGodam!
                        .toString();
                  } else {
                    _extraGodamController.clear();
                  }
                  selectedConstructionYear = warehouseObj.constructionYear;
                  _ownerNameController.text = warehouseObj.ownerName ?? "";
                  if (warehouseObj.warehouseCondtion != null &&
                      conditionList.contains(warehouseObj.warehouseCondtion)) {
                    selectedWarehouseCondition = warehouseObj.warehouseCondtion;
                  } else {
                    selectedWarehouseCondition = null;
                  }
                } else {
                  // Reset fields if not found
                  _capacityController.clear();
                  _extraGodamController.clear();
                  selectedConstructionYear = null;
                  _ownerNameController.clear();
                  selectedWarehouseCondition = null;
                  isAlreadyUpdated = false;
                }
              });
            },
      validator: (value) => value == null ? 'Please select warehouse' : null,
      decoration: _inputDecoration(
        "Warehouse/GSS",
      ).copyWith(enabled: userType != 13),
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
                onPressed: isAlreadyUpdated ? null : _getCurrentLocation,
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
      readOnly: isAlreadyUpdated,
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

  Widget extraGodamField() {
    return TextFormField(
      controller: _extraGodamController,
      keyboardType: TextInputType.number,
      readOnly: isAlreadyUpdated,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration("Other Godown (अतिरिक्त गोदाम संख्या)"),
      style: const TextStyle(fontWeight: FontWeight.w600),
      validator: (value) {
        return null;
      },
    );
  }

  Widget ownerNameField() {
    return TextFormField(
      controller: _ownerNameController,
      keyboardType: TextInputType.name,
      readOnly: isAlreadyUpdated,
      decoration: _inputDecoration("Owner Name"),
      style: const TextStyle(fontWeight: FontWeight.w600),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter owner name";
        }
        return null;
      },
    );
  }

  Widget warehouseConditionDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedWarehouseCondition,
      hint: const Text("Select Warehouse Condition"),
      items: conditionList
          .map(
            (String value) =>
                DropdownMenuItem(value: value, child: Text(value)),
          )
          .toList(),
      isDense: true,
      onChanged: isAlreadyUpdated
          ? null
          : (newValue) {
              setState(() {
                selectedWarehouseCondition = newValue;
              });
            },
      validator: (value) =>
          value == null ? 'Please select warehouse condition' : null,
      decoration: _inputDecoration(
        "Warehouse Condition",
      ).copyWith(enabled: !isAlreadyUpdated),
    );
  }

  Widget constructionYearDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedConstructionYear,
      hint: const Text("Select Construction Year"),
      items: yearList
          .map(
            (String value) => DropdownMenuItem(
              value: value,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      isDense: true,
      onChanged: isAlreadyUpdated
          ? null
          : (newValue) {
              setState(() {
                selectedConstructionYear = newValue;
              });
            },
      validator: (value) =>
          value == null ? 'Please select construction year' : null,
      decoration: _inputDecoration(
        "Construction Year",
      ).copyWith(enabled: !isAlreadyUpdated),
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
