import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Registration/screens/farmer_detail_page.dart';

class JanAadharPage extends StatefulWidget {
  static const routeName = '/jan-aadhar';

  const JanAadharPage({Key? key}) : super(key: key);

  @override
  State<JanAadharPage> createState() => _JanAadharPageState();
}

class _JanAadharPageState extends State<JanAadharPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _tehsils = [
    'कृपया तहसील चुनें',
    'तहसील A',
    'तहसील B',
    'तहसील C',
  ];

  final List<String> _fasals = [
    'कृपया फसल चुनें',
    'मूंग',
    'उड़द',
    'गेहूँ',
    'चना',
  ];

  String? _selectedTehsil;
  String? _selectedFasal;

  // true => Enrollment, false => Card No.
  bool _isEnrollment = true;
  final TextEditingController _aadharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTehsil = _tehsils[0];
    _selectedFasal = _fasals[0];
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (!_formKey.currentState!.validate()) return;

    // Placeholder verification action. Replace with real API call as needed.
    final mode = _isEnrollment ? 'जनआधार एनरोलमेंट' : 'जनआधार कार्ड न.';
    final tehsil = _selectedTehsil ?? '';
    final fasal = _selectedFasal ?? '';
    final idValue = _aadharController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('वेरिफाई किया गया: $mode = $idValue, तहसील: $tehsil, फसल: $fasal'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('जनआधार कार्ड विवरण'),
      ),
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
                  Text(
                    'जनआधार कार्ड विवरण',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Tehsil dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTehsil,
                    decoration: inputDecoration.copyWith(labelText: 'तहसील'),
                    items: _tehsils
                        .map((t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTehsil = v),
                    validator: (value) {
                      if (value == null || value == _tehsils[0]) {
                        return 'कृपया तहसील चुनें';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Fasal dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedFasal,
                    decoration: inputDecoration.copyWith(labelText: 'फसल'),
                    items: _fasals
                        .map((f) => DropdownMenuItem<String>(
                              value: f,
                              child: Text(f),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedFasal = v),
                    validator: (value) {
                      if (value == null || value == _fasals[0]) {
                        return 'कृपया फसल चुनें';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Mode selection
                  Text('चयन करें', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isEnrollment = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: _isEnrollment ? Colors.green[50] : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _isEnrollment ? Colors.green : Colors.grey.shade300)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: _isEnrollment,
                                  onChanged: (v) => setState(() => _isEnrollment = v ?? true),
                                ),
                                const SizedBox(width: 4),
                                const Text('जनआधार एनरोलमेंट'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isEnrollment = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                color: !_isEnrollment ? Colors.green[50] : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: !_isEnrollment ? Colors.green : Colors.grey.shade300)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: _isEnrollment,
                                  onChanged: (v) => setState(() => _isEnrollment = v ?? false),
                                ),
                                const SizedBox(width: 4),
                                const Text('जनआधार कार्ड न.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Input field for enrollment / card no.
                  TextFormField(
                    controller: _aadharController,
                    decoration: inputDecoration.copyWith(
                      labelText: _isEnrollment ? 'जनआधार एनरोलमेंट' : 'जनआधार कार्ड न.',
                      hintText: _isEnrollment ? 'उदाहरण: 1234/56789/01234' : 'उदाहरण: 1234-5678-9012',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _isEnrollment ? 'कृपया एनरोलमेंट नंबर दर्ज करें' : 'कृपया कार्ड नंबर दर्ज करें';
                      }
                      // Add lightweight format checks if needed
                      if (!_isEnrollment && value.trim().length < 6) {
                        return 'अमान्य कार्ड नंबर';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _onVerify,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Verify', style: TextStyle(fontSize: 16)),
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
                            Navigator.pushNamed(context, FarmerDetailPage.routeName);
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
    );
  }
}

