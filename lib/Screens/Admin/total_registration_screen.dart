import 'package:flutter/material.dart';

class TotalRegistrationScreen extends StatefulWidget {
  const TotalRegistrationScreen({super.key});

  @override
  State<TotalRegistrationScreen> createState() =>
      _TotalRegistrationScreenState();
}

class _TotalRegistrationScreenState extends State<TotalRegistrationScreen> {
  List<Map<String, String>> allFarmers = [
    {
      "name": "Ramesh Kumar",
      "regNo": "REG123456",
      "mobile": "9876543210",
      "hectare": "3.5"
    },
    {
      "name": "Sunita Devi",
      "regNo": "REG789012",
      "mobile": "9123456780",
      "hectare": "5.0"
    },
    {
      "name": "Amit Singh",
      "regNo": "REG456789",
      "mobile": "9900123456",
      "hectare": "4.2"
    },
  ];

  List<Map<String, String>> filteredFarmers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFarmers = allFarmers;
    searchController.addListener(_filterList);
  }

  void _filterList() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFarmers = allFarmers.where((farmer) {
        final name = farmer['name']?.toLowerCase() ?? '';
        final regNo = farmer['regNo']?.toLowerCase() ?? '';
        return name.contains(query) || regNo.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or registration number',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredFarmers.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                final farmer = filteredFarmers[index];
                return buildFarmerTile(farmer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFarmerTile(Map<String, String> farmer) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            farmer["name"] ?? "",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.badge, size: 20, color: Colors.teal),
              SizedBox(width: 6),
              Text("Reg No:  "),
              Text("${farmer['regNo']}",style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 20, color: Colors.green),
              SizedBox(width: 6),
              Text("Mobile:   "),
              Text("${farmer['mobile']}",style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.landscape, size: 20, color: Colors.brown),
              SizedBox(width: 6),
              Text("Hectare: "),
              Text("${farmer['hectare']} ha",style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
        ],
      ),
    );
  }
}
