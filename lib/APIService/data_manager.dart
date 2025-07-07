
import 'package:rajfed_qr/models/crop_list_model.dart';

class DataManager {
  DataManager._();
  static final DataManager instance = DataManager._();

  List<CropModel> cropList = [];
  List<String> cropStringList = [];
}