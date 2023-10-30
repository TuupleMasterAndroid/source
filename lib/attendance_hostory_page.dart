import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance_history_image.dart';
import 'color_constant.dart';
import 'my_service/maps_sheet.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  List<Map<String, dynamic>> data = [];
  DateTime startToDayDate = DateTime.now();
  DateTime startFromDayDate = DateTime.now();
  String fromDate = '', toDate = '';
  String apiFromDate = '', apiToDate = '';
  String checkToDate = '', checkFromDate = '';
  bool isLoading = false;

  @override
  void initState() {
    fromDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    toDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    apiFromDate = DateFormat('dd/MMM/yyyy').format(DateTime.now());
    apiToDate = DateFormat('dd/MMM/yyyy').format(DateTime.now());
    checkToDate = DateFormat('dd/MMM/yyyy').format(DateTime.now());
    checkFromDate = DateFormat('dd/MMM/yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Attendance History'),
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
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // ---------- from date ----------
                      InkWell(
                        onTap: () {
                          _selectFromDate(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border:
                                  Border.all(width: 1.0, color: Colors.blue)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 15.0),
                              Column(
                                children: [
                                  Text(
                                    'From',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(fromDate,
                                      style: GoogleFonts.notoSans(fontSize: 15))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // ---------- to date ----------
                      InkWell(
                        onTap: () {
                          _selectToDate(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border:
                                  Border.all(width: 1.0, color: Colors.blue)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 15.0),
                              Column(
                                children: [
                                  Text(
                                    'To',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(toDate,
                                      style: GoogleFonts.notoSans(fontSize: 15))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // ---------- next page ----------
                      InkWell(
                        onTap: () => nextPage(),
                        child: Image.asset('assets/right_arrow.png',
                            width: 35, height: 35),
                      ),
                    ],
                  ),
                  onlyHeader(),
                  Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _fixedTable()),
                  const SizedBox(height: 12.0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void nextPage() {
    DateTime start = startFromDayDate.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    DateTime end = startToDayDate.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    if (start.compareTo(end) == 0 || start.compareTo(end) < 0) {
      _apiCall();
      setState(() => isLoading = true);
    } else {
      _infoDialog('Invalid Date', 'Please Select Proper Date Range');
    }
  }

  Widget onlyHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        //border: TableBorder.all(),
        border: const TableBorder(
            top: BorderSide(),
            left: BorderSide(),
            right: BorderSide(),
            verticalInside: BorderSide(),
            bottom: BorderSide()),
        children: [
          buildRow(['Date|Time', 'In|Out', 'Location', 'Image']),
        ],
      ),
    );
  }

  _fixedTable() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          border: TableBorder.all(),
          children: [
            //buildRow(['Date|Time', 'In|Out', 'Location', 'Image']),
            for (var item in data)
              TableRow(children: [
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        getFormatDateTime(item),
                        textAlign: TextAlign.center,
                      ),
                    )),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item['in_Out'] == 'I' ? 'In' : 'Out',
                        textAlign: TextAlign.center,
                      ),
                    )),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                        padding: const EdgeInsets.all(0),
                        child: InkWell(
                          onTap: () {
                            try {
                              double latitude = double.parse(item['lat']);
                              double longitude = double.parse(item['long']);
                              log('$latitude');
                              log('$longitude');

                              _openMap(context, latitude, longitude);
                            } catch (e) {
                              _infoDialog('Invalid Location',
                                  'Sorry Location not found');
                            }
                          },
                          child: Center(
                            child: Image.asset('assets/location_pin.png',
                                alignment: Alignment.center, height: 30),
                          ),
                        ))),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: InkWell(
                      onTap: () {
                        log(item['emp_Photo']);
                      },
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AttendanceHistoryImage(
                                          imageURL: item['emp_Photo'],
                                        )));
                          },
                          child: Image.asset('assets/profile_pin.png',
                              alignment: Alignment.center, height: 50),
                        ),
                      ),
                    ))
              ])
          ],
        ),
      ),
    );
  }

  _openMap(BuildContext context, double latitude, double longitude) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      bool? available = await MapLauncher.isMapAvailable(MapType.apple);
      if (available != null) {
        if (available) {
          try {
            await MapLauncher.showMarker(
              mapType: MapType.apple,
              coords: Coords(latitude, longitude),
              title: "Attendance Location",
              description: "Attendance Location",
              zoom: 40,
            );
          } catch (e) {
            log('apple map can not launch');
            if (context.mounted) {
              _mapNotAvailable(context, latitude, longitude);
            }
          }
        } else {
          log('not available');
          if (context.mounted) {
            _mapNotAvailable(context, latitude, longitude);
          }
        }
        log('available');
        await MapLauncher.showMarker(
          mapType: MapType.apple,
          coords: Coords(latitude, longitude),
          title: "Attendance Location",
          description: "Attendance Location",
          zoom: 40,
        );
      } else {
        log('null no map available');
        if (context.mounted) {
          _mapNotAvailable(context, latitude, longitude);
        }
      }
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool? available = await MapLauncher.isMapAvailable(MapType.google);
      if (available != null) {
        if (available) {
          try {
            await MapLauncher.showMarker(
              mapType: MapType.google,
              coords: Coords(latitude, longitude),
              title: "Attendance Location",
              description: "Attendance Location",
              zoom: 40,
            );
          } catch (e) {
            log('google can not launch');
            if (context.mounted) {
              _mapNotAvailable(context, latitude, longitude);
            }
          }
        } else {
          log('not available');
          if (context.mounted) {
            _mapNotAvailable(context, latitude, longitude);
          }
        }
      } else {
        log('null no map available');
        if (context.mounted) {
          _mapNotAvailable(context, latitude, longitude);
        }
      }
    }
  }

  _mapNotAvailable(BuildContext context, double latitude, double longitude) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber,
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19EC0404),
                spreadRadius: 2.0,
                blurRadius: 8.0,
                offset: Offset(2, 4),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.black),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Your Google Map Not available\nOpen to other!',
                    style: TextStyle(color: Colors.black)),
              ),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    MapsSheet.show(
                        context: context,
                        onMapTap: (map) {
                          map.showMarker(
                            coords: Coords(latitude, longitude),
                            title: 'Attendance Location',
                            zoom: 40,
                          );
                        });
                  },
                  child: const Text("Open"))
            ],
          )),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  TableRow buildRow(List<String> cells) {
    return TableRow(
        children: cells.map((cell) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            cell,
            style: const TextStyle(fontWeight: FontWeight.w600),
          )));
    }).toList());
  }

  _apiCall() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    String? empID = '';
    empID = sharedPreferences.getString('emp_ID');
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    Uri uri = Uri.parse(
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=Get_Emp_Attn_List&Sp_Name=SP_Common_Control');

    var body =
        '{"emp_id": "$empID", "from_date": "$apiFromDate","to_date": "$apiToDate"}';

    //print(body);
    try {
      final response = await http.post(uri, headers: headers, body: body);
      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        log('--------- success ---------');
        String s = response.body;

        Map<String, dynamic> map = Map.from(json.decode(s));
        List list = map['data'];

        data.clear();
        for (int i = 0; i < list.length; ++i) {
          data.add(Map.from(list[i]));
        }

        setState(() => isLoading = false);
      } else {
        log('--------- fail ---------');
        log(response.reasonPhrase.toString());
        setState(() => isLoading = false);
      }
    } catch (error) {
      log(error.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startFromDayDate,
        firstDate: DateTime(2022, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != startFromDayDate) {
      setState(() {
        startFromDayDate = picked;
        fromDate = DateFormat('dd-MM-yyyy').format(picked);
        apiFromDate = DateFormat('dd/MMM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startToDayDate,
        firstDate: DateTime(2022, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != startToDayDate) {
      setState(() {
        startToDayDate = picked;
        toDate = DateFormat('dd-MM-yyyy').format(picked);
        apiToDate = DateFormat('dd/MMM/yyyy').format(picked);
      });
    }
  }

  getFormatDateTime(Map<String, dynamic> map) {
    if (map.containsKey('attn_Time')) {
      String getTime = map['attn_Time'];
      String year = getTime.substring(0, 4);
      String month = getTime.substring(5, 7);
      String day = getTime.substring(8, 10);
      String hour = getTime.substring(11, 13);
      String minute = getTime.substring(14, 16);
      String second = getTime.substring(17, 19);
      DateTime dt = DateTime(int.parse(year), int.parse(month), int.parse(day),
          int.parse(hour), int.parse(minute), int.parse(second));

      String t = DateFormat('hh:mm a').format(dt);
      String d = DateFormat('dd MMM yyyy').format(dt);
      log(t);
      log(d);
      //return '$day/$month/$year\n$hour:$minute:$second';
      return '$d\n$t';
    } else {
      return '';
    }
  }

  _infoDialog(String title, String message) {
    setState(() => isLoading = false);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }
}
