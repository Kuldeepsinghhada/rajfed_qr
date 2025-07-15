class DispatchInchargeModel {
  int? lotNo;
  String? farmerRegId;
  int? purchaseCenterId;
  int? cropID;
  double? qtl;
  int? noOfBardana;
  String? cropEN;
  String? purchaseCenterKendra;
  String? transctionDate;
  String? dispatchDateTime;
  String? receivedDateTime;
  String? flagName;
  String? warehouseName;
  String? message;
  String? qrCode;
  String? crop_descEN;

  DispatchInchargeModel(
      {this.lotNo,
      this.farmerRegId,
      this.purchaseCenterId,
      this.cropID,
      this.qtl,
      this.noOfBardana,
      this.cropEN,
      this.purchaseCenterKendra,
      this.transctionDate,
      this.flagName,
      this.warehouseName,
      this.qrCode,
      this.crop_descEN,
      this.dispatchDateTime,
      this.receivedDateTime
      });

  DispatchInchargeModel.fromJson(Map<String, dynamic> json) {
    lotNo = json['lotNo'];
    farmerRegId = json['farmerRegId'];
    purchaseCenterId = json['purchaseCenterId'];
    cropID = json['crop_ID'];
    qtl = json['qtl'];
    noOfBardana = json['noOfBardana'];
    cropEN = json['cropEN'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
    transctionDate = json['transction_Date'];
    flagName = json['flagName'];
    warehouseName = json['warehouseName'];
    message = json['message'];
    qrCode = json['qrCode'];
    crop_descEN = json['crop_descEN'];
    dispatchDateTime = json['dispatchDateTime'];
    receivedDateTime = json['receivedDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['lotNo'] = this.lotNo;
    data['farmerRegId'] = this.farmerRegId;
    data['purchaseCenterId'] = this.purchaseCenterId;
    data['crop_ID'] = this.cropID;
    data['qtl'] = this.qtl;
    data['noOfBardana'] = this.noOfBardana;
    data['cropEN'] = this.cropEN;
    data['purchaseCenter_Kendra'] = this.purchaseCenterKendra;
    data['transction_Date'] = this.transctionDate;
    data['flagName'] = this.flagName;
    data['warehouseName'] = this.warehouseName;
    return data;
  }
}
