class MachineModel {
  int? id;
  String? machineName;
  String? createdDate;

  MachineModel({this.id, this.machineName, this.createdDate});

  MachineModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    machineName = json['machineName'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['machineName'] = machineName;
    data['createdDate'] = createdDate;
    return data;
  }
}
