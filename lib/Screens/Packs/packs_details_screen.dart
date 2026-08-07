import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/Screens/Incharge/incharge_home/incharge_service.dart';
import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/common_views/loader_dialog.dart';
import 'package:rajfed_qr/models/block_model.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/packs_model.dart';
import 'package:rajfed_qr/utils/location_service.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class PacksDetailsScreen extends StatefulWidget {
  final bool showAppBar;
  final PacksModel? packsModel;
  const PacksDetailsScreen({
    super.key,
    this.showAppBar = true,
    this.packsModel,
  });

  @override
  State<PacksDetailsScreen> createState() => _PacksDetailsScreenState();
}

class _PacksDetailsScreenState extends State<PacksDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  int? userType;
  String? loginDistrictCode;
  bool isDistrictFixed = false;

  // District state
  String? selectedDistrictValue;
  List<DistrictModel> districtList = [];
  List<String> districtStringList = [];

  // Block state
  List<BlockModel> blockList = [];
  List<String> blockStringList = [];
  String? selectedBlockValue;
  int? selectedBlockId;

  // Packs state (Fetched from GetPacsStatus API)
  List<PacksModel> packsRawList = [];
  List<String> packsStringList = [];
  List<int?> packsIdList = [];
  String? selectedPacksName;
  int? selectedPacksId;

  // Controllers for TextFields
  final TextEditingController _adhyaxNameController = TextEditingController();
  final TextEditingController _vyavasthapakNameController =
      TextEditingController();
  final TextEditingController _vyavasthapakMobileController =
      TextEditingController();
  final TextEditingController _sahVyavasthapakNameController =
      TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  // Radio button for Vyavasthapak charge type
  String _vyavasthapakChargeType =
      "Regular"; // "Regular" or "Additional Charge"

  // Yes/No toggles
  bool _ePacks = false;
  bool _ksk = false;
  bool _chc = false;
  bool _officeBuilding = false;
  bool _shreeAnna = false;

  @override
  void initState() {
    super.initState();
    _populateExistingData();
    _initUserAndData();
    if (_latController.text.isEmpty && _longController.text.isEmpty) {
      _getCurrentLocation();
    }
  }

  void _populateExistingData() {
    if (widget.packsModel != null) {
      final p = widget.packsModel!;
      selectedPacksId = p.wareHouseId;
      selectedPacksName = p.wareHouseName;
      if (selectedPacksName != null && selectedPacksName!.isNotEmpty) {
        packsStringList = [selectedPacksName!];
        packsIdList = [selectedPacksId];
      }
      _adhyaxNameController.text = p.chairmanName ?? '';
      _vyavasthapakNameController.text = p.inchargeName ?? '';
      _vyavasthapakChargeType = (p.regular == 'N' || p.regular == 'No')
          ? "Additional Charge"
          : "Regular";
      _vyavasthapakMobileController.text = p.mobileNo ?? '';
      _sahVyavasthapakNameController.text = p.coInchargeName ?? '';
      _latController.text = p.lat ?? '';
      _longController.text = p.long ?? '';
      _ePacks = p.ePacs == 'Y';
      _ksk = p.pmksk == 'Y';
      _chc = p.chc == 'Y';
      _officeBuilding = p.officeBuilding == 'Y';
      _shreeAnna = p.sheeAnna == 'Y';
      selectedBlockValue = p.blocKENG;
    }
  }

  @override
  void dispose() {
    _adhyaxNameController.dispose();
    _vyavasthapakNameController.dispose();
    _vyavasthapakMobileController.dispose();
    _sahVyavasthapakNameController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _initUserAndData() async {
    userType = await SharedPreferenceHelper.instance.getUserType();
    loginDistrictCode = await SharedPreferenceHelper.instance.getDistrictCode();
    _getDistricts();
  }

  void _getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getDistrictList();
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
            if (district.district != null) {
              _getBlocks(district.district!);
            }
          } catch (e) {}
        }
        if (mounted) setState(() {});
      } else {
        showErrorToast(response?.error ?? "जिले लोड करने में विफलता");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("कुछ गलत हो गया");
    }
  }

  Future<void> _getBlocks(String districtCode) async {
    showLoadingDialog(context);
    try {
      final response = await InchargeService.instance.getBlockMaster(
        districtCode,
        agency: "COOPERATIVE",
      );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response?.status == true) {
        blockList = response?.data ?? [];
        blockStringList = blockList
            .where((b) => b.blocKENG != null)
            .map((b) => b.blocKENG!)
            .toList();

        if (!mounted) return;
        setState(() {
          if (widget.packsModel != null &&
              widget.packsModel!.blocKENG != null) {
            selectedBlockValue = widget.packsModel!.blocKENG;
            try {
              final bObj = blockList.firstWhere(
                (b) => b.blocKENG == selectedBlockValue,
              );
              selectedBlockId = bObj.blocKID;
            } catch (e) {}
          } else {
            selectedBlockValue = null;
            selectedBlockId = null;
          }
        });

        // Call GetPacsStatus API to populate PacksList dropdown for District Code
        _getPacksList(districtCode, selectedBlockValue);
      } else {
        showErrorToast(response?.error ?? "ब्लॉक लोड करने में विफलता");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("कुछ गलत हो गया");
    }
  }

  Future<void> _getPacksList(String districtCode, String? blockName) async {
    showLoadingDialog(context);
    try {
      // Calls API: GetPacsStatus?flag=all&DistrictCode=$districtCode
      final response = await InchargeService.instance.getAllPacksData(
        districtCode: districtCode,
      );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (response?.status == true) {
        List<PacksModel> fetchedPacks = response?.data ?? [];

        // Filter by block name if block is selected
        if (blockName != null && blockName.isNotEmpty) {
          fetchedPacks = fetchedPacks.where((p) {
            return (p.blocKENG ?? '').toLowerCase().trim() ==
                blockName.toLowerCase().trim();
          }).toList();
        }

        packsRawList = fetchedPacks;
        packsStringList = [];
        packsIdList = [];
        for (var item in packsRawList) {
          final name = (item.wareHouseName ?? '').trim();
          if (name.isNotEmpty) {
            packsStringList.add(name);
            packsIdList.add(item.wareHouseId);
          }
        }

        // If editing existing item, preserve selectedPacksName in the dropdown
        if (selectedPacksName != null && selectedPacksName!.isNotEmpty) {
          if (!packsStringList.contains(selectedPacksName)) {
            packsStringList.insert(0, selectedPacksName!);
            packsIdList.insert(0, selectedPacksId);
          }
        }

        if (!mounted) return;
        setState(() {});
      } else {
        showErrorToast(response?.error ?? "पैक्स सूची लोड करने में विफलता");
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) showErrorToast("कुछ गलत हो गया");
    }
  }

  void _getCurrentLocation() async {
    Position? position = await LocationService.instance.getLocation(context);
    if (position != null && mounted) {
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(5);
        _longController.text = position.longitude.toStringAsFixed(5);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedPacksName == null) {
        showErrorToast("कृपया ड्रॉपडाउन से एक पैक्स चुनें");
        return;
      }
      showLoadingDialog(context);
      try {
        String disCode = "";
        if (selectedDistrictValue != null) {
          try {
            final district = districtList.firstWhere(
              (d) => d.districtNameEN == selectedDistrictValue,
            );
            disCode = district.district ?? "";
          } catch (e) {}
        }

        Map<String, dynamic> body = {
          "wareHouseId": selectedPacksId ?? 0,
          "wareHouseName": selectedPacksName ?? "",
          "districT_CODE": disCode,
          "lat": _latController.text.trim(),
          "long": _longController.text.trim(),
          "capacity": 0,
          "constructionYear": "",
          "ownerName": "",
          "warehouseCondtion": "",
          "extraGodam": 0,
          "blocK_ENG": selectedBlockValue ?? "",
          "chairmanName": _adhyaxNameController.text.trim(),
          "inchargeName": _vyavasthapakNameController.text.trim(),
          "regular": _vyavasthapakChargeType == "Regular" ? "Y" : "N",
          "coInchargeName": _sahVyavasthapakNameController.text.trim(),
          "mobileNo": _vyavasthapakMobileController.text.trim(),
          "ePacs": _ePacks ? "Y" : "N",
          "pmksk": _ksk ? "Y" : "N",
          "chc": _chc ? "Y" : "N",
          "sheeAnna": _shreeAnna ? "Y" : "N",
          "officeBuilding": _officeBuilding ? "Y" : "N",
        };

        final response = await InchargeService.instance.updatePacksMaster(body);
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);

        if (response?.status == true) {
          showSuccessToast("पैक्स विवरण सफलतापूर्वक अद्यतन किया गया");
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          showErrorToast(
            response?.error ?? "पैक्स विवरण अद्यतन करने में विफलता",
          );
        }
      } catch (e) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        if (mounted) showErrorToast("कुछ गलत हो गया");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text("पैक्स विवरण जोड़ें"),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("1. सामान्य जानकारी"),
              const SizedBox(height: 12),
              _districtDropdown(),
              const SizedBox(height: 14),
              _blockDropdown(),
              const SizedBox(height: 14),
              _packsDropdown(),
              const SizedBox(height: 24),

              _buildSectionTitle("2. प्रबंधन विवरण"),
              const SizedBox(height: 12),
              _adhyaxField(),
              const SizedBox(height: 14),
              _vyavasthapakField(),
              const SizedBox(height: 10),
              _chargeTypeRadioSection(),
              const SizedBox(height: 14),
              _vyavasthapakMobileField(),
              const SizedBox(height: 14),
              _sahVyavasthapakField(),
              const SizedBox(height: 24),

              _buildSectionTitle("3. Location (Keep location On)"),
              const SizedBox(height: 12),
              _locationFields(),
              const SizedBox(height: 24),

              _buildSectionTitle("4. सुविधाएं एवं सेवाएं (हाँ/नहीं)"),
              const SizedBox(height: 12),
              _yesNoCard(
                "ई-पैक्स (E-Pacs)",
                _ePacks,
                (val) => setState(() => _ePacks = val),
              ),
              _yesNoCard(
                "के.एस.के. (KSK)",
                _ksk,
                (val) => setState(() => _ksk = val),
              ),
              _yesNoCard(
                "सी.एच.सी. (CHC)",
                _chc,
                (val) => setState(() => _chc = val),
              ),
              _yesNoCard(
                "कार्यालय भवन (Office Building)",
                _officeBuilding,
                (val) => setState(() => _officeBuilding = val),
              ),
              _yesNoCard(
                "श्री अन्न (Shree Anna)",
                _shreeAnna,
                (val) => setState(() => _shreeAnna = val),
              ),
              const SizedBox(height: 30),

              CommonButton(text: "पैक्स विवरण सबमिट करें", onPressed: _submit),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.green.shade800, width: 4),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade900,
        ),
      ),
    );
  }

  Widget _districtDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "जिला चुनें (Select District)",
        hintText: "जिला का चयन करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: selectedDistrictValue,
      isExpanded: true,
      items: districtStringList.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: isDistrictFixed
          ? null
          : (value) {
              setState(() {
                selectedDistrictValue = value;
                selectedBlockValue = null;
                selectedBlockId = null;
                selectedPacksName = null;
                selectedPacksId = null;
                packsStringList = [];
                packsIdList = [];
              });
              if (value != null) {
                try {
                  final district = districtList.firstWhere(
                    (d) => d.districtNameEN == value,
                  );
                  if (district.district != null) {
                    _getBlocks(district.district!);
                  }
                } catch (e) {}
              }
            },
      validator: (value) => value == null ? 'जिला चुनना अनिवार्य है' : null,
    );
  }

  Widget _blockDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "ब्लॉक का नाम (Block Name - COOPERATIVE)",
        hintText: "ब्लॉक का चयन करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: selectedBlockValue,
      isExpanded: true,
      hint: const Text("ब्लॉक चुनें"),
      items: blockStringList.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedBlockValue = value;
          try {
            final bObj = blockList.firstWhere((b) => b.blocKENG == value);
            selectedBlockId = bObj.blocKID;
          } catch (e) {
            selectedBlockId = null;
          }
          selectedPacksName = null;
          selectedPacksId = null;
          packsStringList = [];
          packsIdList = [];
        });
        if (selectedDistrictValue != null) {
          try {
            final district = districtList.firstWhere(
              (d) => d.districtNameEN == selectedDistrictValue,
            );
            if (district.district != null) {
              _getPacksList(district.district!, value);
            }
          } catch (e) {}
        }
      },
      validator: (value) =>
          value == null ? 'ब्लॉक का चयन करना अनिवार्य है' : null,
    );
  }

  Widget _packsDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "पैक्स की सूची (Pacs List)",
        hintText: "पैक्स का चयन करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      value: selectedPacksName,
      isExpanded: true,
      hint: const Text("पैक्स चुनें"),
      items: packsStringList.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedPacksName = value;
          int idx = packsStringList.indexOf(value ?? '');
          if (idx != -1 && idx < packsIdList.length) {
            selectedPacksId = packsIdList[idx];
          }
          if (idx != -1 && idx < packsRawList.length) {
            final packObj = packsRawList[idx];
            if (packObj.chairmanName != null &&
                packObj.chairmanName!.isNotEmpty) {
              _adhyaxNameController.text = packObj.chairmanName!;
            }
            if (packObj.inchargeName != null &&
                packObj.inchargeName!.isNotEmpty) {
              _vyavasthapakNameController.text = packObj.inchargeName!;
            }
            if (packObj.regular != null) {
              _vyavasthapakChargeType = packObj.regular == 'N'
                  ? "Additional Charge"
                  : "Regular";
            }
            if (packObj.mobileNo != null && packObj.mobileNo!.isNotEmpty) {
              _vyavasthapakMobileController.text = packObj.mobileNo!;
            }
            if (packObj.coInchargeName != null &&
                packObj.coInchargeName!.isNotEmpty) {
              _sahVyavasthapakNameController.text = packObj.coInchargeName!;
            }
            if (packObj.lat != null && packObj.lat!.isNotEmpty) {
              _latController.text = packObj.lat!;
            }
            if (packObj.long != null && packObj.long!.isNotEmpty) {
              _longController.text = packObj.long!;
            }
            _ePacks = packObj.ePacs == 'Y';
            _ksk = packObj.pmksk == 'Y';
            _chc = packObj.chc == 'Y';
            _officeBuilding = packObj.officeBuilding == 'Y';
            _shreeAnna = packObj.sheeAnna == 'Y';
          }
        });
      },
      validator: (value) =>
          value == null ? 'पैक्स का चयन करना अनिवार्य है' : null,
    );
  }

  Widget _adhyaxField() {
    return TextFormField(
      controller: _adhyaxNameController,
      decoration: InputDecoration(
        labelText: "अध्यक्ष का नाम (Adhyax Name)",
        hintText: "अध्यक्ष का नाम दर्ज करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "अध्यक्ष का नाम दर्ज करना अनिवार्य है";
        }
        return null;
      },
    );
  }

  Widget _vyavasthapakField() {
    return TextFormField(
      controller: _vyavasthapakNameController,
      decoration: InputDecoration(
        labelText: "व्यवस्थापक का नाम (Vyavasthapak Name)",
        hintText: "व्यवस्थापक का नाम दर्ज करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "व्यवस्थापक का नाम दर्ज करना अनिवार्य है";
        }
        return null;
      },
    );
  }

  Widget _chargeTypeRadioSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "व्यवस्थापक प्रभार प्रकार (Charge Type):",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      "नियमित (Regular)",
                      style: TextStyle(fontSize: 13),
                    ),
                    value: "Regular",
                    groupValue: _vyavasthapakChargeType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _vyavasthapakChargeType = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      "अतिरिक्त प्रभार",
                      style: TextStyle(fontSize: 13),
                    ),
                    value: "Additional Charge",
                    groupValue: _vyavasthapakChargeType,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _vyavasthapakChargeType = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vyavasthapakMobileField() {
    return TextFormField(
      controller: _vyavasthapakMobileController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: "व्यवस्थापक मोबाइल नंबर",
        hintText: "10 अंकों का मोबाइल नंबर दर्ज करें",
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "व्यवस्थापक मोबाइल नंबर अनिवार्य है";
        }
        if (value.trim().length != 10) {
          return "कृपया वैध 10 अंकों का मोबाइल नंबर दर्ज करें";
        }
        return null;
      },
    );
  }

  Widget _sahVyavasthapakField() {
    return TextFormField(
      controller: _sahVyavasthapakNameController,
      decoration: InputDecoration(
        labelText: "सह व्यवस्थापक का नाम (Sah Vyavasthapak)",
        hintText: "सह व्यवस्थापक का नाम दर्ज करें",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _locationFields() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "अक्षांश (Latitude)",
                      hintText: "अक्षांश",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "अनिवार्य" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "देशांतर (Longitude)",
                      hintText: "देशांतर",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "अनिवार्य" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text("Get Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yesNoCard(String label, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Row(
              children: [
                ChoiceChip(
                  label: const Text("हाँ (Yes)"),
                  selected: value == true,
                  selectedColor: Colors.green.shade200,
                  onSelected: (selected) {
                    if (selected) onChanged(true);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("नहीं (No)"),
                  selected: value == false,
                  selectedColor: Colors.red.shade100,
                  onSelected: (selected) {
                    if (selected) onChanged(false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
