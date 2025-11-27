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
      {this.purchaseCenterID,
        this.purchaseCenterKendra,
        this.purchaseCenterShakha,
        this.agencyID,
        this.farmerCapM,
        this.farmerCapG,
        this.farmerCapMoong,
        this.farmerCapGN,
        this.farmerCapUdad,
        this.farmerCapSoya,
        this.lat,
        this.long});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['purchaseCenter_ID'] = this.purchaseCenterID;
    data['purchaseCenter_Kendra'] = this.purchaseCenterKendra;
    data['purchaseCenter_Shakha'] = this.purchaseCenterShakha;
    data['agency_ID'] = this.agencyID;
    data['farmer_Cap_M'] = this.farmerCapM;
    data['farmer_Cap_G'] = this.farmerCapG;
    data['farmer_Cap_Moong'] = this.farmerCapMoong;
    data['farmer_Cap_GN'] = this.farmerCapGN;
    data['farmer_Cap_Udad'] = this.farmerCapUdad;
    data['farmer_Cap_Soya'] = this.farmerCapSoya;
    data['lat'] = this.lat;
    data['long'] = this.long;
    return data;
  }
}