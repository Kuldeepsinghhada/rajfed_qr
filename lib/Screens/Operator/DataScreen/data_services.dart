import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/dashboard_data_model.dart';
import 'package:rajfed_qr/utils/enums.dart';

class DataService {
  DataService._();

  static final DataService instance = DataService._();

  Future<APIResponse> dashboardDataList(String? startDate, String? endDate,
      {int? cropId}) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?PurchaseCenter_ID=$purchaseCenterID";
      if (cropId != null) {
        query = "$query&CropId=$cropId";
      }
     if(startDate != null){
       query = "$query&StartDate=$startDate&EndDate=$endDate";
     }
      var response = await ApiService.instance.apiCall(
          APIEndPoint.dashboardData + query, HttpRequestType.get, null);
      if (response.status) {
        var data = response.data['response']['data'];
        print(data);
        List<DashboardDataModel> dataModel = (data as List)
            .map((item) => DashboardDataModel.fromJson(item))
            .toList();
        return APIResponse(true, dataModel, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      return APIResponse(false, null, e.toString());
    }
  }
}
