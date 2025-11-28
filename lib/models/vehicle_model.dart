class VehicleModel {
  String? ownerName;
  String? mobileNo;
  String? panNo;
  String? address;
  String? tinNo;
  String? truckNo;

  VehicleModel(
      {this.ownerName,
        this.mobileNo,
        this.panNo,
        this.address,
        this.tinNo,
        this.truckNo});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    ownerName = json['ownerName'];
    mobileNo = json['mobileNo'];
    panNo = json['panNo'];
    address = json['address'];
    tinNo = json['tinNo'];
    truckNo = json['truckNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ownerName'] = this.ownerName;
    data['mobileNo'] = this.mobileNo;
    data['panNo'] = this.panNo;
    data['address'] = this.address;
    data['tinNo'] = this.tinNo;
    data['truckNo'] = this.truckNo;
    return data;
  }
}