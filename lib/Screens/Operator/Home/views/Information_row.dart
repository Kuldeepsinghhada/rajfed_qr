import 'package:flutter/material.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/utils/date_formatter.dart';

class InformationView extends StatelessWidget {
  const InformationView({required this.details, super.key});
  final OperatorDetails? details;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(4), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Shadow color
            spreadRadius: 2, // Spread of shadow
            blurRadius: 10, // Blur effect
            offset: Offset(4, 4), // Shadow position
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          InformationRow(
              title: "Registration no.", subtitle: details?.farmerRegID ?? ''),
          InformationRow(title: "Name", subtitle: details?.farmerName ?? ''),
          InformationRow(
              title: "Purchase Center",
              subtitle: details?.purchaseCenterKendra ?? ''),
          InformationRow(
              title: "Purchase Date",
              subtitle:
                  DateFormatter.formatDateToDDMMMYYYY(details?.regDate ?? '')),
          InformationRow(
              title: "Quantity(Qt)",
              subtitle: "${details?.transctionQty ?? ''}"),
          InformationRow(
              title: "No. of Bardana",
              subtitle: "${details?.transctionBardana ?? ''}"),
          InformationRow(
              title: "Copy Type", subtitle: details?.cropTypeEN ?? '')
        ],
      ),
    );
  }
}

class InformationRow extends StatelessWidget {
  const InformationRow(
      {required this.title, required this.subtitle, super.key});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 145, child: CommonText(text: title)),
        CommonText(text: ' :  '),
        Expanded(child: CommonText(text: subtitle))
      ],
    );
  }
}

class CommonText extends StatelessWidget {
  const CommonText({required this.text, super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}
