class BlockModel {
  int? blocKID;
  String? blocKENG;

  BlockModel({this.blocKID, this.blocKENG});

  BlockModel.fromJson(Map<String, dynamic> json) {
    // Some backend responses send numeric IDs as strings. Handle both types safely.
    var idValue = json['blocK_ID'];
    if (idValue is int) {
      blocKID = idValue;
    } else if (idValue is String) {
      blocKID = int.tryParse(idValue);
    } else {
      blocKID = null;
    }
    // blocK_ENG may sometimes be sent under slightly different keys; handle nulls safely
    blocKENG = json['blocK_ENG'] ?? json['blocK_ENG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['blocK_ID'] = blocKID;
    data['blocK_ENG'] = blocKENG;
    return data;
  }
}
