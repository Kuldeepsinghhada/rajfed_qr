import 'package:flutter/material.dart';

class BataidarPage extends StatefulWidget {
  static const routeName = '/bataidar';
  const BataidarPage({Key? key}) : super(key: key);

  @override
  State<BataidarPage> createState() => _BataidarPageState();
}

class _BataidarPageState extends State<BataidarPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _options = ['कृपया चुनें', 'हां', 'नहीं'];
  String? _selectedOption;

  final TextEditingController _aadharController = TextEditingController();
  final List<String> _months = [
    'कृपया माह चुनें',
    'जनवरी',
    'फरवरी',
    'मार्च',
    'अप्रैल',
    'मई',
    'जून',
    'जुलाई',
    'अगस्त',
    'सितंबर',
    'अक्टूबर',
    'नवंबर',
    'दिसंबर',
  ];
  String? _selectedMonth;

  bool get _isBataidar => _selectedOption == 'हां';

  @override
  void initState() {
    super.initState();
    _selectedOption = _options[0];
    _selectedMonth = _months[0];
  }

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_isBataidar) {
      if (!_formKey.currentState!.validate()) return;

      final aadhar = _aadharController.text.trim();
      final month = _selectedMonth ?? '';

      // Placeholder verification - show SnackBar. Replace with API call when available.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('वेरिफाई किया गया: JANAADHAAR=$aadhar, माह=$month')),
      );
    } else {
      // If not bataidar, simply acknowledge
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पंजीकरण बटाईदार द्वारा नहीं किया जा रहा है')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('बटाईदार पंजीकरण')),
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
                  Text('क्या यह पंजीकरण बटाईदार द्वारा करवाया जा रहा है ?', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _selectedOption,
                    decoration: inputDecoration.copyWith(labelText: 'चुनें'),
                    items: _options
                        .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedOption = v;
                        if (!_isBataidar) {
                          _aadharController.clear();
                          _selectedMonth = _months[0];
                        }
                      });
                    },
                    validator: (v) {
                      if (v == null || v == _options[0]) return 'कृपया विकल्प चुनें';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Conditional fields when bataidar selects 'हां'
                  if (_isBataidar) ...[
                    TextFormField(
                      controller: _aadharController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration.copyWith(labelText: 'भूमि मालिक का JANAADHAAR'),
                      maxLength: 12,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'कृपया JANAADHAAR दर्ज करें';
                        final digits = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length != 12) return 'JANAADHAAR 12 अंकों का होना चाहिए';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: inputDecoration.copyWith(labelText: 'माह चुनें'),
                      items: _months
                          .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMonth = v),
                      validator: (v) {
                        if (v == null || v == _months[0]) return 'कृपया माह चुनें';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

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
                          onPressed: _onVerify,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Text('Verify'),
                          ),
                        ),
                      ],
                    ),

                  ] else ...[
                    const SizedBox(height: 8),
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
                          onPressed: _onVerify,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Text('Verify'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
