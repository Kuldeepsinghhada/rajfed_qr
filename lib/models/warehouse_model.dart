class WareHouseModel {
  int? wareHouseId;
  String? wareHouseName;
  int? districtId;
  String? districTCODE;

  WareHouseModel(
      {wareHouseId,
        wareHouseName,
        districtId,
        districTCODE});

  WareHouseModel.fromJson(Map<String, dynamic> json) {
    wareHouseId = json['wareHouseId'];
    wareHouseName = json['wareHouseName'];
    districtId = json['districtId'];
    districTCODE = json['districT_CODE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wareHouseId'] = wareHouseId;
    data['wareHouseName'] = wareHouseName;
    data['districtId'] = districtId;
    data['districT_CODE'] = districTCODE;
    return data;
  }
}