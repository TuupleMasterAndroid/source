import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class SqlOfflineSync {
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    Map<String, dynamic> returnMap = {};
    try {
      var headers = {
        'x-functions-key':
            'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://arclightmobile.azurewebsites.net/api/Store_Attendance_File'));
      request.fields
          .addAll({'lat': '0', 'lng': '0', 'usr_id': '0', 'data_type': 'S'});
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      ));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        log('--------- success ---------');

        final responseString = await response.stream.bytesToString();

        Map<String, dynamic> map = Map.from(json.decode(responseString));

        String imageUrl = map['file_url'];
        returnMap = {'status': true, 'message': imageUrl};
        return returnMap;
      } else {
        log('--------- fail ---------');
        log('${response.reasonPhrase}');
        returnMap = {'status': false, 'message': '${response.reasonPhrase}'};
        return returnMap;
      }
    } catch (e) {
      //e.toString();
      returnMap = {'status': false, 'message': e.toString()};
      return returnMap;
    }
  }

  Future<Map<String, dynamic>> sendAttendance(String imageUrl, String empID,
      String attendanceTime, String inOut, String lat, String long) async {
    Map<String, dynamic> attendanceMap = {};
    try {
      var headers = {
        'x-functions-key':
            'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
      };

      Uri uri = Uri.parse(
          'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=Save_Attn_Self_Offline&Sp_Name=SP_Common_Control');

      var body =
          '{"emp_id": "$empID", "in_out": "$inOut", "lat": "$lat", "long": "$long", "emp_photo": "$imageUrl", "app_capture_time": "$attendanceTime"}';

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        log('--------- success ---------');
        String s = response.body;

        Map<String, dynamic> map = Map.from(json.decode(s));
        attendanceMap = {'status': true, 'message': 'success'};
        return attendanceMap;
      } else {
        log('--------- fail ---------');
        log('${response.reasonPhrase}');
        attendanceMap = {
          'status': false,
          'message': '${response.reasonPhrase}'
        };
        return attendanceMap;
      }
    } catch (e) {
      attendanceMap = {'status': false, 'message': e.toString()};
      return attendanceMap;
    }
  }

  Future deleteFile(String imageName) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      String dumpDir = Directory('${appDocDir.path}/dump/').path;
      String filePath = dumpDir + imageName;
      log(filePath);
      await File(filePath).delete();
      log('done');
    } catch (fError) {
      log(fError.toString());
    }
  }
}
