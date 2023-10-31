import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archlighthr/color_constant.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance_status_page.dart';
import 'my_camera.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

late DateTime serverTime;

class _AttendancePageState extends State<AttendancePage> {
  late File renamed;
  late String newPath = 'blank';
  bool isLoading = false;
  bool attendanceButton = false;

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  final ValueNotifier<bool> onCameraReady = ValueNotifier(false);
  //late DateTime serverTime;
  late String serverAttendanceStatus = 'Out';
  @override
  void initState() {
    super.initState();
  }

  _getServerTimeApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empId = prefs.getString('emp_ID');
    if (empId == null) return 'error';

    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    String uri =
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=Get_Attn_Time&Sp_Name=SP_Common_Control';
    var body = '{"emp_id": "$empId"}';

    final response =
        await http.post(Uri.parse(uri), headers: headers, body: body);
    if (response.statusCode == 200) {
      String s = response.body;

      Map<String, dynamic> map = json.decode(s);
      List list = map['data'];

      Map<String, dynamic> mp = list[0];
      //print('------------');
      //print(mp['in_Out']);
      //print(mp['attn_Time']);
      String getTime = mp['attn_Time'];
      String year = getTime.substring(0, 4);
      String month = getTime.substring(5, 7);
      String day = getTime.substring(8, 10);
      String hour = getTime.substring(11, 13);
      String minute = getTime.substring(14, 16);
      String second = getTime.substring(17, 19);
      serverAttendanceStatus = mp['in_Out'];
      serverTime = DateTime(int.parse(year), int.parse(month), int.parse(day),
          int.parse(hour), int.parse(minute), int.parse(second));
      return mp;
    } else {
      return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Employee Attendance'),
            backgroundColor: ColorConstant.darkColor,
            elevation: 0.0),
        body: SafeArea(
            child: Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            //padding: const EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
              color: ColorConstant.lightColor.withOpacity(0.5),
            ),
            child: FutureBuilder(
              future: _getServerTimeApi(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            decoration: BoxDecoration(
                              color: ColorConstant.lightColor.withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                //const SizedBox(height: 15),
                                StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1)),
                                    builder: (context, shot) {
                                      serverTime = DateTime(
                                          serverTime.year,
                                          serverTime.month,
                                          serverTime.day,
                                          serverTime.hour,
                                          serverTime.minute,
                                          serverTime.second + 1);
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 30.0),
                                          Text(
                                            DateFormat('hh:mm:ss a')
                                                .format(serverTime),
                                            style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500]),
                                          ),
                                          //const SizedBox(height: 10),
                                          Text(
                                            DateFormat('dd MMMM yyyy')
                                                .format(serverTime),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      );
                                    })
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SelfImage(
                              serverAttendanceStatus: serverAttendanceStatus),
                        )
                      ]);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )
        ])));
  }
}

class SelfImage extends StatefulWidget {
  const SelfImage({Key? key, required String serverAttendanceStatus})
      : _serverAttendanceStatus = serverAttendanceStatus,
        super(key: key);
  final String _serverAttendanceStatus;
  @override
  State<SelfImage> createState() => _SelfImageState();
}

class _SelfImageState extends State<SelfImage> {
  late File renamed;
  late String newPath = 'blank';
  bool isLoading = false;
  bool attendanceButton = false;
  bool startAPI = false;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  var _tabTextIndexSelected = 0;
  final _listTextTabToggle = ["In", "Out"];
  @override
  void initState() {
    checkGps();
    super.initState();

    if (widget._serverAttendanceStatus == 'I') {
      switchControl = false;
      _tabTextIndexSelected = 0;
      inOut = 'I';
    } else {
      switchControl = true;
      _tabTextIndexSelected = 1;
      inOut = 'O';
    }
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          log("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        /* setState(() {
          //refresh the UI
        });*/

