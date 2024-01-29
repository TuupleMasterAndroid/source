import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archlighthr/color_constant.dart';
import 'package:archlighthr/mysql/sql_helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attendance_status_page.dart';
import 'my_camera.dart';
import 'mysql/sql_offline_sync.dart';

class OfflineAttendancePage extends StatefulWidget {
  const OfflineAttendancePage({super.key});

  @override
  State<OfflineAttendancePage> createState() => _OfflineAttendancePageState();
}

class _OfflineAttendancePageState extends State<OfflineAttendancePage> {
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

/*  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: const Text('Employee Attendance (Offline)'),
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: ColorConstant.darkComplementary2),
                                child: TabBar(
                                    indicator: BoxDecoration(
                                        color: ColorConstant.darkComplementary1,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    labelColor: Colors.white,
                                    dividerColor: Colors.white,
                                    tabs: const [
                                      Tab(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Icon(Icons.person_3,
                                                color: Colors.white),
                                            SizedBox(width: 15.0),
                                            Text('Self',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))
                                          ])),
                                      Tab(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Icon(
                                              Icons.groups,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 15.0),
                                            Text(
                                              'My Team',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )
                                          ]))
                                    ]))),
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
                                const SizedBox(height: 15),
                                StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1)),
                                    builder: (context, snapshot) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('hh:mm:ss a')
                                                .format(DateTime.now()),
                                            style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500]),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            DateFormat('dd MMMM yyyy')
                                                .format(DateTime.now()),
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
                        const Expanded(
                            child: TabBarView(children: <Widget>[
                          SelfImage(),
                          TeamImage(),
                        ]))
                      ]))
            ]))));
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Employee Attendance (Offline)'),
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                        decoration: BoxDecoration(
                          color: ColorConstant.lightColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            StreamBuilder(
                                stream:
                                    Stream.periodic(const Duration(seconds: 1)),
                                builder: (context, snapshot) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 30.0),
                                      Text(
                                        DateFormat('hh:mm:ss a')
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()),
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
                    const Expanded(
                      child: SelfImage(),
                    )
                  ]))
        ])));
  }
}

class SelfImage extends StatefulWidget {
  const SelfImage({super.key});

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
  bool switchControl = false;
  var inOut = 'OFF';
  var _tabTextIndexSelected = 0;
  final _listTextTabToggle = ["In", "Out"];

  @override
  void initState() {
    checkGps();
    super.initState();
    inOut = 'I';
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
        /*setState(() {
          //refresh the UI
        });*/

