class LeaveApplyModel {
  late final bool status;
  late final int statusCode;
  late final String message;
  late final List<Data>? data;

  LeaveApplyModel(
      {required this.status,
      required this.statusCode,
      required this.message,
      required this.data});

  factory LeaveApplyModel.fromJson(Map<String, dynamic> json) {
    return LeaveApplyModel(
        status: json['status'],
        statusCode: json['statusCode'],
        message: json['message'],
        data: json['data'] != null
            ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
            : null);
  }
}

class Data {
  late final bool status;
  late final String msg;

  Data({
    required this.status,
    required this.msg,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(status: json['status'], msg: json['msg']);
  }
}
