import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Registration/screens/bataidar_page.dart';

class FarmerDetailPage extends StatefulWidget {
  static const routeName = '/farmer-detail';
  const FarmerDetailPage({Key? key}) : super(key: key);

  @override
  State<FarmerDetailPage> createState() => _FarmerDetailPageState();
}

class _FarmerDetailPageState extends State<FarmerDetailPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cropCarrierNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _patwarHalkaController = TextEditingController();
  final TextEditingController _panchayatSamitiController = TextEditingController();
  final TextEditingController _gramPanchayatController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  final List<String> _categories = [
    'कृपया श्रेणी चुनें',
    'किसान',
    'बटाईदार',
    'अन्य',
  ];

  final List<String> _tehsils = [
    'कृपया तहसील चुनें',
    'तहसील A',
    'तहसील B',
    'तहसील C',
  ];

  String? _selectedCategory;
  String? _selectedTehsil;
  bool _isSmallOrMarginal = false;

  // In-memory storage for added farmer entries (simple list)
  final List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];
    _selectedTehsil = _tehsils[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cropCarrierNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _patwarHalkaController.dispose();
    _panchayatSamitiController.dispose();
    _gramPanchayatController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'cropCarrierName': _cropCarrierNameController.text.trim(),
      'isSmallOrMarginal': _isSmallOrMarginal,
      'mobile': _mobileController.text.trim(),
      'address': _addressController.text.trim(),
      'tehsil': _selectedTehsil,
      'patwarHalka': _patwarHalkaController.text.trim(),
      'panchayatSamiti': _panchayatSamitiController.text.trim(),
      'gramPanchayat': _gramPanchayatController.text.trim(),
      'village': _villageController.text.trim(),
    };

    setState(() {
      _entries.add(data);
      // clear form
      _nameController.clear();
      _cropCarrierNameController.clear();
      _mobileController.clear();
      _addressController.clear();
      _patwarHalkaController.clear();
      _panchayatSamitiController.clear();
      _gramPanchayatController.clear();
      _villageController.clear();
      _selectedCategory = _categories[0];
      _selectedTehsil = _tehsils[0];
      _isSmallOrMarginal = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added (${_entries.length}): ${data['name']}')),
    );
  }

  void _onSave() {
    // Keep existing save behaviour but keep it consistent with Add
    _onAdd();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Details / किसान विवरण')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('किसान विवरण', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration.copyWith(labelText: 'Name / नाम'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'कृपया नाम दर्ज करें' : null,
                  ),

                  const SizedBox(height: 12),

                  // श्रेणी
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: inputDecoration.copyWith(labelText: 'श्रेणी'),
                    items: _categories
                        .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) {
                      if (v == null || v == _categories[0]) return 'कृपया श्रेणी चुनें';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // फसल लाने वाले किसान/व्यक्ति का नाम
                  TextFormField(
                    controller: _cropCarrierNameController,
                    decoration: inputDecoration.copyWith(labelText: 'फसल लाने वाले किसान/व्यक्ति का नाम'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'कृपया नाम दर्ज करें' : null,
                  ),

                  const SizedBox(height: 12),

                  // छोटा/सीमांत किसान?
                  Row(
                    children: [
                      Expanded(child: Text('क्या किसान "लघु अथवा सीमांत किसान" है?')),
                      Switch(
                        value: _isSmallOrMarginal,
                        onChanged: (v) => setState(() => _isSmallOrMarginal = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Mobile
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration.copyWith(labelText: 'मोबाइल न.'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'कृपया मोबाइल नंबर दर्ज करें';
                      final digits = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length < 10) return 'अमान्य मोबाइल नंबर';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: inputDecoration.copyWith(labelText: 'पता'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'कृपया पता दर्ज करें' : null,
                  ),

                  const SizedBox(height: 12),

                  // तहसील
                  DropdownButtonFormField<String>(
                    value: _selectedTehsil,
                    decoration: inputDecoration.copyWith(labelText: 'तहसील'),
                    items: _tehsils.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _selectedTehsil = v),
                    validator: (v) {
                      if (v == null || v == _tehsils[0]) return 'कृपया तहसील चुनें';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // पटवार हल्का
                  TextFormField(
                    controller: _patwarHalkaController,
                    decoration: inputDecoration.copyWith(labelText: 'पटवार हल्का'),
                  ),

                  const SizedBox(height: 12),

                  // पंचायत समिति
                  TextFormField(
                    controller: _panchayatSamitiController,
                    decoration: inputDecoration.copyWith(labelText: 'पंचायत समिति'),
                  ),

                  const SizedBox(height: 12),

                  // ग्राम पंचायत
                  TextFormField(
                    controller: _gramPanchayatController,
                    decoration: inputDecoration.copyWith(labelText: 'ग्राम पंचायत'),
                  ),

                  const SizedBox(height: 12),

                  // ग्राम
                  TextFormField(
                    controller: _villageController,
                    decoration: inputDecoration.copyWith(labelText: 'ग्राम'),
                  ),

                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _onSave,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Save / सहेजें', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text('Back'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamed(context, BataidarPage.routeName);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Added: ${_entries.length}', style: const TextStyle(fontSize: 16)),
            ElevatedButton.icon(
              onPressed: _onAdd,
              icon: const Icon(Icons.add),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
