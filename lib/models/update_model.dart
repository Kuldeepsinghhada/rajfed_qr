class UpdateModel {
  int? id;
  String? listName;
  String? message;
  String? createdAt;

  UpdateModel({this.id, this.listName, this.message, this.createdAt});

  UpdateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    listName = json['listName'];
    message = json['message'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['listName'] = this.listName;
    data['message'] = this.message;
    data['createdAt'] = this.createdAt;
    return data;
  }
}