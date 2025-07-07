class DashboardDataModel {
  int? totalRegisteredFarmers;
  int? purchaseTransactions;
  int? qRGeneratedFarmers;
  int? dispatchedFarmers;
  int? paymentDoneFarmers;

  DashboardDataModel(
      {this.totalRegisteredFarmers,
        this.purchaseTransactions,
        this.qRGeneratedFarmers,
        this.dispatchedFarmers,
        this.paymentDoneFarmers});

  DashboardDataModel.fromJson(Map<String, dynamic> json) {
    totalRegisteredFarmers = json['total_Registered_Farmers'];
    purchaseTransactions = json['purchase_Transactions'];
    qRGeneratedFarmers = json['qR_Generated_Farmers'];
    dispatchedFarmers = json['dispatched_Farmers'];
    paymentDoneFarmers = json['payment_Done_Farmers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_Registered_Farmers'] = this.totalRegisteredFarmers;
    data['purchase_Transactions'] = this.purchaseTransactions;
    data['qR_Generated_Farmers'] = this.qRGeneratedFarmers;
    data['dispatched_Farmers'] = this.dispatchedFarmers;
    data['payment_Done_Farmers'] = this.paymentDoneFarmers;
    return data;
  }
}