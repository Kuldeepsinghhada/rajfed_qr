class InchargeDetails {
  int? lotNo;
  String? farmerRegId;
  int? purchaseCenterId;
  int? cropID;
  double? qtl;
  int? noOfBardana;
  String? cropEN;
  String? purchaseCenterKendra;
  String? transctionDate;

  InchargeDetails(
      {lotNo,
        farmerRegId,
        purchaseCenterId,
        cropID,
        qtl,
        noOfBardana,
        cropEN,
        purchaseCenterKendra,
        transctionDate});

  InchargeDetails.fromJson(Map<String, dynamic> json) {
    lotNo = json['lotNo'];
    farmerRegId = json['farmerRegId'];
    purchaseCenterId = json['purchaseCenterId'];
    cropID = json['crop_ID'];
    qtl = json['qtl'];
    noOfBardana = json['noOfBardana'];
    cropEN = json['cropEN'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
    transctionDate = json['transction_Date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lotNo'] = lotNo;
    data['farmerRegId'] = farmerRegId;
    data['purchaseCenterId'] = purchaseCenterId;
    data['crop_ID'] = cropID;
    data['qtl'] = qtl;
    data['noOfBardana'] = noOfBardana;
    data['cropEN'] = cropEN;
    data['purchaseCenter_Kendra'] = purchaseCenterKendra;
    data['transction_Date'] = transctionDate;
    return data;
  }
}