import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/farmer_details_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class FarmerService {
  FarmerService._();

  static final FarmerService instance = FarmerService._();

  Future<APIResponse?> farmerDetails(String farmerRegNo, int cropId) async {
    try {
      var query =
          "?CropID=$cropId&FarmerRegID=$farmerRegNo";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.farmerDetails + query, HttpRequestType.get, null);
      if (response.status) {
        var data = FarmerDetailsModel.fromJson(
            response.data['response']['farmerRecord']);
        return APIResponse(true, data, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
