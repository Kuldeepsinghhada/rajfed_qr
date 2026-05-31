class WareHouseModel {
  int? wareHouseId;
  String? wareHouseName;
  int? districtId;
  String? districTCODE;
  double? lat;
  double? long;
  double? capacity;
  String? status;
  String? constructionYear;
  String? ownerName;
  String? warehouseCondtion;

  WareHouseModel(
      {this.wareHouseId,
      this.wareHouseName,
      this.districtId,
      this.districTCODE,
      this.lat,
      this.long,
      this.capacity,
      this.status,
      this.constructionYear,
      this.ownerName,
      this.warehouseCondtion});

  WareHouseModel.fromJson(Map<String, dynamic> json) {
    // Parse wareHouseId that may come as int or string. Try common keys first,
    // then scan the JSON for a key that looks like a warehouse id.
    dynamic whId = json['wareHouseId'] ?? json['warehouseId'] ?? json['warehouse_id'] ?? json['wareHouse_ID'] ?? json['WareHouseId'];
    if (whId == null) {
      // scan for any key containing both 'ware' and 'id' or containing 'warehouse' and 'id'
      for (var entry in json.entries) {
        final key = entry.key.toString().toLowerCase();
        if ((key.contains('ware') || key.contains('warehouse')) && key.contains('id')) {
          whId = entry.value;
          break;
        }
      }
      // also accept a plain 'id' field as a fallback if nothing else found
      if (whId == null && json.containsKey('id')) whId = json['id'];
    }
    if (whId is int) {
      wareHouseId = whId;
    } else if (whId is String) {
      wareHouseId = int.tryParse(whId);
    } else {
      wareHouseId = null;
    }

    // Name may come in different casing/keys
    wareHouseName = (json['wareHouseName'] ?? json['wareHouse_Name'] ?? json['warehouseName'] ?? json['wareHouse'])?.toString();

    // Parse districtId as int or string (try common keys)
    var dId = json['districtId'] ?? json['districtID'] ?? json['district_id'];
    if (dId is int) {
      districtId = dId;
    } else if (dId is String) {
      districtId = int.tryParse(dId);
    } else {
      districtId = null;
    }
    districTCODE = json['districT_CODE'];
    lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    long = json['long'] != null ? double.tryParse(json['long'].toString()) : null;
    capacity = json['capacity'] != null
        ? double.tryParse(json['capacity'].toString())
        : null;
    status = json['status'];
    constructionYear = (json['constructionYear'] ?? json['construction_year'] ?? json['constructionYear'] ?? json['yearOfConstruction'])?.toString();
    ownerName = (json['ownerName'] ?? json['owner_name'] ?? json['ownerName'] ?? json['owner_Name'])?.toString();
    warehouseCondtion = (json['warehouseCondtion'] ?? json['warehouse_condition'] ?? json['warehouseCondtion'])?.toString();
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
    data['constructionYear'] = constructionYear;
    data['ownerName'] = ownerName;
    data['construction_year'] = constructionYear;
    data['owner_name'] = ownerName;
    data['warehouseCondition'] = warehouseCondtion;
    return data;
  }
}