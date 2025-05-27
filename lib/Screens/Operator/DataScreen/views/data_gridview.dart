import 'package:flutter/material.dart';

class DataGridView extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      "title": "Total Purchase",
      "image": Icons.shopping_cart_checkout_rounded,
      'color': Color(0xFFAB47BC)
    },
    {
      "title": "Total Deposit",
      "image": Icons.cabin,
      'color': Color(0xFF1CC88A)
    },
    {
      "title": "In Transit",
      "image": Icons.directions_transit,
      'color': Color(0xFFFFC107)
    },
    {
      "title": "Total Bardana",
      "image": Icons.shopping_bag_outlined,
      'color': Color(0xFF36B9CC)
    },
  ];

  DataGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width to set column count
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : 4;

    return GridView.builder(
      padding: EdgeInsets.all(12),
      itemCount: items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 1.5),
      //scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: items[index]['color'],
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    Icon(items[index]["image"]!, size: 50, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  items[index]["title"]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "3,12,234",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
