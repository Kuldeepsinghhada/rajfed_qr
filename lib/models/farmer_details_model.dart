class FarmerDetailsModel {
  String? farmerRegID;
  String? farmerNameEN;
  String? purchaseCenterKendra;
  String? cropDescEN;
  String? regDate;
  String? dateAllotment;
  String? purchaseDate;
  String? girdawriCheckDate;
  String? paymentTransOrderSheetDate;
  double? transctionQty;
  double? paymentTransTransferAmount;
  String? bankAccNo;
  String? ifsCCODE;
  String? utr;

  FarmerDetailsModel(
      {farmerRegID,
        farmerNameEN,
        purchaseCenterKendra,
        cropDescEN,
        regDate,
        dateAllotment,
        purchaseDate,
        girdawriCheckDate,
        paymentTransOrderSheetDate,
        transctionQty,
        paymentTransTransferAmount,
        bankAccNo,
        ifsCCODE,
        utr});

  FarmerDetailsModel.fromJson(Map<String, dynamic> json) {
    farmerRegID = json['farmerRegID'];
    farmerNameEN = json['farmerNameEN'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
    cropDescEN = json['crop_descEN'];
    regDate = json['regDate'];
    dateAllotment = json['dateAllotment'];
    purchaseDate = json['purchaseDate'];
    girdawriCheckDate = json['girdawriCheckDate'];
    paymentTransOrderSheetDate = json['paymentTrans_OrderSheetDate'];
    transctionQty = json['transction_Qty'];
    paymentTransTransferAmount = json['paymentTrans_TransferAmount'];
    bankAccNo = json['bank_Acc_No'];
    ifsCCODE = json['ifsC_CODE'];
    utr = json['utr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['farmerRegID'] = farmerRegID;
    data['farmerNameEN'] = farmerNameEN;
    data['purchaseCenter_Kendra'] = purchaseCenterKendra;
    data['crop_descEN'] = cropDescEN;
    data['regDate'] = regDate;
    data['dateAllotment'] = dateAllotment;
    data['purchaseDate'] = purchaseDate;
    data['girdawriCheckDate'] = girdawriCheckDate;
    data['paymentTrans_OrderSheetDate'] = paymentTransOrderSheetDate;
    data['transction_Qty'] = transctionQty;
    data['paymentTrans_TransferAmount'] = paymentTransTransferAmount;
    data['bank_Acc_No'] = bankAccNo;
    data['ifsC_CODE'] = ifsCCODE;
    data['utr'] = utr;
    return data;
  }
}