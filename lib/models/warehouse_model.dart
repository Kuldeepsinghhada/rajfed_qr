class WareHouseModel {
  int? wareHouseId;
  String? wareHouseName;
  int? districtId;
  String? districTCODE;
  double? lat;
  double? long;
  double? capacity;
  String? status;

  WareHouseModel(
      {this.wareHouseId,
      this.wareHouseName,
      this.districtId,
      this.districTCODE,
      this.lat,
      this.long,
      this.capacity,
      this.status});

  WareHouseModel.fromJson(Map<String, dynamic> json) {
    wareHouseId = json['wareHouseId'];
    wareHouseName = json['wareHouseName'];
    districtId = json['districtId'];
    districTCODE = json['districT_CODE'];
    lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    long = json['long'] != null ? double.tryParse(json['long'].toString()) : null;
    capacity = json['capacity'] != null
        ? double.tryParse(json['capacity'].toString())
        : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wareHouseId'] = wareHouseId;
    data['wareHouseName'] = wareHouseName;
    data['districtId'] = districtId;
    data['districT_CODE'] = districTCODE;
    data['lat'] = lat;
    data['long'] = long;
    data['capacity'] = capacity;
    data['status'] = status;
    return data;
  }
}