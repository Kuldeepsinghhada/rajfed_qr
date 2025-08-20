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
      {lotNo,
      farmerRegId,
      purchaseCenterId,
      cropID,
      qtl,
      noOfBardana,
      cropEN,
      purchaseCenterKendra,
      transctionDate,
      flagName,
      warehouseName,
      qrCode,
      crop_descEN,
      dispatchDateTime,
      receivedDateTime
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
    data['flagName'] = flagName;
    data['warehouseName'] = warehouseName;
    return data;
  }
}
