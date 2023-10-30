class ImageUploadModel {
  /*"file_name": "1686152271520-336.jpg",
  "file_url": "https://arclightattnstore.blob.core.windows.net/atten/1686152271520-336.jpg?sv=2018-03-28&sr=b&sig=yebY1P%2Bf2iIwkvcdSVzcOqagABJVBsJ5f4Q0v7s0x%2FI%3D&se=2028-06-07T15%3A37%3A52Z&sp=r",
  "containername": "attn",
  "storagename": "arclightattnstore",
  "attencance_validated": "yes",
  "employee_name": "Sankha Chatterjee"*/

  String file_name;
  String file_url;
  String containername;
  String storagename;
  String attencance_validated;
  String employee_name;

  ImageUploadModel(
      {required this.file_name,
      required this.file_url,
      required this.containername,
      required this.storagename,
      required this.attencance_validated,
      required this.employee_name});

  factory ImageUploadModel.fromJson(Map<String, dynamic> json) {
    return ImageUploadModel(
        file_name: json['file_name'] ?? '',
        file_url: json['file_url'] ?? '',
        containername: json['containername'] ?? '',
        storagename: json['storagename'] ?? '',
        attencance_validated: json['attencance_validated'] ?? '',
        employee_name: json['employee_name'] ?? '');
  }
}
