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
}
