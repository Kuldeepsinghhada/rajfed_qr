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
      {this.lotNo,
        this.farmerRegId,
        this.purchaseCenterId,
        this.cropID,
        this.qtl,
        this.noOfBardana,
        this.cropEN,
        this.purchaseCenterKendra,
        this.transctionDate});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lotNo'] = this.lotNo;
    data['farmerRegId'] = this.farmerRegId;
    data['purchaseCenterId'] = this.purchaseCenterId;
    data['crop_ID'] = this.cropID;
    data['qtl'] = this.qtl;
    data['noOfBardana'] = this.noOfBardana;
    data['cropEN'] = this.cropEN;
    data['purchaseCenter_Kendra'] = this.purchaseCenterKendra;
    data['transction_Date'] = this.transctionDate;
    return data;
  }
}