import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OfficeInfo {
  final String region;
  final String name;
  final String address;
  final String phone;
  final String mobile;

  OfficeInfo({
    required this.region,
    required this.name,
    required this.address,
    required this.phone,
    required this.mobile,
  });
}

final List<OfficeInfo> offices = [
  OfficeInfo(
    region: "अजमेर",
    name: "श्री गौरव सेन",
    address: "बी-109, दांतानगर, जटिया हिल्स, लोहागल रोड, अजमेर",
    phone: "0145-2433107",
    mobile: "94625-50456",
  ),
  OfficeInfo(
    region: "भरतपुर",
    name: "श्री चन्द्र भान पाराशर",
    address: "115, कृष्णा नगर, भरतपुर",
    phone: "05644-222490",
    mobile: "94605-06346",
  ),
  OfficeInfo(
    region: "बीकानेर",
    name: "श्री शिशुपाल सिंह",
    address: "ए-97, सादुलगंज, बीकानेर",
    phone: "0151-2545282",
    mobile: "94145-02141",
  ),
  OfficeInfo(
    region: "जयपुर",
    name: "श्रीमती सुलक्षणा देवाना",
    address: "4, भवानी सिंह रोड, जयपुर",
    phone: "0141-2740753",
    mobile: "94143-63867",
  ),
  OfficeInfo(
    region: "जोधपुर",
    name: "श्री दलपत दान",
    address: "राजीव गांधी सहकार भवन, कमरा नं. 202, द्वितीय मंजिल, जोधपुर",
    phone: "0291-2639544",
    mobile: "94142-94245",
  ),
  OfficeInfo(
    region: "कोटा",
    name: "श्री विष्णु दत्त शर्मा",
    address: "20-बी, न्यू कॉलोनी, गुमानपुरा, कोटा",
    phone: "0744-2366242",
    mobile: "86194-10225",
  ),
  OfficeInfo(
    region: "श्रीगंगानगर",
    name: "श्री हरी सिंह",
    address: "101-ए, अशोक नगर, श्रीगंगानगर",
    phone: "0154-2470783",
    mobile: "93519-88106",
  ),
  OfficeInfo(
    region: "उदयपुर",
    name: "श्री वी.एन. सिंह",
    address: "23, पद्मिनी मार्ग, रविन्द्र नगर, उदयपुर",
    phone: "0294-2490302",
    mobile: "94147-59184",
  ),
];

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _dialNumber(String number) async {
    final Uri url = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: HeadquartersSection(),
              ),
              const SizedBox(height: 16),
              Card(
                child: RegionalOfficesSection(
                  offices: offices,
                  onDial: _dialNumber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable component for headquarters section
class HeadquartersSection extends StatelessWidget {
  HeadquartersSection({super.key});

  final List<_HeadquartersBranch> branches = const [
    _HeadquartersBranch(
      title: "चित्त एवं लेखा",
      contacts: [
        _HeadquartersContact(
          name: "डाॅ. भगवान सहाय लाडला",
          subtitle: "महाप्रबंधक (चित्त एवं लेखा)",
          phone: null,
        ),
        _HeadquartersContact(
          name: "श्रीमती शालिनी लुहाडिया",
          subtitle: "उप महाप्रबंधक (लेखा)",
          phone: "2740351",
        ),
      ],
    ),
    _HeadquartersBranch(
      title: "वाणिज्य शाखा",
      contacts: [
        _HeadquartersContact(
          name: "श्री कार्तिकेय मिश्र",
          subtitle: "महाप्रबंधक (वाणिज्य)",
          phone: "2740076",
        ),
        _HeadquartersContact(
          name: "श्री बाबूदीन",
          subtitle: "वरिष्ठ प्रबंधक",
          phone: "2740076",
        ),
        _HeadquartersContact(
          name: "श्री दिलीप पारिक",
          subtitle: "उप रजिस्टार",
          phone: "2740108",
        ),
      ],
    ),
    _HeadquartersBranch(
      title: "कृषि आदान शाखा",
      contacts: [
        _HeadquartersContact(
          name: "श्री सुवालाल जाट",
          subtitle: null,
          phone: "2740457",
        ),
      ],
    ),
    _HeadquartersBranch(
      title: "मानव संसाधन विकास",
      contacts: [
        _HeadquartersContact(
          name: "डाॅ. अमित शर्मा",
          subtitle: "महाप्रबंधक (मा.सं.वि.)",
          phone: "2740418",
        ),
        _HeadquartersContact(
          name: "श्री बुद्ध प्रकाश मोर्य",
          subtitle: "प्रबंधक (भंडारण)",
          phone: "2740364",
        ),
      ],
    ),
    _HeadquartersBranch(
      title: "सहकारी पशु आहार फैक्ट्री",
      contacts: [
        _HeadquartersContact(
          name: "डाॅ. भगवान सहाय लाडला",
          subtitle: "महाप्रबंधक (फैक्ट्री)",
          phone: "0141 4895799",
        ),
        _HeadquartersContact(
          name: "श्रीमती संतोष कंवर",
          subtitle: "उप रजिस्टार प्रबंधक (फैक्ट्री)",
          phone: "-",
        ),
      ],
    ),
    _HeadquartersBranch(
      title: "गैस शाखा",
      contacts: [
        _HeadquartersContact(
          name: "श्रीमती दीपा शर्मा",
          subtitle: "प्रभारी (गैस)",
          phone: "2740203 / 2740684",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:
          const Text("मुख्यालय", style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        ListView.separated(
          itemCount: branches.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final branch = branches[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...branch.contacts.map((contact) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                contact.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (contact.subtitle != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2.0),
                                                  child: Text(
                                                    contact.subtitle!,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (contact.phone != null &&
                                            contact.phone != "-")
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.phone,
                                                  color: Colors.green,
                                                  size: 20),
                                              const SizedBox(width: 6),
                                              Text(
                                                contact.phone!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HeadquartersBranch {
  final String title;
  final List<_HeadquartersContact> contacts;
  const _HeadquartersBranch({required this.title, required this.contacts});
}

class _HeadquartersContact {
  final String name;
  final String? subtitle;
  final String? phone;
  const _HeadquartersContact({required this.name, this.subtitle, this.phone});
}

// Reusable component for regional offices
class RegionalOfficesSection extends StatelessWidget {
  final List<OfficeInfo> offices;
  final void Function(String) onDial;
  const RegionalOfficesSection(
      {super.key, required this.offices, required this.onDial});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("क्षेत्रीय कार्यालय",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        ListView.separated(
          itemCount: offices.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final office = offices[index];
            return OfficeInfoTile(office: office, onDial: onDial);
          },
          separatorBuilder: (context, index) => const Divider(height: 16),
        ),
      ],
    );
  }
}

// Reusable tile for office info
class OfficeInfoTile extends StatelessWidget {
  final OfficeInfo office;
  final void Function(String) onDial;
  const OfficeInfoTile({super.key, required this.office, required this.onDial});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        office.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        office.region,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Phone actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          office.phone,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_android,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          office.mobile,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Optionally, add a divider and more info here
          ],
        ),
      ),
    );
  }
}
