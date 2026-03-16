import 'dart:convert';

class Crop {
  int? aid;
  int? cropId;
  String? cropHin;
  double? area;
  double? irrigatedArea;
  double? nonIrrigatedArea;
  String? irrigationStatus;

  Crop({
    this.aid,
    this.cropId,
    this.cropHin,
    this.area,
    this.irrigatedArea,
    this.nonIrrigatedArea,
    this.irrigationStatus,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        aid: json['AID'] is int ? json['AID'] : int.tryParse('${json['AID']}'),
        cropId: json['CropId'] is int
            ? json['CropId']
            : int.tryParse('${json['CropId']}'),
        cropHin: json['CROP_HIN']?.toString(),
        area: _toDouble(json['Area']),
        irrigatedArea: _toDouble(json['IrrigatedArea']),
        nonIrrigatedArea: _toDouble(json['NonIrrigatedArea']),
        irrigationStatus: json['IrrigationStatus']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'AID': aid,
        'CropId': cropId,
        'CROP_HIN': cropHin,
        'Area': area,
        'IrrigatedArea': irrigatedArea,
        'NonIrrigatedArea': nonIrrigatedArea,
        'IrrigationStatus': irrigationStatus,
      };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class LandRecord {
  int? id;
  int? districtLgCode;
  String? district;
  int? tehsilLgCode;
  String? tehsil;
  int? ilrCode;
  String? ilr;
  int? patwarCode;
  String? patwarCircle;
  int? villageCode;
  String? village;
  String? khataNo;
  String? khasraNo;
  int? year;
  String? ownerName;
  String? caste;
  String? ownerHissa;
  double? area;
  String? landClass;
  String? sourceOfIrrigation;
  double? uncultivatedArea;
  List<Crop>? crops;

  LandRecord({
    this.id,
    this.districtLgCode,
    this.district,
    this.tehsilLgCode,
    this.tehsil,
    this.ilrCode,
    this.ilr,
    this.patwarCode,
    this.patwarCircle,
    this.villageCode,
    this.village,
    this.khataNo,
    this.khasraNo,
    this.year,
    this.ownerName,
    this.caste,
    this.ownerHissa,
    this.area,
    this.landClass,
    this.sourceOfIrrigation,
    this.uncultivatedArea,
    this.crops,
  });

  factory LandRecord.fromJson(Map<String, dynamic> json) => LandRecord(
        id: json['ID'] is int ? json['ID'] : int.tryParse('${json['ID']}'),
        districtLgCode: json['DISTRICT_LG_CODE'] is int
            ? json['DISTRICT_LG_CODE']
            : int.tryParse('${json['DISTRICT_LG_CODE']}'),
        district: json['District']?.toString(),
        tehsilLgCode: json['TEHSIL_LG_CODE'] is int
            ? json['TEHSIL_LG_CODE']
            : int.tryParse('${json['TEHSIL_LG_CODE']}'),
        tehsil: json['Tehsil']?.toString(),
        ilrCode: json['ILR_CODE'] is int
            ? json['ILR_CODE']
            : int.tryParse('${json['ILR_CODE']}'),
        ilr: json['ILR']?.toString(),
        patwarCode: json['PATWAR_CODE'] is int
            ? json['PATWAR_CODE']
            : int.tryParse('${json['PATWAR_CODE']}'),
        patwarCircle: json['PatwarCircle']?.toString(),
        villageCode: json['VILLAGE_CODE'] is int
            ? json['VILLAGE_CODE']
            : int.tryParse('${json['VILLAGE_CODE']}'),
        village: json['Village']?.toString(),
        khataNo: json['KhataNo']?.toString(),
        khasraNo: json['KhasraNo']?.toString(),
        year: json['Year'] is int ? json['Year'] : int.tryParse('${json['Year']}'),
        ownerName: json['OwnerName']?.toString(),
        caste: json['Caste']?.toString(),
        ownerHissa: json['OwnerHissa']?.toString(),
        area: _toDouble(json['Area']),
        landClass: json['LandClass']?.toString(),
        sourceOfIrrigation: json['SourceOfIrrigation']?.toString(),
        uncultivatedArea: _toDouble(json['Uncultivated_Area']),
        crops: json['Crops'] != null
            ? List<Crop>.from(
                (json['Crops'] as List).map((x) => Crop.fromJson(x)))
            : <Crop>[],
      );

  Map<String, dynamic> toJson() => {
        'ID': id,
        'DISTRICT_LG_CODE': districtLgCode,
        'District': district,
        'TEHSIL_LG_CODE': tehsilLgCode,
        'Tehsil': tehsil,
        'ILR_CODE': ilrCode,
        'ILR': ilr,
        'PATWAR_CODE': patwarCode,
        'PatwarCircle': patwarCircle,
        'VILLAGE_CODE': villageCode,
        'Village': village,
        'KhataNo': khataNo,
        'KhasraNo': khasraNo,
        'Year': year,
        'OwnerName': ownerName,
        'Caste': caste,
        'OwnerHissa': ownerHissa,
        'Area': area,
        'LandClass': landClass,
        'SourceOfIrrigation': sourceOfIrrigation,
        'Uncultivated_Area': uncultivatedArea,
        'Crops': crops?.map((e) => e.toJson()).toList(),
      };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  String toString() => jsonEncode(toJson());
}

