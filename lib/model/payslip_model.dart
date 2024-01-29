class PaySlipModel {
  PaySlipModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.pagination,
  });
  late final bool status;
  late final int statusCode;
  late final String message;
  late final List<Data> data;
  late final Pagination pagination;

  PaySlipModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
    pagination = Pagination.fromJson(json['pagination']);
  }

  Map<String, dynamic> toJson() {
    final localData = <String, dynamic>{};
    localData['status'] = status;
    localData['statusCode'] = statusCode;
    localData['message'] = message;
    localData['data'] = data.map((e) => e.toJson()).toList();
    localData['pagination'] = pagination.toJson();
    return localData;
  }
}

class Data {
  Data({
    required this.month,
    required this.salaryMonth,
    required this.salarySlipLink,
  });
  late final String month;
  late final String salaryMonth;
  late final String salarySlipLink;

  Data.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    salaryMonth = json['salary_Month'];
    salarySlipLink = json['salary_slip_Link'];
  }

  Map<String, dynamic> toJson() {
    final localData = <String, dynamic>{};
    localData['month'] = month;
    localData['salary_Month'] = salaryMonth;
    localData['salary_slip_Link'] = salarySlipLink;
    return localData;
  }
}

class Pagination {
  Pagination({
    required this.loadMore,
    required this.lastRow,
    required this.total,
  });
  late final String loadMore;
  late final String lastRow;
  late final String total;

  Pagination.fromJson(Map<String, dynamic> json) {
    loadMore = json['loadMore'];
    lastRow = json['lastRow'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final localData = <String, dynamic>{};
    localData['loadMore'] = loadMore;
    localData['lastRow'] = lastRow;
    localData['total'] = total;
    return localData;
  }
}
