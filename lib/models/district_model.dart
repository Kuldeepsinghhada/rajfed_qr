class DistrictModel {
  int? districTID;
  String? district;
  String? districtNameLL;
  String? districtNameEN;
  String? state;
  String? status;
  String? dateActiveInactive;
  String? rto;

  DistrictModel(
      {districTID,
        district,
        districtNameLL,
        districtNameEN,
        state,
        status,
        dateActiveInactive,
        rto});

  DistrictModel.fromJson(Map<String, dynamic> json) {
    districTID = json['districT_ID'];
    district = json['district'];
    districtNameLL = json['district_Name_LL'];
    districtNameEN = json['district_Name_EN'];
    state = json['state'];
    status = json['status'];
    dateActiveInactive = json['date_Active_Inactive'];
    rto = json['rto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['districT_ID'] = districTID;
    data['district'] = district;
    data['district_Name_LL'] = districtNameLL;
    data['district_Name_EN'] = districtNameEN;
    data['state'] = state;
    data['status'] = status;
    data['date_Active_Inactive'] = dateActiveInactive;
    data['rto'] = rto;
    return data;
  }
}

