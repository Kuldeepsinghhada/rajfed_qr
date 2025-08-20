class RejectedModel {
  int? lotNo;
  String? farmerRegId;
  String? qrCode;
  String? rejectedDate;
  String? purchaseCenterKendra;

  RejectedModel(
      {lotNo,
        farmerRegId,
        qrCode,
        rejectedDate,
        purchaseCenterKendra});

  RejectedModel.fromJson(Map<String, dynamic> json) {
    lotNo = json['lotNo'];
    farmerRegId = json['farmerRegId'];
    qrCode = json['qrCode'];
    rejectedDate = json['rejected_Date'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lotNo'] = lotNo;
    data['farmerRegId'] = farmerRegId;
    data['qrCode'] = qrCode;
    data['rejected_Date'] = rejectedDate;
    data['purchaseCenter_Kendra'] = purchaseCenterKendra;
    return data;
  }
}