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
      {this.districTID,
        this.district,
        this.districtNameLL,
        this.districtNameEN,
        this.state,
        this.status,
        this.dateActiveInactive,
        this.rto});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['districT_ID'] = this.districTID;
    data['district'] = this.district;
    data['district_Name_LL'] = this.districtNameLL;
    data['district_Name_EN'] = this.districtNameEN;
    data['state'] = this.state;
    data['status'] = this.status;
    data['date_Active_Inactive'] = this.dateActiveInactive;
    data['rto'] = this.rto;
    return data;
  }
}

