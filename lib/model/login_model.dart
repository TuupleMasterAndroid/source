class LoginModel {
  //return_Status: True, comp_ID: YAAPTCYRKC, br_ID: Q5KKS8M695, emp_ID: 5DOM5HKN4N, emp_Code: E001, emP_Name: Sankha, mobile: 9830083322, password: s1, loginDeviceID: GF17BPFHMT
  String return_Status;
  String comp_ID;
  String br_ID;
  String emp_ID;
  String emp_Code;
  String emP_Name;
  String mobile;
  String password;
  String loginDeviceID;

  LoginModel({
    required this.return_Status,
    required this.comp_ID,
    required this.br_ID,
    required this.emp_ID,
    required this.emp_Code,
    required this.emP_Name,
    required this.mobile,
    required this.password,
    required this.loginDeviceID,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      return_Status: json['return_Status'],
      comp_ID: json['comp_ID'],
      br_ID: json['br_ID'],
      emp_ID: json['emp_ID'],
      emp_Code: json['emp_Code'],
      emP_Name: json['emP_Name'],
      mobile: json['mobile'],
      password: json['password'],
      loginDeviceID: json['loginDeviceID'],
    );
  }
}
