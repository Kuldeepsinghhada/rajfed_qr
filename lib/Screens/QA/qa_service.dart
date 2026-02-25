import 'package:rajfed_qr/models/machine_model.dart';
import 'package:rajfed_qr/APIService/api_endpoint.dart';
import 'package:rajfed_qr/APIService/api_service.dart';
import 'package:rajfed_qr/models/APIModel/api_response.dart';
import 'package:rajfed_qr/utils/enums.dart';

class QaService {
  QaService._();

  static final QaService instance = QaService._();

  Future<APIResponse?> getMachineDetails() async {
    try {
      var response = await ApiService.instance.apiCall(
          APIEndPoint.machineDetails, HttpRequestType.get, null);
      if (response.status) {
        var data = response.data;
        if (data is Map && data.containsKey('response') && data['response']['machineDetails'] != null) {
          data = data['response']['machineDetails'];
        } else if (data is Map && data.containsKey('response') && data['response']['data'] != null) {
          data = data['response']['data'];
        } else if (data is Map && data.containsKey('data')) {
          data = data['data'];
        } else if (data is Map && data.containsKey('machines')) {
          data = data['machines'];
        }

        List<MachineModel> machineList = [];
        if (data is List) {
          machineList = data.map((item) => MachineModel.fromJson(item)).toList();
        }

        return APIResponse(true, machineList, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      return null;
    }
  }

  Future<APIResponse?> uploadFarmerRemark({
    required String registrationNumber,
    required String farmerName,
    required String mobileNo,
    required String purchaseCenterID,
    required String cropID,
    required String fy,
    required String foreignMatter,
    required String type,
    required String qualityAnalystName,
    required String fileSource,
    required String imageBase64,
    required String machineName,
  }) async {
    try {
      Map<String, dynamic> body = {
        "registrationNumber": registrationNumber,
        "farmerName": farmerName,
        "mobileNo": mobileNo,
        "purchaseCenterID": purchaseCenterID,
        "cropID": cropID,
        "fy": fy,
        "foreignMatter": foreignMatter,
        "type": type,
        "qualityAnalystName": qualityAnalystName,
        "fileSource": fileSource,
        "imageBase64": imageBase64,
        "machineName": machineName,
      };

      var response = await ApiService.instance.apiCall(
          APIEndPoint.uploadFarmerRemark, HttpRequestType.post, body);
      if (response.status) {
        return APIResponse(true, response.data, "");
      }
      return APIResponse(false, null, response.error);
    } catch (e) {
      return null;
    }
  }
}
