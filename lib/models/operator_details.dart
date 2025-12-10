class OperatorDetails {
  int? lotId;
  int? savedBardana;
  String? farmerRegID;
  String? farmerName;
  String? regDate;
  String? purchaseCenterKendra;
  int? transctionBardana;
  int? rejectedBardana;
  int? acceptedBardana;
  int? remainingBardana;
  double? transctionQty;
  String? cropTypeEN;

  OperatorDetails(
      {this.lotId,
      this.savedBardana,
      this.farmerRegID,
      this.farmerName,
      this.regDate,
      this.purchaseCenterKendra,
      this.transctionBardana,
      this.transctionQty,
      this.cropTypeEN});

  OperatorDetails.fromJson(Map<String, dynamic> json) {
    lotId = json['lotId'];
    savedBardana = json['saved_Bardana'];
    farmerRegID = json['farmerRegID'];
    farmerName = json['farmerName'];
    regDate = json['regDate'];
    purchaseCenterKendra = json['purchaseCenter_Kendra'];
    transctionBardana = json['transction_Bardana'];
    rejectedBardana = json['rejected_Bardana'];
    acceptedBardana = json['accepted_Bardana'];
    remainingBardana = json['remaining_Bardana'];
    transctionQty = json['transction_Qty'];
    cropTypeEN = json['cropType_EN'];
  }
}
