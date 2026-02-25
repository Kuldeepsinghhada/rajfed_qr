import 'package:flutter/material.dart';
import 'package:rajfed_qr/Screens/Registration/screens/jan_aadhar_page.dart';

class InformationPage extends StatefulWidget {
  static const routeName = '/information';

  const InformationPage({Key? key}) : super(key: key);

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final List<String> _paragraphs = [
    'समर्थन मूल्य पर जिंसो कि खरीद भारत सरकार द्वारा निर्धारित FAQ मापदंड पूर्ण होने कि स्थिति में ही खरीद कि जा सकेगी',
    'अनिवार्य :- जनआधार में यदि किसान का खाता संख्या/ ब्रांच आईएफएससी गलत है तो पहले जनआधार में अपडेट करें, जनआधार अपडेट होजाने के पश्चात ही किसान का पंजीकरण करें |',
    'अनिवार्य :- किसान का पंजीकरण गिरदावरी में अंकित नाम से ही करें (बटाईदार होने पर बटाईदार के नाम से पंजीकरण हो सकता है) |',
    'गिरदावरी की प्रति इ-मित्र यूजर अपने पास सुरक्षित रखें |',
    'अनिवार्य :- एक गिरदावरी में अंकित एक नाम पर एक ही रजिस्ट्रेशन होगा तथा बुवाई क्षेत्र हेक्टेयर में ही भरें |',
    'अनिवार्य :- एक जनआधार कार्ड पर एक ही रजिस्ट्रेशन होगा |',
    'एक जनआधार कार्ड पर एक पंजीकरण ही होगा अतः यदि किसान की मूंग/उड़द की गिरदावरी है तो उसे “भूमि विवरण जोड़े” आप्शन से एक ही फॉर्म में जोड़े |',
    'बटाईदार का अग्रीमेंट गिरदावरी की पीडीएफ़ के साथ पंजीकरण के समय अपलोड करना होगा',
    'क्रय केंद्र का चयन :- किसान की भूमि जिस तहसील में है उस तहसील में कार्यरत क्रय केंद्र का चयन किया जा सकेगा अन्य तहसील मे पंजीयन मान्य नही होगा |',
    'यदि सम्बंधित तहसील SHOW नहीं हो रही हो तो RAJFED.OPR@yahoo.com पर ईमेल करें |',
    'E-Mitra से टोकन नंबर जनरेट नही होने की स्थिति में रजिस्ट्रेशन मान्य नही होगा । इस स्थिति में जिम्मेदारी पूर्णतया E-Mitra होगी ।',
  ];

  @override
  Widget build(BuildContext context) {
    final TextStyle headingStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );

    final TextStyle bodyStyle = TextStyle(
      fontSize: 16,
      height: 1.5,
      color: Colors.black87,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('आवश्यक सुचना'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('आवश्यक सुचना', style: headingStyle),
                const SizedBox(height: 12),
                ..._paragraphs.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(p, style: bodyStyle),
                    )),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, JanAadharPage.routeName);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
