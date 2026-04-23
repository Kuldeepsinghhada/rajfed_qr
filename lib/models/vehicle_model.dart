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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ownerName'] = ownerName;
    data['mobileNo'] = mobileNo;
    data['panNo'] = panNo;
    data['address'] = address;
    data['tinNo'] = tinNo;
    data['truckNo'] = truckNo;
    return data;
  }
}