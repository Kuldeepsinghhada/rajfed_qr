class YieldMaster {
  int? yieldID;
  String? yieldDistrict;
  int? yieldCropID;
  double? yieldRate;
  int? yieldDistrictId;

  YieldMaster(
      {this.yieldID,
      this.yieldDistrict,
      this.yieldCropID,
      this.yieldRate,
      this.yieldDistrictId});

  YieldMaster.fromJson(Map<String, dynamic> json) {
    yieldID = json['yield_ID'];
    yieldDistrict = json['yield_District'];
    yieldCropID = json['yield_CropID'];
    yieldRate = json['yield_Rate'];
    yieldDistrictId = json['yield_DistrictId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['yield_ID'] = yieldID;
    data['yield_District'] = yieldDistrict;
    data['yield_CropID'] = yieldCropID;
    data['yield_Rate'] = yieldRate;
    data['yield_DistrictId'] = yieldDistrictId;
    return data;
  }
}
