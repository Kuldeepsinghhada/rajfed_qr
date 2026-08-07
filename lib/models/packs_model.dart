class PacksModel {
  int? wareHouseId;
  String? wareHouseName;
  String? districTCODE;
  String? lat;
  String? long;
  double? capacity;
  String? constructionYear;
  String? ownerName;
  String? warehouseCondtion;
  int? extraGodam;
  String? blocKENG;
  String? chairmanName; // Adhyax ka Name
  String? inchargeName; // Vyavasthapak ka name
  String? regular; // "Y" or "N" (Regular vs Additional Charge)
  String? coInchargeName; // Sah Vyavasthapak ka name
  String? mobileNo; // Vyavasthapak Mobile Number
  String? ePacs; // "Y" or "N"
  String? pmksk; // "Y" or "N"
  String? chc; // "Y" or "N"
  String? sheeAnna; // "Y" or "N"
  String? officeBuilding; // "Y" or "N"
  String? status;

  PacksModel({
    this.wareHouseId,
    this.wareHouseName,
    this.districTCODE,
    this.lat,
    this.long,
    this.capacity = 0,
    this.constructionYear = "",
    this.ownerName = "",
    this.warehouseCondtion = "",
    this.extraGodam = 0,
    this.blocKENG,
    this.chairmanName,
    this.inchargeName,
    this.regular = "Y",
    this.coInchargeName,
    this.mobileNo,
    this.ePacs = "N",
    this.pmksk = "N",
    this.chc = "N",
    this.sheeAnna = "N",
    this.officeBuilding = "N",
    this.status = "Pending",
  });

  bool get isSubmitted {
    if (status != null && status!.isNotEmpty) {
      final st = status!.toLowerCase().trim();
      if (st == 'updated' ||
          st == 'submitted' ||
          st == 'a' ||
          st == 'active' ||
          st == '1' ||
          st == 's') {
        return true;
      }
      if (st == 'pending' || st == '0') {
        return false;
      }
    }
    if (chairmanName != null && chairmanName!.trim().isNotEmpty) return true;
    if (inchargeName != null && inchargeName!.trim().isNotEmpty) return true;
    if (mobileNo != null && mobileNo!.trim().isNotEmpty) return true;
    if (lat != null &&
        lat!.trim().isNotEmpty &&
        lat!.trim() != '0' &&
        lat!.trim() != '0.0') {
      return true;
    }
    return false;
  }

  factory PacksModel.fromJson(Map<String, dynamic> json) {
    String parseYesNo(dynamic val) {
      if (val == null) return "N";
      final str = val.toString().trim().toUpperCase();
      if (str == 'Y' || str == 'YES' || str == 'TRUE' || str == '1') {
        return "Y";
      }
      return "N";
    }

    dynamic whId = json['wareHouseId'] ??
        json['warehouseId'] ??
        json['pacsId'] ??
        json['pacs_id'] ??
        json['wareHouse_ID'] ??
        json['districT_ID'] ??
        json['district_id'] ??
        json['id'];
    int? parsedWhId;
    if (whId is int) {
      parsedWhId = whId;
    } else if (whId != null) {
      parsedWhId = int.tryParse(whId.toString());
    }

    String? name = (json['wareHouseName'] ??
            json['packsName'] ??
            json['pacsName'] ??
            json['pacs_name'] ??
            json['wareHouse_Name'] ??
            json['societyName'] ??
            json['society_name'] ??
            json['district_Name_EN'] ??
            json['district_Name_LL'] ??
            json['name'])
        ?.toString();

    String? dCode = (json['districT_CODE'] ??
            json['districtCode'] ??
            json['district'] ??
            json['districT_ID'])
        ?.toString();

    dynamic cap = json['capacity'];
    double? parsedCap;
    if (cap is double) {
      parsedCap = cap;
    } else if (cap is int) {
      parsedCap = cap.toDouble();
    } else if (cap != null) {
      parsedCap = double.tryParse(cap.toString());
    }

    dynamic eg = json['extraGodam'];
    int? parsedEg;
    if (eg is int) {
      parsedEg = eg;
    } else if (eg != null) {
      parsedEg = int.tryParse(eg.toString());
    }

    return PacksModel(
      wareHouseId: parsedWhId,
      wareHouseName: name,
      districTCODE: dCode,
      lat: json['lat']?.toString(),
      long: json['long']?.toString(),
      capacity: parsedCap ?? 0.0,
      constructionYear: (json['constructionYear'] ?? json['construction_year'])?.toString() ?? "",
      ownerName: (json['ownerName'] ?? json['owner_name'])?.toString() ?? "",
      warehouseCondtion: (json['warehouseCondtion'] ?? json['warehouse_condition'])?.toString() ?? "",
      extraGodam: parsedEg ?? 0,
      blocKENG: (json['blocK_ENG'] ?? json['blockName'] ?? json['blocKENG'] ?? json['block_name'])?.toString(),
      chairmanName: (json['chairmanName'] ?? json['adhyaxName'] ?? json['adhyax_name'])?.toString(),
      inchargeName: (json['inchargeName'] ?? json['vyavasthapakName'] ?? json['vyavasthapak_name'])?.toString(),
      regular: (json['regular'] == 'N' || json['regular'] == 'No') ? 'N' : 'Y',
      coInchargeName: (json['coInchargeName'] ?? json['sahVyavasthapakName'] ?? json['sah_vyavasthapak_name'])?.toString(),
      mobileNo: (json['mobileNo'] ?? json['vyavasthapakMobile'] ?? json['mobile_no'])?.toString(),
      ePacs: parseYesNo(json['ePacs'] ?? json['ePacks']),
      pmksk: parseYesNo(json['pmksk'] ?? json['ksk']),
      chc: parseYesNo(json['chc']),
      sheeAnna: parseYesNo(json['sheeAnna'] ?? json['shreeAnna']),
      officeBuilding: parseYesNo(json['officeBuilding']),
      status: json['status']?.toString() ?? "Pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wareHouseId': wareHouseId,
      'wareHouseName': wareHouseName ?? "",
      'districT_CODE': districTCODE ?? "",
      'lat': lat ?? "",
      'long': long ?? "",
      'capacity': capacity ?? 0,
      'constructionYear': constructionYear ?? "",
      'ownerName': ownerName ?? "",
      'warehouseCondtion': warehouseCondtion ?? "",
      'extraGodam': extraGodam ?? 0,
      'blocK_ENG': blocKENG ?? "",
      'chairmanName': chairmanName ?? "",
      'inchargeName': inchargeName ?? "",
      'regular': regular ?? "Y",
      'coInchargeName': coInchargeName ?? "",
      'mobileNo': mobileNo ?? "",
      'ePacs': ePacs ?? "N",
      'pmksk': pmksk ?? "N",
      'chc': chc ?? "N",
      'sheeAnna': sheeAnna ?? "N",
      'officeBuilding': officeBuilding ?? "N",
    };
  }
}
