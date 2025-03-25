import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class ChangePasswordService {
  ChangePasswordService._();

  static final ChangePasswordService instance = ChangePasswordService._();

  Future<APIResponse?> changePassword(
      String oldPassword, String newPassword) async {
    try {
      var userName = await SharedPreferenceHelper.instance.getUserName();
      var response = await ApiService.instance.apiCall(
          APIEndPoint.changePassword,
          HttpRequestType.post,
          {'user': userName, 'pass': oldPassword, 'newpass': newPassword});
      if (response.status) {
        return APIResponse(true, null, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