        getLocation();
      }
    } else {
      log("GPS Service is not enabled, turn on GPS location");
      //print("GPS Service is not enabled, turn on GPS location");
      _infoDialog(
          'Attendance', 'GPS Service is not enabled, turn on GPS location');
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    //print(position.longitude); //Output: 80.24599079
    //print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    /*setState(() {
      //refresh UI
    });*/

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best, //accuracy of the location data
      distanceFilter: 1, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (kDebugMode) {
        print(position.longitude); //Output: 80.24599079
        print(position.latitude); //Output: 29.6593457
      }

      long = position.longitude.toString();
      lat = position.latitude.toString();
      if (mounted) {
        setState(() {
          //refresh UI on update
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration:
            BoxDecoration(color: ColorConstant.lightColor.withOpacity(0.5)),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _getImage(),
              const SizedBox(height: 10),
              FlutterToggleTab(
                // width in percent
                width: 45,
                borderRadius: 30,
                height: 30,
                selectedIndex: _tabTextIndexSelected,
                selectedBackgroundColors: _tabTextIndexSelected == 0
                    ? const [Colors.green, Colors.green]
                    : const [Colors.blue, Colors.blue],
                selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
                unSelectedTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                labels: _listTextTabToggle,
                selectedLabelIndex: (index) {
                  //log('------ Index $index');
                  index == 0 ? inOut = 'I' : inOut = 'O';
                  setState(() {
                    _tabTextIndexSelected = index;
                  });
                  //log('------ data ${inOut}');
                },
                isScroll: true,
              ),
              const SizedBox(height: 25.0),
              StatefulBuilder(builder: (context, setCustomState) {
                return isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60.0, vertical: 15.0),
                            backgroundColor: ColorConstant.darkColor,
                            shape: const StadiumBorder()),
                        onPressed: () {
                          log(inOut);
                          log(widget._serverAttendanceStatus);
                          log(lat);
                          log(long);
                          if (!attendanceButton) return;
                          setCustomState(() {
                            isLoading = true;
                          });

                          startAPI = true;
                          //_apiCall();
                          if (lat.isNotEmpty && long.isNotEmpty) {
                            _uploadImage();
                          } else {
                            _infoDialog('Attendance',
                                'Your GPS is OFF. Please ON your GPS');
                          }
                        },
                        child: const Text('Attendance'));
              })
            ],
          ),
        ),
      ),
    );
  }

  bool switchControl = true;
  var inOut = 'OFF';

  _getImage() {
    /*return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(width: 4.0, color: Colors.grey)),
      child: Image.file(File(newPath),
          width: 150, height: 150, fit: BoxFit.cover, errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/self.png',
          ),
        );
      }),
    );*/
    return Stack(
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(width: 4.0, color: Colors.grey)),
          child: Image.file(File(newPath),
              width: 150,
              height: 150,
              fit: BoxFit.cover, errorBuilder: (BuildContext context,
                  Object exception, StackTrace? stackTrace) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/self.png',
              ),
            );
          }),
        ),
        SizedBox(
          width: 250,
          height: 250,
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () async {
                if (startAPI) return;
                String dir = (await getTemporaryDirectory()).path;
                String mPath = path.join(dir, 'myImage.jpg');
                if (await File(mPath).exists()) {
                  await File(mPath).delete();
                }
                _imgFromCamera();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/camera.png',
                  width: 45,
                  height: 45,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _imgFromCamera() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyCamera()))
        .then((value) {
      log('---- WHEN BACK TO PREVIOUS PAGE ----');
      imageCache.clear();
      _getSaveImage();
    });
    //_saveImage();
  }

  _getSaveImage() async {
    String dir = (await getTemporaryDirectory()).path;
    String mPath = path.join(dir, 'myImage.jpg');
    if (await File(mPath).exists()) {
      log('---- file found ----');
      setState(() {
        newPath = File(mPath).path;
        attendanceButton = true;
      });
    } else {
      log('---- file not found ----');
    }
  }

  _uploadImage() async {
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
      newPath,
      contentType: MediaType('image', 'jpeg'),
    ));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      log('--------- success ---------');

      final responseString = await response.stream.bytesToString();
      //final decodeMap = json.decode(responseString);
      Map<String, dynamic> map = Map.from(json.decode(responseString));
      //print(map['file_name']);
      //print(map['file_url']);
      String imageUrl = map['file_url'];
      _apiCall(imageUrl);
    } else {
      log('--------- fail ---------');
      log('${response.reasonPhrase}');
      setState(() {
        isLoading = false;
        attendanceButton = false;
        startAPI = false;
      });
    }
  }

  _apiCall(String imageUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empID = prefs.getString('emp_ID');
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    Uri uri = Uri.parse(
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=Save_Attn_Self_Online&Sp_Name=SP_Common_Control');

    String attendanceTime = DateFormat('yyyy-MM-dd HH:mm').format(serverTime);
    var body =
        '{"emp_id": "$empID", "in_out": "$inOut", "lat": "$lat", "long": "$long", "emp_photo": "$imageUrl", "app_capture_time": "$attendanceTime"}';
    print(body);

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      log('--------- success ---------');
      String s = response.body;

      //  {
      //  "status":true,"
      //  statusCode":200,
      //  "message":"Save_Attn_Self_Online",
      //  "data":[{
      //  "return_Status":"True",
      //  "return_Message":"Attn. Data Saved"
      //  }],
      //  "pagination":{"loadMore":"0","lastRow":"1","total":"1"}}
      //print('---------------');
      Map<String, dynamic> map = Map.from(json.decode(s));
      List list = map['data'];
      Map<String, dynamic> mp = list[0];
      if (mp['return_Status'] == 'True') {
        String message = mp['return_Message'];
        setState(() {
          isLoading = false;
          attendanceButton = false;
          startAPI = false;
        });
        _showDialog('Success', message, 'Success', newPath, '');
      } else {
        String message = mp['return_Message'];
        setState(() {
          isLoading = false;
          attendanceButton = false;
          startAPI = false;
        });
        _showError('Fail', message);
      }

      /*final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String? name = sharedPreferences.getString('emP_Name');*/

      /*if (map['attencance_validated'] == 'yes') {
        String name = map['employee_name'];
        _showDialog(
            'Success', 'Employee Name: $name', name, 'Success', newPath);
      } else {
        String name = map['employee_name'];
        _showDialog2(
            'Fail', '$name Attendance can\'t submitted. Try some time later');
      }*/
    } else {
      log('--------- fail ---------');
      //print(response.reasonPhrase);
      setState(() {
        isLoading = false;
        attendanceButton = false;
        startAPI = false;
      });
    }
  }

  _showDialog(String title, String message, String name, String status,
      String imagePath) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      showCloseIcon: true,
      title: title,
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dismiss from callback $type');
        //_openStatusPage(name, status, imagePath);
        Navigator.of(context, rootNavigator: true).pop();
      },
    ).show();
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

  _showDialog2(String title, String message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      showCloseIcon: true,
      title: title,
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      },
    ).show();
  }

  _showError(String title, String message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      showCloseIcon: true,
      title: title,
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      },
    ).show();
  }

  _openStatusPage(String empName, String status, String imagePath) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AttendanceStatusPage(
                empName: empName,
                status: status,
                imagePath: imagePath))).then((value) {
      setState(() {
        newPath = 'blank';
      });
    });
  }
}

