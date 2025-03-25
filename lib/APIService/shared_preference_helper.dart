import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  var tokenKey = "token";
  var userNameKey = "username";
  var userId = "userId";
  var userType = "userType";
  var purchaseCenterIdKey = "purchaseCenterId";

  SharedPreferenceHelper._();

  static final SharedPreferenceHelper instance = SharedPreferenceHelper._();

  Future<bool?> setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var status = await preferences.setString(tokenKey, token);
    return status;
  }

  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getString(tokenKey);
    return data;
  }

  Future<bool?> setUserName(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var status = await preferences.setString(userNameKey, userName);
    return status;
  }

  Future<String?> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getString(userNameKey);
    return data;
  }

  Future<bool?> setUserId(int userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var status = await preferences.setInt(userId, userName);
    return status;
  }

  Future<int?> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getInt(userId);
    return data;
  }

  Future<bool?> setUserType(int userTypes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var status = await preferences.setInt(userType, userTypes);
    return status;
  }

  Future<int?> getUserType() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getInt(userType);
    return data;
  }

  Future<bool?> setPurchaseCenterId(int userTypes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var status = await preferences.setInt(purchaseCenterIdKey, userTypes);
    return status;
  }

  Future<int?> getPurchaseCenterId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getInt(purchaseCenterIdKey);
    return data;
  }


  Future<bool> clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    return true;
  }

}
