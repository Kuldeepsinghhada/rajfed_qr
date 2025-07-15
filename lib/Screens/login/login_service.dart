import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/login_response.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class LoginService {
  LoginService._();

  static final LoginService instance = LoginService._();

  Future<APIResponse?> loginUser(String userName, String password) async {
    try {
      var response = await ApiService.instance.apiCall(APIEndPoint.login,
          HttpRequestType.post, {'user': userName, 'pass': password});
      if (response.status) {
        var data = LoginResponse.fromJson(response.data['response']['data']);
        if (data.token != null) {
          SharedPreferenceHelper.instance.setToken(data.token!);
          SharedPreferenceHelper.instance.setUserId(data.uid!);
          SharedPreferenceHelper.instance.setUserName(data.userName!);
          SharedPreferenceHelper.instance.setUserType(data.userType!);
          SharedPreferenceHelper.instance
              .setPurchaseCenterId(data.purchaseCenterID!);
          return APIResponse(true, data, "");
        }
        return APIResponse(false, null, "Data not parsed");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
