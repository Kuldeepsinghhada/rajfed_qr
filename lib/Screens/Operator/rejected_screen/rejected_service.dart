import 'package:fluttertoast/fluttertoast.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/rejected_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class RejectedService {
  RejectedService._();

  static final RejectedService instance = RejectedService._();

  Future<APIResponse?> operatorRejectedList() async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      var query = "?PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
          APIEndPoint.operatorRejected + query, HttpRequestType.get, null);
      if (response.status) {
        List<RejectedModel> rejectedItems = (response.data['response']['data'] as List)
            .map((item) => RejectedModel.fromJson(item))
            .toList();
        return APIResponse(true, rejectedItems, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
