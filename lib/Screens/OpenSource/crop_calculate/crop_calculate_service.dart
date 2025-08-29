import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/dashboard_data_model.dart';
import 'package:rajfed_qr/models/yield_master.dart';
import 'package:rajfed_qr/utils/enums.dart';

class CropCalculateService {
  CropCalculateService._();

  static final CropCalculateService instance = CropCalculateService._();

  Future<APIResponse> getYield(String? district, int? cropId) async {
    try {
      var query = "?District=$district&CropID=$cropId";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.getYield + query, HttpRequestType.get, null);
      if (response.status) {
        var data = response.data['response']['yieldmaster'];
        YieldMaster dataModel = YieldMaster.fromJson(data);
        return APIResponse(true, dataModel, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      return APIResponse(false, null, e.toString());
    }
  }
}
