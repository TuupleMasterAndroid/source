class GetBalanceModel {
  bool status;
  int statusCode;
  String message;
  List<Data> data;

  GetBalanceModel(
      {required this.status,
      required this.statusCode,
      required this.message,
      required this.data});
/*
data = json['data'] != null
        ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
        : [];
 */
  factory GetBalanceModel.fromJson(Map<String, dynamic> json) {
    return GetBalanceModel(
        status: json['status'],
        statusCode: json['statusCode'],
        message: json['message'],
        data: json['data'] != null
            ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
            : []);
  }
}

class Data {
  double balance;

  Data({required this.balance});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(balance: json['balance']);
  }
}
