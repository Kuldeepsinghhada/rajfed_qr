import 'package:flutter/material.dart';

class TotalPurchaseScreen extends StatefulWidget {
  const TotalPurchaseScreen({super.key});

  @override
  State<TotalPurchaseScreen> createState() =>
      _TotalPurchaseScreenState();
}

class _TotalPurchaseScreenState extends State<TotalPurchaseScreen> {
  List<Map<String, String>> allFarmers = [
    {
      "name": "Ramesh Kumar",
      "regNo": "REG123456",
      "qtl": "43",
      "amount": "4353432"
    },
    {
      "name": "Sunita Devi",
      "regNo": "REG789012",
      "qtl": "25",
      "amount": "2222125.0"
    },
    {
      "name": "Amit Singh",
      "regNo": "REG456789",
      "qtl": "25",
      "amount": "34223125.0"
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
      appBar: AppBar(title: Text("Total Purchase")),
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
              Icon(Icons.scale, size: 20, color: Colors.green),
              SizedBox(width: 6),
              Text("Qtl:   "),
              Text("${farmer['qtl']}",style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 20, color: Colors.brown),
              SizedBox(width: 6),
              Text("Amount: "),
              Text("${farmer['amount']}",style: TextStyle(fontWeight: FontWeight.w700),),
            ],
          ),
        ],
      ),
    );
  }
}
