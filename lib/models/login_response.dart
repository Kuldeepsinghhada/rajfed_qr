class LoginResponse {
  int? uid;
  String? userName;
  String? password;
  int? purchaseCenterID;
  int? userType;
  String? token;

  LoginResponse(
      {this.uid,
        this.userName,
        this.password,
        this.purchaseCenterID,
        this.userType,
        this.token});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['userName'];
    password = json['password'];
    purchaseCenterID = json['purchaseCenter_ID'];
    userType = json['userType'];
    token = json['token'];
  }
}