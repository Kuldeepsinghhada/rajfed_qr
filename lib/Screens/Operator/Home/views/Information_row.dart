import 'package:flutter/material.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/utils/date_formatter.dart';

class InformationView extends StatelessWidget {
  const InformationView({required this.details,this.model, super.key});
  final OperatorDetails? details;
  final DispatchInchargeModel? model;
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
              title: "Lot No.", subtitle: (details?.lotId ?? model?.lotNo ?? 'NA').toString()),
          InformationRow(
              title: "Registration no.", subtitle: details?.farmerRegID ?? model?.farmerRegId ?? ''),
          Visibility(
              visible: details != null,
              child: InformationRow(title: "Name", subtitle: details?.farmerName ?? '')),
          InformationRow(
              title: "Purchase Center",
              subtitle: details?.purchaseCenterKendra ?? model?.purchaseCenterKendra ?? ''),
          Visibility(
            visible: details != null,
            child: InformationRow(
              title: "Purchase Date",
              subtitle:
                  DateFormatter.formatDateToDDMMMYYYY(details?.regDate ?? '')),),
          Visibility(
              visible: model?.dispatchDateTime != null,
              child: InformationRow(
                  title: "Dispatch Date",
                  subtitle: DateFormatter.formatDateToDDMMMYYYY(
                      model?.dispatchDateTime ?? 'NA'))),
          Visibility(
              visible: model?.receivedDateTime != null,
              child: InformationRow(
                  title: "Received Date",
                  subtitle: DateFormatter.formatDateToDDMMMYYYY(
                      model?.receivedDateTime ?? 'NA'))),
          InformationRow(
              title: "Quantity(Qt)",
              subtitle: "${details?.transctionQty ?? model?.qtl.toString() ?? 'NA'}"),
          details != null ? InformationRow(
              title: "No. of Bardana",
              subtitle: "${details?.transctionBardana ?? 'NA'}"): SizedBox(),
          InformationRow(
              title: "Copy Type", subtitle: details?.cropTypeEN ?? model?.cropEN ?? 'NA')
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
