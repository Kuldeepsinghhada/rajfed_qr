import 'package:device_info_plus/device_info_plus.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/operator_details.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class OPHomeService {
  OPHomeService._();

  static final OPHomeService instance = OPHomeService._();

  Future<APIResponse?> operatorDetails(String farmerRegNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      //39000847
      var query =
          "?FarmerRegID=$farmerRegNo&PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
          APIEndPoint.operatorDetails + query, HttpRequestType.get, null);
      if (response.status) {
        var data = OperatorDetails.fromJson(response.data['response']['data']);
        return APIResponse(true, data, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> farmerSavedList(String farmerRegNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      var query =
          "?farmerRegNo=$farmerRegNo&PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
          APIEndPoint.farmerSavedQrCode + query, HttpRequestType.get, null);
      if (response.status) {
        List<SavedQrModel> savedQrIds = (response.data as List)
            .map((item) => SavedQrModel.fromJson(item))
            .toList();
        return APIResponse(true, savedQrIds, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> saveFarmerQrCode(
      String farmerRegNo, List<String> qrCode, String lotNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');

      Map<String, dynamic> body = {
        "farmerRegNo": farmerRegNo,
        "qr_code": qrCode,
        "device_info": androidInfo.model.toString(),
        "purchaseCenter_ID": purchaseCenterID,
        "lotNo": lotNo
      };

      var response = await ApiService.instance
          .apiCall(APIEndPoint.operatorSaveQr, HttpRequestType.post, body);
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
