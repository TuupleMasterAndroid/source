class LeaveStatusModel {
  bool status;
  int statusCode;
  String message;
  List<LeaveData>? data;

  LeaveStatusModel(
      {required this.status,
      required this.statusCode,
      required this.message,
      required this.data});

  factory LeaveStatusModel.fromJson(Map<String, dynamic> json) {
    return LeaveStatusModel(
        status: json['status'],
        statusCode: json['statusCode'],
        message: json['message'],
        data: json['data'] != null
            ? List.from(json['data']).map((e) => LeaveData.fromJson(e)).toList()
            : null);
  }
}

class LeaveData {
  String leaveType;
  String applicationDateRange;
  double noOfDaysApply;
  String remarks;
  String status;

  LeaveData(
      {required this.leaveType,
      required this.applicationDateRange,
      required this.noOfDaysApply,
      required this.remarks,
      required this.status});

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
        leaveType: json['leavE_TYPE'],
        applicationDateRange: json['application_Date_range'],
        noOfDaysApply: json['no_Of_Days_Apply'],
        remarks: json['remarks'],
        status: json['status']);
  }
}
