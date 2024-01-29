import 'dart:convert';

import 'package:archlighthr/model/payslip_model.dart';
import 'package:archlighthr/my_constant/api_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'color_constant.dart';

class PayslipListPage extends StatefulWidget {
  const PayslipListPage({super.key, required this.employeeName});
  final String employeeName;
  @override
  State<PayslipListPage> createState() => _PayslipListPageState();
}

class _PayslipListPageState extends State<PayslipListPage> {
  List<Data> paySlipData = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.pageBackGround,
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // <-- SEE HERE
          ),
          title: const Text('Payslip', style: TextStyle(color: Colors.white)),
          backgroundColor: ColorConstant.darkColor,
          elevation: 0.0),
      body: SafeArea(
        child: Column(
          children: [
            topPart(),
            const SizedBox(height: 8.0),
            FutureBuilder(
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
                  return dataPart();
                }
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget topPart() {
    return Container(
      decoration: const BoxDecoration(color: ColorConstant.pageBackGround),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/pay_icon.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text(widget.employeeName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.firaSansCondensed(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600)))
          ],
        ),
      ),
    );
  }

  Widget dataPart() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: ColorConstant.pageBackGround),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: paySlipData.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0),
                      color: index % 2 == 0
                          ? const Color(0xFFB6CFE5)
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/date_icon.png',
                      width: 30,
                      height: 30,
                    ),
                    title: Text(
                      paySlipData[index].salaryMonth,
                      style: const TextStyle(fontSize: 20),
                    ),
                    trailing: Image.asset(
                      'assets/g001.png',
                      width: 25,
                      height: 25,
                    ),
                    onTap: () {
                      openWebPage(index);
                    },
                  ),
                ));
          },
        ),
      ),
    );
  }

  getAPIData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) return 'error1';

    var body = '{"emp_code": "$empCode"}';
    String serverURL =
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func_clinet_db?Report_Name=Get_Payslip&Sp_Name=SP_Salary_Slip&CON=XL24';
    try {
      final response = await http.post(Uri.parse(serverURL),
          headers: APIData().getAPIHeader(), body: body);
      if (response.statusCode == 200) {
        PaySlipModel paySlipModel =
            PaySlipModel.fromJson(json.decode(response.body));
        paySlipData = paySlipModel.data;

        return paySlipData;
      } else {
        debugPrint(response.statusCode.toString());
        return 'error2';
      }
    } catch (e) {
      debugPrint('API try catch ');
      debugPrint(e.toString());
      return [];
    }
  }

  openWebPage(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return false;
    }

    /*String uri =
        'http://johhr.compacct.cloud/Report/Crystal_Files/CRM/joh_Form/Joh_Salary_slip.aspx?Emp_ID=28&SLDate=01/Dec/2023';*/
    String uri = paySlipData[index].salarySlipLink;

    uri = paySlipData[index].salarySlipLink;
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      throw 'Could not launch Uri';
    }
  }
}
