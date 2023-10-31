import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'color_constant.dart';

class NoDataPage extends StatefulWidget {
  const NoDataPage({super.key, required this.pageTitle, required this.type});
  final String pageTitle;
  final int type;
  @override
  State<NoDataPage> createState() => _NoDataPageState();
}

class _NoDataPageState extends State<NoDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.pageTitle),
          backgroundColor: ColorConstant.darkColor,
          elevation: 0.0),
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ColorConstant.lightColor.withOpacity(0.5),
            ),
            child: FutureBuilder(
              future: getAPIData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_download_off,
                          color: Colors.black12,
                          size: 80,
                        ),
                        Text(snapshot.error.toString())
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text('')]);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )
        ],
      )),
    );
  }

  getAPIData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empId = prefs.getString('emp_ID');
    if (empId == null) return 'error';
    String typeValue = 'Get_Application';
    if (widget.type == 1) typeValue = 'Get_Application';
    if (widget.type == 2) typeValue = 'Get_Payslip';
    if (widget.type == 3) typeValue = 'Get_Leave';
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    String uri =
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=$typeValue&Sp_Name=SP_Common_Control';
    var body = '{"emp_id": "$empId"}';

    final response =
        await http.post(Uri.parse(uri), headers: headers, body: body);
    if (response.statusCode == 200) {
      String s = response.body;

      Map<String, dynamic> map = json.decode(s);
      String data = 'Sorry no data';
      if (map.containsKey('data')) {
        List list = map['data'];
        Map<String, dynamic> mp = list[0];

        if (mp.containsKey('rem')) {
          data = mp['rem'];
        } else {
          data = 'Sorry no data';
        }
      } else {
        data = 'Sorry no data';
      }
      _infoDialog('title', data);
      return data;
    } else {
      return 'error';
    }
  }

  _infoDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }
}
