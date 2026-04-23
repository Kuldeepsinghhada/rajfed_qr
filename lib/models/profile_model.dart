class ProfileModel {
  int? purchaseCenterID;
  String? purchaseCenterKendra;
  String? purchaseCenterShakha;
  int? agencyID;
  int? farmerCapM;
  int? farmerCapG;
  int? farmerCapMoong;
  int? farmerCapGN;
  int? farmerCapUdad;
  int? farmerCapSoya;
  String? lat;
  String? long;

  ProfileModel(
      {purchaseCenterID,
        purchaseCenterKendra,
        purchaseCenterShakha,
        agencyID,
        farmerCapM,
        farmerCapG,
        farmerCapMoong,
        farmerCapGN,
        farmerCapUdad,
        farmerCapSoya,
        lat,
        long});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    purchaseCenterID = json['purchaseCenter_ID'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
    purchaseCenterShakha = json['purchaseCenter_Shakha'];
    agencyID = json['agency_ID'];
    farmerCapM = json['farmer_Cap_M'];
    farmerCapG = json['farmer_Cap_G'];
    farmerCapMoong = json['farmer_Cap_Moong'];
    farmerCapGN = json['farmer_Cap_GN'];
    farmerCapUdad = json['farmer_Cap_Udad'];
    farmerCapSoya = json['farmer_Cap_Soya'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['purchaseCenter_ID'] = purchaseCenterID;
    data['purchaseCenter_Kendra'] = purchaseCenterKendra;
    data['purchaseCenter_Shakha'] = purchaseCenterShakha;
    data['agency_ID'] = agencyID;
    data['farmer_Cap_M'] = farmerCapM;
    data['farmer_Cap_G'] = farmerCapG;
    data['farmer_Cap_Moong'] = farmerCapMoong;
    data['farmer_Cap_GN'] = farmerCapGN;
    data['farmer_Cap_Udad'] = farmerCapUdad;
    data['farmer_Cap_Soya'] = farmerCapSoya;
    data['lat'] = lat;
    data['long'] = long;
    return data;
  }
}