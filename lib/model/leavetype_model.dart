class LeaveTypeModel {
  late final bool status;
  late final int statusCode;
  late final String message;
  late final List<Data> data;

  LeaveTypeModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null
        ? List.from(json['data']).map((e) => Data.fromJson(e)).toList()
        : [];
  }
}

class Data {
  late final int attenTypeID;
  late final String attenType;
  Data({
    required this.attenTypeID,
    required this.attenType,
  });

  Data.fromJson(Map<String, dynamic> json) {
    attenTypeID = json['atten_Type_ID'];
    attenType = json['atten_Type'];
  }
}
