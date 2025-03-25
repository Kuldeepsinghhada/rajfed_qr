class SavedQrModel {
  int? lotNo;
  String? farmerRegId;
  String? qrCode;
  String? deviceInfo;
  int? purchaseCenterId;
  String? datetime;
  int? status;
  int? cropId;
  int? wareHouseId;
  String? vehicleNo;

  SavedQrModel(
      {this.lotNo,
        this.farmerRegId,
        this.qrCode,
        this.deviceInfo,
        this.purchaseCenterId,
        this.datetime,
        this.status,
        this.cropId,
        this.wareHouseId,
        this.vehicleNo
      });

  SavedQrModel.fromJson(Map<String, dynamic> json) {
    lotNo = json['lotNo'];
    farmerRegId = json['farmerRegId'];
    qrCode = json['qrCode'];
    deviceInfo = json['deviceInfo'];
    purchaseCenterId = json['purchaseCenterId'];
    datetime = json['datetime'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lotNo'] = lotNo;
    data['farmerRegId'] = farmerRegId;
    data['qrCode'] = qrCode;
    data['purchaseCenterId'] = purchaseCenterId;
    data['cropId'] = cropId;
    data['wareHouseId'] = wareHouseId;
    data['vehicleNo'] = vehicleNo;
    return data;
  }

}