class FarmerRemarkModel {
  int? farmerRemarkID;
  String? registrationNumber;
  String? farmerName;
  String? mobileNo;
  int? purchaseCenterID;
  int? cropID;
  int? fy;
  String? remark;
  double? foreignMatter;
  double? moisture;
  String? type;
  String? qualityAnalystName;
  String? fileSource;
  String? loginSSOID;
  String? loginIP;
  String? imageName;
  String? imagePath;
  String? createdDate;
  String? machineName;
  String? imageBase64;

  FarmerRemarkModel({
    this.farmerRemarkID,
    this.registrationNumber,
    this.farmerName,
    this.mobileNo,
    this.purchaseCenterID,
    this.cropID,
    this.fy,
    this.remark,
    this.foreignMatter,
    this.moisture,
    this.type,
    this.qualityAnalystName,
    this.fileSource,
    this.loginSSOID,
    this.loginIP,
    this.imageName,
    this.imagePath,
    this.createdDate,
    this.machineName,
    this.imageBase64
  });

  FarmerRemarkModel.fromJson(Map<String, dynamic> json) {
    farmerRemarkID = json['farmerRemarkID'];
    registrationNumber = json['registrationNumber'];
    farmerName = json['farmerName'];
    mobileNo = json['mobileNo'];
    purchaseCenterID = json['purchaseCenterID'];
    cropID = json['cropID'];
    fy = json['fy'];
    remark = json['remark'];
    foreignMatter = json['foreignMatter'];
    moisture = json['moisture'];
    type = json['type'];
    qualityAnalystName = json['qualityAnalystName'];
    fileSource = json['fileSource'];
    loginSSOID = json['loginSSOID'];
    loginIP = json['loginIP'];
    imageName = json['imageName'];
    imagePath = json['imagePath'];
    createdDate = json['createdDate'];
    machineName = json['machineName'];
    imageBase64 = json['imageBase64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['farmerRemarkID'] = farmerRemarkID;
    data['registrationNumber'] = registrationNumber;
    data['farmerName'] = farmerName;
    data['mobileNo'] = mobileNo;
    data['purchaseCenterID'] = purchaseCenterID;
    data['cropID'] = cropID;
    data['fy'] = fy;
    data['remark'] = remark;
    data['foreignMatter'] = foreignMatter;
    data['moisture'] = moisture;
    data['type'] = type;
    data['qualityAnalystName'] = qualityAnalystName;
    data['fileSource'] = fileSource;
    data['loginSSOID'] = loginSSOID;
    data['loginIP'] = loginIP;
    data['imageName'] = imageName;
    data['imagePath'] = imagePath;
    data['createdDate'] = createdDate;
    data['machineName'] = machineName;
    data['imageBase64'] = imageBase64;
    return data;
  }
}
