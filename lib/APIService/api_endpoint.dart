class APIEndPoint {
  static String login = 'login';
  static String logout = 'logout';
  static String operatorDetails = 'OperatorDetails';
  static String changePassword = "ChangePassword";
  static String operatorRejected = "OperatorRejected";
  static String operatorSaveQr = "OperatorSaveQr";
  static String farmerSavedQrCode = "QrCodeByFarmerRegNo";

  // Incharge Endpoint
  static String inchargeDetails = "InchargeDetails";
  static String getDistrict = "DistrictMaster";
  static String getWareHouse = "WarehouseMaster";
  static String dispatchToWareHouse = "DispatchedToWareHouse";
  static String rejectedInchargeDashboard = "Rejected_Incharge";
  static String sentInchargeDashboard = "Sent_Incharge_Dashboard";

  // WareHouse Detail

  static String wareHouseDetails = "WarehouseDetailsQrCodeWise";
  static String wareHouseAccepted = "WarehouseAcceptedRecords";
  static String wareHouseRejected = "WareHouseRejectedRecords";
  static String rejectedInWareHousePartially = "RejectedInWareHousePartially";
  static String receivedInWareHousePartially = "ReceivedInWareHousePartially";
}