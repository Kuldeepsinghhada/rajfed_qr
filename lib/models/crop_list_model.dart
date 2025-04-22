

class CropModel {
  int? cropID;
  String? cropDescEN;
  int? cropIsAcrive;

  CropModel({this.cropID, this.cropDescEN, this.cropIsAcrive});

  CropModel.fromJson(Map<String, dynamic> json) {
    cropID = json['crop_ID'];
    cropDescEN = json['crop_descEN'];
    cropIsAcrive = json['crop_IsAcrive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['crop_ID'] = this.cropID;
    data['crop_descEN'] = this.cropDescEN;
    data['crop_IsAcrive'] = this.cropIsAcrive;
    return data;
  }
}