class TotalDaysModel {
  bool status;
  int statusCode;
  String message;
  List<Data> data;

  TotalDaysModel(
      {required this.status,
      required this.statusCode,
      required this.message,
      required this.data});

  factory TotalDaysModel.fromJson(Map<String, dynamic> json) {
    return TotalDaysModel(
        status: json['status'],
        statusCode: json['statusCode'],
        message: json['message'],
        data: json['data'] != null
            ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
            : []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    data['data'] = this.data.map((v) => v.toJson()).toList();
    return data;
  }
}

class Data {
  int? column1;

  Data({this.column1});

  Data.fromJson(Map<String, dynamic> json) {
    column1 = json['column1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['column1'] = column1;
    return data;
  }
}
