class DashboardDataModel {
  double? totalRegisteredFarmers;
  double? totalDateAllotedFarmers;
  double? purchaseTransactionsFarmers;
  double? purchaseBardana;
  double? wrdatAMT;
  double? qRGeneratedFarmers;
  double? dispatchedFarmers;
  double? paymentDoneFarmers;

  DashboardDataModel(
      {this.totalRegisteredFarmers,
      this.totalDateAllotedFarmers,
      this.purchaseTransactionsFarmers,
      this.purchaseBardana,
      this.wrdatAMT,
      this.qRGeneratedFarmers,
      this.dispatchedFarmers,
      this.paymentDoneFarmers});

  DashboardDataModel.fromJson(Map<String, dynamic> json) {
    totalRegisteredFarmers = json['total_Registered_Farmers'];
    totalDateAllotedFarmers = json['total_DateAlloted_Farmers'];
    purchaseTransactionsFarmers = json['purchase_Transactions_Farmers'];
    purchaseBardana = json['purchase_Bardana'];
    wrdatAMT = json['wrdatA_MT'];
    qRGeneratedFarmers = json['qR_Generated_Farmers'];
    dispatchedFarmers = json['dispatched_Farmers'];
    paymentDoneFarmers = json['payment_Done_Farmers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_Registered_Farmers'] = totalRegisteredFarmers;
    data['total_DateAlloted_Farmers'] = totalDateAllotedFarmers;
    data['purchase_Transactions_Farmers'] = purchaseTransactionsFarmers;
    data['purchase_Bardana'] = purchaseBardana;
    data['wrdatA_MT'] = wrdatAMT;
    data['qR_Generated_Farmers'] = qRGeneratedFarmers;
    data['dispatched_Farmers'] = dispatchedFarmers;
    data['payment_Done_Farmers'] = paymentDoneFarmers;
    return data;
  }
}
