class CropModel {
  int? cropID;
  String? cropDescEN;
  int? cropIsAcrive;
  int? rM_Rate;
  int? target;
  CropModel({this.cropID, this.cropDescEN, this.cropIsAcrive});

  CropModel.fromJson(Map<String, dynamic> json) {
    cropID = json['crop_ID'];
    cropDescEN = json['crop_descEN'];
    cropIsAcrive = json['crop_IsAcrive'];
    rM_Rate = json['rM_Rate'];
    target = json['target'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['crop_ID'] = cropID;
    data['crop_descEN'] = cropDescEN;
    data['crop_IsAcrive'] = cropIsAcrive;
    data['rM_Rate'] = rM_Rate;
    data['target'] = target;
    return data;
  }
}