        getLocation();
      }
    } else {
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
        desiredAccuracy: LocationAccuracy.high);
    if (kDebugMode) {
      //print(position.longitude); //Output: 80.24599079
      //print(position.latitude); //Output: 29.6593457
    }

    long = position.longitude.toString();
    lat = position.latitude.toString();

    /*setState(() {
      //refresh UI
    });*/

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
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
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration:
            BoxDecoration(color: ColorConstant.lightColor.withOpacity(0.5)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _getImage(),
            const SizedBox(height: 10),
            /*ElevatedButton(
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
            const SizedBox(height: 30.0),*/
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
                index == 0 ? inOut = 'I' : inOut = 'O';
                setState(() {
                  _tabTextIndexSelected = index;
                });
              },
              isScroll: true,
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Text('IN', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 20.0),

                FlutterSwitch(
                  width: 90,
                  height: 35,
                  activeText: 'In',
                  inactiveText: 'Out',
                  inactiveColor: ColorConstant.darkComplementary1,
                  activeColor: ColorConstant.darkComplementary2,
                  toggleSize: 20.0,
                  value: switchControl,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: toggleSwitch,
                ),
                const SizedBox(width: 20.0),
                //  const Text('OUT', style: TextStyle(fontSize: 18))
              ],
            ),*/
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
                        if (lat.isNotEmpty && long.isNotEmpty) {
                          if (!attendanceButton) return;
                          setCustomState(() {
                            isLoading = true;
                          });
                          startAPI = true;
                          _saveToSQL();
                        } else {
                          _infoDialog('Attendance',
                              'GPS Service is not enabled, turn on GPS location');
                        }

                        //_offlineSynchronization();
                      },
                      child: const Text('Attendance'));
            })
          ],
        ),
      ),
    );
  }

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
      log('------------- WHEN BACK TO PREVIOUS PAGE');
      imageCache.clear();
      _getSaveImage();
    });
  }

  _getSaveImage() async {
    String dir = (await getTemporaryDirectory()).path;
    String mPath = path.join(dir, 'myImage.jpg');

    String folderInAppDocDir = await createFolderInAppDocDir('dump');
    log(mPath);
    log(folderInAppDocDir);
    int countRecord = await SqlHelper().countRecord();

    newPath = path.join(folderInAppDocDir, 'myImage${countRecord + 1}.jpg');
    await moveFile(File(mPath), newPath);
    if (await File(newPath).exists()) {
      log('file found -----------');
      setState(() {
        //newPath = File(mPath).path;
        attendanceButton = true;
      });
    } else {
      log('file not found -----------');
    }
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory appDocDirFolder =
        Directory('${appDocDir.path}/$folderName/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  Future<File> moveFile(File originalFile, String targetPath) async {
    try {
      // This will try first to just rename the file if they are on the same directory,
      return await originalFile.rename(targetPath);
    } on FileSystemException catch (error) {
      // if the rename method fails, it will copy the original file to the new directory and then delete the original file
      final newFileInTargetPath = await originalFile.copy(targetPath);
      await originalFile.delete();
      return newFileInTargetPath;
    }
  }

  _saveToSQL() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empId = prefs.getString('emp_ID');
    int countRecord = await SqlHelper().countRecord();

    Map<String, dynamic> map = {
      'emp_id': empId ?? '',
      'in_out': inOut,
      'lat': lat,
      'long': long,
      'emp_photo': 'myImage${countRecord + 1}.jpg',
      'capture_time': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())
    };
    log('-------- start sql');
    SqlHelper().insertData(map).then((value) {
      if (value) {
        setState(() {
          isLoading = false;
          attendanceButton = false;
          startAPI = false;
        });
        isTablet(context).then((bool iPad) {
          _showDialog('Success', 'Your Attendance Save Successfully', '',
              'Success', newPath, iPad);
        });
      } else {
        setState(() {
          isLoading = false;
          attendanceButton = false;
          startAPI = false;
        });
        if (!mounted) return;
        isTablet(context).then((bool iPad) {
          _showDialog2('Fail', 'Your Attendance cannot Save!!!', iPad);
        });
      }
    }).catchError((onError) {
      //print('--------');
      //print(onError.toString());
      setState(() {
        isLoading = false;
        attendanceButton = false;
        startAPI = false;
      });
      isTablet(context).then((bool iPad) {
        _showDialog2('Fail', 'Your Attendance cannot Save!!!', iPad);
      });
    });
  }

  _showDialog(String title, String message, String name, String status,
      String imagePath, bool iPad) {
    if (iPad) {
      AwesomeDialog(
        context: context,
        width: 500,
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
          newPath = 'blank';
          switchControl = false;
          inOut = 'I';
          setState(() {});
          //_openStatusPage(name, status, imagePath);
          //Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    } else {
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
          newPath = 'blank';
          switchControl = false;
          inOut = 'I';
          setState(() {});
          //_openStatusPage(name, status, imagePath);
          //Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  _showDialog2(String title, String message, bool isPad) {
    if (isPad) {
      AwesomeDialog(
        context: context,
        width: 500,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.error,
        showCloseIcon: true,
        title: title,
        desc: message,
        btnOkOnPress: () {
          debugPrint('On Click');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: false,
        dialogType: DialogType.error,
        showCloseIcon: true,
        title: title,
        desc: message,
        btnOkOnPress: () {
          debugPrint('On Click');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        },
      ).show();
    }
  }

  _infoDialog(String title, String message) async {
    if (!mounted) return;
    bool iPad = await isTablet(context);
    if (!mounted) return;
    if (iPad) {
      AwesomeDialog(
        context: context,
        width: 500,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: title,
        desc: message,
        btnOkOnPress: () {},
      ).show();
    } else {
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

  Future<bool> isTablet(BuildContext context) async {
    bool isTab = false;
    if (Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.model.toLowerCase() == "ipad") {
        isTab = true;
      } else {
        isTab = false;
      }
      return isTab;
    } else {
      var shortestSide = MediaQuery.of(context).size.shortestSide;
      if (shortestSide > 600) {
        isTab = true;
      } else {
        isTab = false;
      }
      return isTab;
    }
  }

  _offlineSynchronization() async {
/*    SqlHelper().countRecord().then((value) {
      print(value);
    }).catchError((onError) {});*/
    bool isConnected = await hasNetwork();
    if (!isConnected) {
      log('--------- NET NOT CONNECTED ---------');
      return;
    }

    String dumpDir = await createFolderInAppDocDir('dump');
    //print(dumpDir);
    SqlHelper().getAll().then((value) {
      List<Map<String, dynamic>> getData = value;
      //print(getData.length);
      if (getData.isNotEmpty) {
        Map<String, dynamic> dataMap = getData.first;
        // {id: 1, emp_id: 5DOM5HKN4N, in_out: O, lat: 37.4219983, long: -122.084, emp_photo: myImage1.jpg, capture_time: 2023-06-09 12:36}
        int id = dataMap['id'];
        String empID = dataMap['emp_id'];
        String empPhoto = dataMap['emp_photo'];
        String inOut = dataMap['in_out'];
        String attendanceTime = dataMap['capture_time'];
        String getLat = dataMap['lat'];
        String getLan = dataMap['long'];
        //print(empPhoto);
        String filePath = '$dumpDir$empPhoto';
        //print(filePath);
        log('------- start upload image');

        SqlOfflineSync().uploadImage(filePath).then((value) {
          log('-------- on complete');
          Map<String, dynamic> map = value;
          String getUrl = map['message'];
          if (map['status']) {
            SqlOfflineSync()
                .sendAttendance(
                    getUrl, empID, attendanceTime, inOut, getLat, getLan)
                .then((value) {
              Map<String, dynamic> map = value;
              if (map['status']) {
                SqlHelper().deleteRecord(id).whenComplete(() {
                  _restartProcess();
                });
              } else {
                log('get error from attendance api');
              }
            });
          } else {
            log('error on upload image api');
          }
        }).catchError((onError) {
          log(onError.toString());
        });
      } else {
        log('----- no row in sql table');
      }
    });
  }

  _restartProcess() {
    _offlineSynchronization();
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  _offlineUploadImage() async {
    String imagePath = '';
    Map<String, dynamic> uploadResult =
        await SqlOfflineSync().uploadImage(imagePath);
    //returnMap = {'status': true, 'message': imageUrl};
    if (uploadResult.containsKey('status') &&
        uploadResult.containsKey('message')) {
      if (uploadResult['status']) {
        log('success and get upload url from map');
        String imageUrl = uploadResult['message'];
        _submitAttendance(imageUrl);
      } else {
        log('upload image return fail or unable');
      }
    } else {
      log('return map problem');
    }
  }

  _submitAttendance(String imageUrl) async {
    /*Map<String, dynamic> attendanceResult = await SqlOfflineSync()
        .sendAttendance(imageUrl, attendanceTime, inOut, lat, long);*/
  }
}

class TeamImage extends StatefulWidget {
  const TeamImage({super.key});

  @override
  State<TeamImage> createState() => _TeamImageState();
}

class _TeamImageState extends State<TeamImage> {
  File? _image;
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
    //print(position.longitude); //Output: 80.24599079
    //print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 1, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      //print(position.longitude); //Output: 80.24599079
      //print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
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
            const SizedBox(height: 30.0),
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
