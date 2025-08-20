import 'dart:convert';
import 'dart:developer';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/APIService/shared_preference_helper.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/models/dispatch_incharge_model.dart';
import 'package:rajfed_qr/models/district_model.dart';
import 'package:rajfed_qr/models/incharge_details.dart';
import 'package:rajfed_qr/models/saved_qr_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class InchargeService {
  InchargeService._();

  static final InchargeService instance = InchargeService._();

  Future<APIResponse?> inchargeDetails(String qrCode) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();

      var query = "?QrCode=$qrCode&PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
          APIEndPoint.inchargeDetails + query, HttpRequestType.get, null);
      if (response.status) {
        var data = InchargeDetails.fromJson(response.data['response']['data']);
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

      Map<String, dynamic> body = {
        "farmerRegNo": farmerRegNo,
        "qr_code": qrCode,
        "device_info": "string",
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

  Future<APIResponse?> dispatchToWareHouse(
      List<SavedQrModel> qrCodeList) async {
    try {
      List<dynamic> list = [];
      for (var item in qrCodeList) {
        var obj = {
          "lotNo": item.lotNo,
          "farmerRegId": item.farmerRegId,
          "qrCode": item.qrCode,
          "purchaseCenterId": item.purchaseCenterId,
          "cropId": item.cropId,
          "wareHouseId": item.wareHouseId,
          "vehicleNo": item.vehicleNo
        };
        list.add(obj);
      }

      String jsonString =
          jsonEncode(qrCodeList.map((lot) => lot.toJson()).toList());
      log(jsonEncode(list));
      var response = await ApiService.instance.apiCall(
          APIEndPoint.dispatchToWareHouse, HttpRequestType.post, jsonString);
      if (response.status) {
        return APIResponse(true, null, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> rejectedInchargeList(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&PurchaseCenter_ID=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.rejectedInchargeDashboard + query,
          HttpRequestType.get,
          null);
      if (response.status) {
        List<DispatchInchargeModel> rejectedList =
            (response.data['response']['data'] as List)
                .map((item) => DispatchInchargeModel.fromJson(item))
                .toList();
        return APIResponse(true, rejectedList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> sentInchargeList(String vehicleNo) async {
    try {
      var purchaseCenterID =
          await SharedPreferenceHelper.instance.getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&PurchaseCenter_ID=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
          APIEndPoint.sentInchargeDashboard + query, HttpRequestType.get, null);
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
