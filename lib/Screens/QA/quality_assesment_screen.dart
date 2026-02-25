import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'dart:io';
import 'dart:convert';

import 'package:rajfed_qr/common_views/common_button.dart';
import 'package:rajfed_qr/Screens/QA/qa_service.dart';
import 'package:rajfed_qr/models/machine_model.dart';

class QualityAssessmentReport extends StatefulWidget {
  final String registrationNumber;
  final String farmerName;
  final String mobileNo;
  final String purchaseCenterID;
  final String cropID;

  const QualityAssessmentReport({
    super.key,
    required this.registrationNumber,
    required this.farmerName,
    required this.mobileNo,
    required this.purchaseCenterID,
    required this.cropID,
  });

  @override
  State<QualityAssessmentReport> createState() =>
      _QualityAssessmentReportState();
}

class _QualityAssessmentReportState extends State<QualityAssessmentReport> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _foreignMatterController =
      TextEditingController();
  final TextEditingController _analystNameController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();


  String? selectedMachine;
  String? qualityType;

  List<MachineModel> machineDataList = [];
  List<String> machineList = [];

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    var response = await QaService.instance.getMachineDetails();
    if (response != null && response.status) {
      if (mounted) {
        setState(() {
          machineList.clear();
          machineDataList.clear();

          if (response.data != null && response.data is List<MachineModel>) {
            machineDataList = response.data as List<MachineModel>;
            for (var machine in machineDataList) {
              if (machine.machineName != null) {
                machineList.add(machine.machineName!);
              }
            }
          }
        });
      }
    }
  }
  XFile? _pickedImage;

  @override
  void dispose() {
    _foreignMatterController.dispose();
    _analystNameController.dispose();
    _moistureController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  /// Allow only numbers + single dot
  final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*'),
  );

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (qualityType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select FAQ or NON-FAQ")),
        );
        return;
      }
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please attach an image")),
        );
        return;
      }
      if (selectedMachine == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a machine")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String imageBase64 = base64Encode(File(_pickedImage!.path).readAsBytesSync());
        int year = DateTime.now().year;

        var purchaseCenterId = await SharedPreferenceHelper.instance.getPurchaseCenterId();

        var response = await QaService.instance.uploadFarmerRemark(
          registrationNumber: widget.registrationNumber,
          farmerName: widget.farmerName,
          mobileNo: widget.mobileNo,
          purchaseCenterID: purchaseCenterId.toString(),
          cropID: widget.cropID,
          fy: year,
          foreignMatter: _foreignMatterController.text,
          type: qualityType!,
          qualityAnalystName: _analystNameController.text,
          fileSource: "Mobile",
          imageBase64: imageBase64,
          machineName: selectedMachine!, moisture: _moistureController.text,
          remark: _remarkController.text,
        );

        Navigator.pop(context); // close loader

        if (response != null && response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Form Submitted Successfully")),
          );
          Navigator.pop(context); // go back
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?.error ?? "Something went wrong")),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  String? _validatePercentage(
      String? value, double maxLimit, String fieldName) {
    if (value == null || value.isEmpty) {
      return "Enter $fieldName";
    }

    final number = double.tryParse(value);
    if (number == null) {
      return "Invalid number";
    }

    if (number > maxLimit) {
      return "Max allowed is $maxLimit%";
    }

    if (number < 0) {
      return "Cannot be negative";
    }

    return null;
  }

  InputDecoration modernDecoration(String label,
      {bool labelInside = true, String? hintText}) {
    return InputDecoration(
      // If caller wants label above, we avoid labelText here and use hint instead
      labelText: labelInside ? label : null,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      // Default border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
    );
  }

  Widget labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file != null) {
        setState(() {
          _pickedImage = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quality Assessment Report"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// Machine Section - label above
              labeled(
                'Select Machine Name',
                DropdownButtonFormField<String>(
                  initialValue: selectedMachine,
                  decoration: modernDecoration('Select Machine Name',
                      labelInside: false),
                  isExpanded: true,
                  hint: Text("Select Machine"),
                  validator: (value) => value == null ? "Select machine" : null,
                  items: machineList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedMachine = val;
                    });
                  },
                ),
              ),

              SizedBox(
                height: 12,
              ),

              /// Quality Parameters
              Column(
                children: [
                  labeled(
                    'Foreign Matter (Max 4%)',
                    TextFormField(
                      controller: _foreignMatterController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_decimalFormatter],
                      decoration: modernDecoration('',
                          labelInside: false, hintText: "Enter percentage"),
                      validator: (value) =>
                          _validatePercentage(value, 4, "Foreign Matter"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              labeled(
                "Moisture (Upto 8%)",
                TextFormField(
                  controller: _moistureController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalFormatter],
                  decoration: modernDecoration('',
                      labelInside: false, hintText: "Enter percentage").copyWith(suffixText: '%'),
                  validator: (value) =>
                      _validatePercentage(value, 8, "Enter value for Moisture"),
                ),
              ),
              const SizedBox(height: 16),
              /// FAQ / NON-FAQ Modern Toggle (keep label above)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: labeled(
                  'Type',
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SegmentedButton<String>(
                        emptySelectionAllowed: true,
                        segments: const [
                          ButtonSegment(value: "FAQ", label: Text("FAQ")),
                          ButtonSegment(
                              value: "NON-FAQ", label: Text("NON-FAQ")),
                        ],
                        selected: qualityType != null ? {qualityType!} : {},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            qualityType = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Analyst Section - label above
              labeled(
                'Quality Analyst Name',
                TextFormField(
                  controller: _analystNameController,
                  decoration: modernDecoration('', labelInside: false,hintText: "Enter Name"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter Analyst Name"
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              /// Image picker section
              labeled(
                'Attach Image (गिरदावरी / Agreement)',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _pickedImage == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.image_outlined,
                                      size: 42, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('No image selected',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_pickedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Remark field
              labeled(
                'Remark',
                TextFormField(
                  controller: _remarkController,
                  decoration: modernDecoration('', labelInside: false, hintText: 'Enter remark'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter remark' : null,
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      /// Modern Bottom Button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: const Color.fromRGBO(0, 0, 0, 0.05),
              )
            ],
          ),
          child: CommonButton(
            text: 'SUBMIT REPORT',
            onPressed: () {
              _submitForm();
            },
          ),
        ),
      ),
    );
  }
}
