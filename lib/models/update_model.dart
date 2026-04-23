class UpdateModel {
  int? id;
  String? listName;
  String? message;
  String? createdAt;

  UpdateModel({id, listName, message, createdAt});

  UpdateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    listName = json['listName'];
    message = json['message'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['listName'] = listName;
    data['message'] = message;
    data['createdAt'] = createdAt;
    return data;
  }
}