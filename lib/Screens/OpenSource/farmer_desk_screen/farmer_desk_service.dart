import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/update_model.dart';
import 'package:rajfed_qr/utils/enums.dart';

class FarmerDeskService {
  FarmerDeskService._();

  static final FarmerDeskService instance = FarmerDeskService._();

  Future<APIResponse> getLatestNews() async {
    try {
      var response = await ApiService.instance
          .apiCall(APIEndPoint.getUpdates, HttpRequestType.get, null);
      if (response.status) {
        var data = response.data['updates'] as List;
        List<UpdateModel> dataList =
        data.map((item) => UpdateModel.fromJson(item)).toList();
        return APIResponse(true, dataList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      return APIResponse(false, null, e.toString());
    }
  }
}
