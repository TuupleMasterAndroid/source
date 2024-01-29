class YearModel {
  late final bool status;
  late final int statusCode;
  late final String message;
  late final List<Data> data;

  YearModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  YearModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null
        ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final getData = <String, dynamic>{};
    getData['status'] = status;
    getData['statusCode'] = statusCode;
    getData['message'] = message;
    getData['data'] = data.map((e) => e.toJson()).toList();
    return getData;
  }
}

class Data {
  late final int hRYearID;
  late final String hRYearName;
  Data({
    required this.hRYearID,
    required this.hRYearName,
  });
  Data.fromJson(Map<String, dynamic> json) {
    hRYearID = json['hR_Year_ID'];
    hRYearName = json['hR_Year_Name'];
  }

  Map<String, dynamic> toJson() {
    final getData = <String, dynamic>{};
    getData['hR_Year_ID'] = hRYearID;
    getData['hR_Year_Name'] = hRYearName;
    return getData;
  }
}
