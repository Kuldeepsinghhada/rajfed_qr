class WareHouseModel {
  int? wareHouseId;
  String? wareHouseName;
  int? districtId;
  String? districTCODE;

  WareHouseModel(
      {this.wareHouseId,
        this.wareHouseName,
        this.districtId,
        this.districTCODE});

  WareHouseModel.fromJson(Map<String, dynamic> json) {
    wareHouseId = json['wareHouseId'];
    wareHouseName = json['wareHouseName'];
    districtId = json['districtId'];
    districTCODE = json['districT_CODE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wareHouseId'] = this.wareHouseId;
    data['wareHouseName'] = this.wareHouseName;
    data['districtId'] = this.districtId;
    data['districT_CODE'] = this.districTCODE;
    return data;
  }
}