class TeamImage extends StatefulWidget {
  const TeamImage({Key? key, required String serverAttendanceStatus})
      : _serverAttendanceStatus = serverAttendanceStatus,
        super(key: key);
  final String _serverAttendanceStatus;

  @override
  State<TeamImage> createState() => _TeamImageState();
}

class _TeamImageState extends State<TeamImage> {
  late File renamed;
  late String newPath = 'blank';
  bool isLoading = false;
  bool attendanceButton = false;
  bool startAPI = false;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    super.initState();

    if (widget._serverAttendanceStatus == 'In') switchControl = false;
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          log("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      log("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //log(position.longitude); //Output: 80.24599079
    //print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration:
            BoxDecoration(color: ColorConstant.lightColor.withOpacity(0.5)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _getImage(),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  if (startAPI) return;
                  String dir = (await getTemporaryDirectory()).path;
                  String mPath = path.join(dir, 'myImage.jpg');
                  if (await File(mPath).exists()) {
                    await File(mPath).delete();
                  }
                  _imgFromCamera();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 15.0),
                    backgroundColor: ColorConstant.darkColor,
                    shape: const StadiumBorder()),
                child: const Text('Take Image')),
            const SizedBox(height: 25.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'IN',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 20.0),
              Transform.scale(
                  scale: 1.5,
                  child: Switch(
                    onChanged: toggleSwitch,
                    value: switchControl,
                    activeColor: Colors.blue,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  )),
              const SizedBox(width: 20.0),
              const Text(
                'OUT',
                style: TextStyle(fontSize: 18),
              )
            ]),
            const SizedBox(height: 25.0),
            StatefulBuilder(builder: (context, setCustomState) {
              return isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60.0, vertical: 15.0),
                          backgroundColor: ColorConstant.darkColor,
                          shape: const StadiumBorder()),
                      onPressed: () {
                        if (!attendanceButton) return;
                        setCustomState(() {
                          isLoading = true;
                        });

                        startAPI = true;
                        _apiCall();
                      },
                      child: const Text('Attendance'));
            })
          ],
        ),
      ),
    );
  }

  bool switchControl = true;
  var inOut = 'OFF';
  void toggleSwitch(bool value) {
    if (switchControl == false) {
      setState(() {
        switchControl = true;
        inOut = 'ON';
      });
      log('Switch is ON');
      // Put your code here which you want to execute on Switch ON event.
    } else {
      setState(() {
        switchControl = false;
        inOut = 'OFF';
      });
      log('Switch is OFF');
      // Put your code here which you want to execute on Switch OFF event.
    }
  }

  late StateSetter imageState;
  _getImage() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(width: 4.0, color: Colors.grey)),
      child: Image.file(File(newPath),
          width: 150, height: 150, fit: BoxFit.cover, errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/team.png',
          ),
        );
      }),
    );
  }

  _imgFromCamera() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyCamera()))
        .then((value) {
      log('------------- WHEN BACK TO PREVIOUS PAGE');
      imageCache.clear();
      _getSaveImage();
    });
    //_saveImage();
  }

  _getSaveImage() async {
    String dir = (await getTemporaryDirectory()).path;
    String mPath = path.join(dir, 'myImage.jpg');
    if (await File(mPath).exists()) {
      log('file found -----------');
      setState(() {
        newPath = File(mPath).path;
        attendanceButton = true;
      });
    } else {
      log('file not found -----------');
    }
  }

  _apiCall() async {
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://arclightmobile.azurewebsites.net/api/Store_Attendance_File'));
    request.fields
        .addAll({'lat': lat, 'lng': long, 'usr_id': '10', 'data_type': 'T'});

    request.files.add(await http.MultipartFile.fromPath('file', newPath));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      log('--------- success ---------');

      final responseString = await response.stream.bytesToString();
      //final decodeMap = json.decode(responseString);
      Map<String, dynamic> map = Map.from(json.decode(responseString));

      setState(() {
        isLoading = false;
        attendanceButton = false;
        startAPI = false;
      });
      if (map['attencance_validated'] == 'yes') {
        String name = map['employee_name'];
        _showDialog(
            'Success', 'Employee Name: $name', name, 'Success', newPath);
      } else {
        String name = map['employee_name'];
        _showDialog2(
            'Fail', '$name Attendance can\'t submitted. Try some time later');
      }
    } else {
      log('--------- fail ---------');
      //print(response.reasonPhrase);
      setState(() {
        isLoading = false;
        attendanceButton = false;
        startAPI = false;
      });
    }
  }

  _showDialog(String title, String message, String name, String status,
      String imagePath) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      showCloseIcon: true,
      title: title,
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dismiss from callback $type');
        _openStatusPage(name, status, imagePath);
      },
    ).show();
  }

  _showDialog2(String title, String message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      showCloseIcon: true,
      title: title,
      desc: message,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
      },
    ).show();
  }

  _openStatusPage(String empName, String status, String imagePath) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AttendanceStatusPage(
                empName: empName,
                status: status,
                imagePath: imagePath))).then((value) {
      setState(() {
        newPath = 'blank';
      });
    });
  }
}
