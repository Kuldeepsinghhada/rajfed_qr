import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class WarehouseService {
  WarehouseService._();

  static final WarehouseService instance = WarehouseService._();

  Future<APIResponse?> getListByVehicleNo(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      var query = "?VehicleNo=$vehicleNo&WareHouseId=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
          APIEndPoint.getItemByVehicleNo + query, HttpRequestType.get, null);
      if (response.status) {
        List<DispatchInchargeModel> wareHouseList =
            (response.data['response']['data'] as List)
                .map((item) => DispatchInchargeModel.fromJson(item))
                .toList();
        return APIResponse(true, wareHouseList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> getDistrictList() async {
    try {
      var response = await ApiService.instance
          .apiCall(APIEndPoint.getDistrict, HttpRequestType.get, null);
      if (response.status) {
        List<DistrictModel> districtList =
            (response.data['response']['data'] as List)
                .map((item) => DistrictModel.fromJson(item))
                .toList();
        return APIResponse(true, districtList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> getWareHouseList(String district) async {
    try {
      var query = "?DistrictCode=$district";
      var response = await ApiService.instance
          .apiCall(APIEndPoint.getWareHouse + query, HttpRequestType.get, null);
      if (response.status) {
        List<WareHouseModel> wareHouseList =
            (response.data['response']['data'] as List)
                .map((item) => WareHouseModel.fromJson(item))
                .toList();
        return APIResponse(true, wareHouseList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> rejectedWareHouseList(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&warehouseId=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.wareHouseRejected + query, HttpRequestType.get, null);
      if (response.status) {
        List<DispatchInchargeModel> wareHouseList =
            (response.data['response']['data'] as List)
                .map((item) => DispatchInchargeModel.fromJson(item))
                .toList();
        return APIResponse(true, wareHouseList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> acceptedWarehouseList(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&warehouseId=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.wareHouseAccepted + query, HttpRequestType.get, null);
      if (response.status) {
        List<DispatchInchargeModel> dispatchList =
            (response.data['response']['data'] as List)
                .map((item) => DispatchInchargeModel.fromJson(item))
                .toList();
        return APIResponse(true, dispatchList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> acceptQrCodeByWarehouse(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&warehouseId=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.wareHouseAccepted + query, HttpRequestType.get, null);
      if (response.status) {
        List<DispatchInchargeModel> dispatchList =
            (response.data['response']['data'] as List)
                .map((item) => DispatchInchargeModel.fromJson(item))
                .toList();
        return APIResponse(true, dispatchList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
