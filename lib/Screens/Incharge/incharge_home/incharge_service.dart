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
import 'package:rajfed_qr/models/vehicle_model.dart';
import 'package:rajfed_qr/models/warehouse_model.dart';
import 'package:rajfed_qr/models/block_model.dart';
import 'package:rajfed_qr/utils/enums.dart';
import 'package:rajfed_qr/utils/toast_formatter.dart';

class InchargeService {
  InchargeService._();

  static final InchargeService instance = InchargeService._();

  Future<APIResponse?> inchargeDetails(String qrCode) async {
    try {
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();

      var query = "?QrCode=$qrCode&PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
        APIEndPoint.inchargeDetails + query,
        HttpRequestType.get,
        null,
      );
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
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();

      var query =
          "?farmerRegNo=$farmerRegNo&PurchaseCenter_ID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
        APIEndPoint.farmerSavedQrCode + query,
        HttpRequestType.get,
        null,
      );
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
    String farmerRegNo,
    List<String> qrCode,
    String lotNo,
  ) async {
    try {
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();

      Map<String, dynamic> body = {
        "farmerRegNo": farmerRegNo,
        "qr_code": qrCode,
        "device_info": "string",
        "purchaseCenter_ID": purchaseCenterID,
        "lotNo": lotNo,
      };

      var response = await ApiService.instance.apiCall(
        APIEndPoint.operatorSaveQr,
        HttpRequestType.post,
        body,
      );
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
      var response = await ApiService.instance.apiCall(
        APIEndPoint.getDistrict,
        HttpRequestType.get,
        null,
      );
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

  Future<APIResponse?> getBlockMaster(
    String districtCode, {
    String? agency,
  }) async {
    try {
      var query = "?DistrictCode=$districtCode";
      if (agency != null) {
        query += "&Agency=$agency";
      }
      var response = await ApiService.instance.apiCall(
        APIEndPoint.getBlockMaster + query,
        HttpRequestType.get,
        null,
      );
      if (response.status) {
        // Log raw response to help debugging inconsistent payloads
        log('getBlockMaster raw response: ${response.data}');

        try {
          var listData = response.data['response']?['data'];
          // fallback if response shape is different
          listData ??= response.data['data'];

          if (listData is List) {
            // Parse raw list into BlockModel list
            List<BlockModel> rawList = listData
                .map((item) => BlockModel.fromJson(item))
                .toList();

            // Deduplicate by blocK_ID (prefer first occurrence) and also
            // deduplicate name-only entries (where blocK_ID is null) by name.
            final Map<int, BlockModel> idMap = {};
            final Map<String, BlockModel> nameMapForNullIds = {};

            for (var b in rawList) {
              // Skip entries with empty or null names (blocK_ENG == "")
              final String nameNormalized = (b.blocKENG ?? '').trim();
              if (nameNormalized.isEmpty) continue;
              if (b.blocKID != null) {
                idMap.putIfAbsent(b.blocKID!, () => b);
              } else {
                final nameKey = nameNormalized.toLowerCase();
                nameMapForNullIds.putIfAbsent(nameKey, () => b);
              }
            }

            // Combine lists and sort alphabetically by blocKENG
            List<BlockModel> finalList = [];
            finalList.addAll(idMap.values);
            finalList.addAll(nameMapForNullIds.values);
            finalList.sort(
              (a, b) => (a.blocKENG ?? '').toLowerCase().compareTo(
                (b.blocKENG ?? '').toLowerCase(),
              ),
            );

            return APIResponse(true, finalList, "");
          } else {
            // Unexpected payload
            log(
              'getBlockMaster: expected list but got ${listData.runtimeType}',
            );
            return APIResponse(false, null, 'Invalid block master payload');
          }
        } catch (e, st) {
          log('Error parsing BlockMaster response: $e\n$st');
          return APIResponse(
            false,
            null,
            'Failed to parse block master response',
          );
        }
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
      var response = await ApiService.instance.apiCall(
        APIEndPoint.getWareHouse + query,
        HttpRequestType.get,
        null,
      );
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
    List<SavedQrModel> qrCodeList,
  ) async {
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
          "vehicleNo": item.vehicleNo,
        };
        list.add(obj);
      }

      String jsonString = jsonEncode(
        qrCodeList.map((lot) => lot.toJson()).toList(),
      );
      log(jsonEncode(list));
      var response = await ApiService.instance.apiCall(
        APIEndPoint.dispatchToWareHouse,
        HttpRequestType.post,
        jsonString,
      );
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
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&PurchaseCenter_ID=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
        APIEndPoint.rejectedInchargeDashboard + query,
        HttpRequestType.get,
        null,
      );
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
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();
      var query = "?VehicleNo=$vehicleNo&PurchaseCenter_ID=$purchaseCenterID";
      var response = await ApiService.instance.apiCall(
        APIEndPoint.sentInchargeDashboard + query,
        HttpRequestType.get,
        null,
      );
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

  Future<APIResponse?> getVehicleDetail() async {
    try {
      var purchaseCenterID = await SharedPreferenceHelper.instance
          .getPurchaseCenterId();

      var query = "?PurchaseCenterID=$purchaseCenterID";

      var response = await ApiService.instance.apiCall(
        APIEndPoint.vehicleDetails + query,
        HttpRequestType.get,
        null,
      );
      if (response.status) {
        List<VehicleModel> vehicleList =
            (response.data['response']['data'] as List)
                .map((item) => VehicleModel.fromJson(item))
                .toList();
        return APIResponse(true, vehicleList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> updateWarehouseMaster(Map<String, dynamic> body) async {
    try {
      var response = await ApiService.instance.apiCall(
        APIEndPoint.updateWarehouseMaster,
        HttpRequestType.post,
        body,
      );
      return response;
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }

  Future<APIResponse?> getAllWarehouseData() async {
    try {
      var query = "?flag=ALL";
      var response = await ApiService.instance.apiCall(
        APIEndPoint.getWarehouseLatLongStatus + query,
        HttpRequestType.get,
        null,
      );
      if (response.status) {
        List<WareHouseModel> wareHouseList = (response.data['data'] as List)
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

  Future<APIResponse?> getWareHouseListUser8(
    String district, {
    String? agency,
    int? blockId,
  }) async {
    try {
      var query = "?DistrictCode=$district";
      if (agency != null) {
        query += "&Agency=$agency";
      }
      if (blockId != null) {
        query += "&BLOCK_ID=$blockId";
      }
      var response = await ApiService.instance
          .apiCall(APIEndPoint.getWareHouseNew + query, HttpRequestType.get, null);
      if (response.status) {
        // Log raw response for debugging
        log('getWareHouseListUser8 raw response: ${response.data}');
        List<WareHouseModel> wareHouseList =
            (response.data['response']['data'] as List)
                .map((item) => WareHouseModel.fromJson(item))
                .toList();
        // Log parsed ids and names to verify parsing
        log('Parsed warehouses: ' + wareHouseList.map((w) => '{id: ${w.wareHouseId}, name: ${w.wareHouseName}}').join(', '));
        return APIResponse(true, wareHouseList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      showErrorToast("Something went wrong");
      return null;
    }
  }
}
