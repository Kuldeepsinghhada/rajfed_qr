class RejectedModel {
  int? lotNo;
  String? farmerRegId;
  String? qrCode;
  String? rejectedDate;
  String? purchaseCenterKendra;

  RejectedModel(
      {this.lotNo,
        this.farmerRegId,
        this.qrCode,
        this.rejectedDate,
        this.purchaseCenterKendra});

  RejectedModel.fromJson(Map<String, dynamic> json) {
    lotNo = json['lotNo'];
    farmerRegId = json['farmerRegId'];
    qrCode = json['qrCode'];
    rejectedDate = json['rejected_Date'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lotNo'] = this.lotNo;
    data['farmerRegId'] = this.farmerRegId;
    data['qrCode'] = this.qrCode;
    data['rejected_Date'] = this.rejectedDate;
    data['purchaseCenter_Kendra'] = this.purchaseCenterKendra;
    return data;
  }
}