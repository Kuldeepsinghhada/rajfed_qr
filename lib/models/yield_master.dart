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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['yield_ID'] = this.yieldID;
    data['yield_District'] = this.yieldDistrict;
    data['yield_CropID'] = this.yieldCropID;
    data['yield_Rate'] = this.yieldRate;
    data['yield_DistrictId'] = this.yieldDistrictId;
    return data;
  }
}