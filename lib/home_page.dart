import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:archlighthr/attendance_hostory_page.dart';
import 'package:archlighthr/no_data_page.dart';
import 'package:archlighthr/webportal_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'attendance_page.dart';
import 'color_constant.dart';
import 'my_service/check_innetnet.dart';
import 'mysql/sql_helper.dart';
import 'mysql/sql_offline_sync.dart';
import 'offline_attendance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color backgroundColor = const Color(0xFFFFFFFF);
  late String employeeName = '';
  bool isLoading = false;

  late StreamSubscription internetSubscription;
  bool hasInternet = true;

  @override
  void initState() {
    readName();
    super.initState();
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final hasInternet = event == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });
    });
  }

  @override
  void dispose() {
    internetSubscription.cancel();
    super.dispose();
  }

  readName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('emP_Name');
    if (name == null) {
      employeeName = '';
    } else {
      employeeName = name;
    }
    return employeeName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Container(
                color: ColorConstant.darkColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/app_icon.jpg'),
                          radius: 30,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text('Employee Portal',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10.0),
                      FutureBuilder(
                          future: readName(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Text(employeeName,
                                  style: GoogleFonts.firaSansCondensed(
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w600)));
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return Text(employeeName,
                                  style: GoogleFonts.firaSansCondensed(
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w600)));
                            }
                            return const Center();
                          }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 210,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 200,
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  decoration: BoxDecoration(
                      color: ColorConstant.lightColor.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0))),
                  child: GridView.count(
                    physics: const ScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: 200 / 120,
                    padding: const EdgeInsets.all(10.0),
                    children: [
                      menuItem('assets/attendance.png', 'Attendance', 1),
                      menuItem('assets/sync.png', 'Data Sync', 2),
                      menuItem(
                          'assets/attendance_history.png', 'Atten. History', 3),
                      menuItem('assets/application.png', 'Application', 4),
                      menuItem('assets/payslip.png', 'Payslip', 5),
                      menuItem('assets/leave.png', 'Leave', 6),
                      //menuItem('assets/potal.png', 'Portal', 7),
                      // -----------------------------------
                    ],
                  ),
                ),
              )),
          Positioned(
            top: 25,
            right: 8,
            child: PopUpMen(menuList: [
              PopupMenuItem(
                child: InkWell(
                    onTap: () async {
                      log('---------- logout');
                      bool iPad = await isTablet(context);
                      _logOut(iPad);
                    },
                    child: const ListTile(
                        leading: Icon(Icons.logout), title: Text("Logout"))),
              ),
            ], icon: const Icon(Icons.settings, size: 25, color: Colors.white)),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  alignment: Alignment.center,
                  child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            const CircularProgressIndicator(
                                backgroundColor: Colors.white, strokeWidth: 5),
                            const SizedBox(height: 8.0),
                            Text('Please wait',
                                style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)))
                          ]))),
                )
              : Container()
        ],
      ),
    );
  }

  Widget menuItem(String image, String title, int index) {
    return InkWell(
      onTap: () async {
        hasInternet = await CheckNetOneTime().hasNetwork();
        bool isGPSOn = await Geolocator.isLocationServiceEnabled();
        if (isGPSOn) {
          switch (index) {
            // ----------- Attendance Page -----------
            case 1:
              setState(() {});

              if (hasInternet) {
                log('--------- NET CONNECTED ---------');
                if (!mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AttendancePage()));
              } else {
                log('--------- NET NOT CONNECTED ---------');

                if (!mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OfflineAttendancePage()));
              }
              break;
            // ----------- Sync Data -----------
            case 2:
              if (!hasInternet) return;
              _countSqlRecord();
              break;
            // ----------- Attendance History -----------
            case 3:
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryPage()));
              break;
            case 4:
              // ----------- Application -----------
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NoDataPage(pageTitle: 'Application', type: 1),
                  ));
              break;
            case 5:
              // ----------- Payslip -----------
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NoDataPage(pageTitle: 'Payslip', type: 2),
                  ));
              break;
            case 6:
              // ----------- Leave -----------
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NoDataPage(pageTitle: 'Leave', type: 3),
                  ));
              break;
            case 7:
              if (!hasInternet) return;
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebPortalPage()));
              break;
            default:
          }
        } else {
          if (!mounted) return;
          bool iPad = await isTablet(context);

          _infoDialog('Attendance', 'Your GPS is OFF. Please ON you GPS', iPad);
        }
      },
      child: FutureBuilder(
          future: CheckNetOneTime().hasNetwork(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return Text(employeeName,
                  style: GoogleFonts.firaSansCondensed(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600)));
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              hasInternet = snapshot.data;
              return Container(
                  width: 180,
                  height: 130,
                  decoration: BoxDecoration(
                      color: index == 1
                          ? Colors.white
                          : hasInternet
                              ? Colors.white
                              : Colors.white30,
                      border: Border.all(
                        color: index == 1
                            ? const Color.fromARGB(255, 0, 0, 255)
                            : hasInternet
                                ? const Color.fromARGB(255, 0, 0, 255)
                                : Colors.white,
                        width: 1.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0))),
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Image.asset(
                          image,
                          width: 50,
                          height: 50,
                          color: ColorConstant.darkColor,
                        ),
                        const SizedBox(height: 10.0),
                        Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))
                      ])));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Future<void> customerCare() async {
    Uri? phoneNo;
    if (defaultTargetPlatform == TargetPlatform.android) {
      phoneNo = Uri.parse('tel:9007716803');
    }
    if (TargetPlatform == TargetPlatform.iOS) {
      phoneNo = Uri.parse('tel://9007716803');
    }

    if (phoneNo != null) {
      if (await canLaunchUrl(phoneNo)) {
        await launchUrl(phoneNo);
      } else {
        log(' could not launch $phoneNo');
      }
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

  _logOut(bool iPad) {
    if (iPad) {
      AwesomeDialog(
        context: context,
        width: 500,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Logout',
        desc: 'Logout from your account. Are you sure?',
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          // Remove data for the user data key.
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('comp_ID');
          await prefs.remove('br_ID');
          await prefs.remove('emp_ID');
          await prefs.remove('emp_Code');
          await prefs.remove('emP_Name');
          await prefs.remove('mobile');
          await prefs.remove('password');
          _reopenApp();
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Logout',
        desc: 'Logout from your account. Are you sure?',
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          // Remove data for the user data key.
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('comp_ID');
          await prefs.remove('br_ID');
          await prefs.remove('emp_ID');
          await prefs.remove('emp_Code');
          await prefs.remove('emP_Name');
          await prefs.remove('mobile');
          await prefs.remove('password');
          _reopenApp();
        },
      ).show();
    }
  }

  _reopenApp() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  _countSqlRecord() async {
    SqlHelper().countRecord().then((int count) async {
      if (count > 0) {
        bool iPad = await isTablet(context);
        _confirmDialog(iPad);
      } else {
        bool iPad = await isTablet(context);
        _infoDialog(
            'Sync Data', 'You have no any Offline Attendance Data', iPad);
      }
    });
  }

  _offlineSynchronization() async {
    bool isConnected = await hasNetwork();
    if (!isConnected) {
      log('--------- NET NOT CONNECTED ---------');
      setState(() => isLoading = false);
      return;
    }
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    String dumpDir = Directory('${appDocDir.path}/dump/').path;
    //print(dumpDir);
    SqlHelper().getAll().then((value) async {
      List<Map<String, dynamic>> getData = value;
      //print(getData.length);
      if (getData.isNotEmpty) {
        //print(getData.first);
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

        SqlOfflineSync().uploadImage(filePath).then((value) async {
          log('-------- on complete');
          Map<String, dynamic> map = value;
          String getUrl = map['message'];
          if (map['status']) {
            SqlOfflineSync()
                .sendAttendance(
                    getUrl, empID, attendanceTime, inOut, getLat, getLan)
                .then((value) async {
              Map<String, dynamic> map = value;
              if (map['status']) {
                SqlHelper().deleteRecord(id).whenComplete(() {
                  SqlOfflineSync().deleteFile(empPhoto).whenComplete(() {
                    _restartProcess();
                  });
                });
              } else {
                log('get error from attendance api');
                bool iPad = await isTablet(context);
                _errorDialog(
                    'Fail', 'Unable to Submit your Attendance Data', iPad);
              }
            });
          } else {
            log('error on upload image api');
            bool iPad = await isTablet(context);
            _errorDialog(
                'Fail', 'Unable to Upload your Attendance Photo', iPad);
          }
        }).catchError((onError) async {
          log(onError.toString());
          bool iPad = await isTablet(context);
          _errorDialog(
              'Fail',
              'Unable to save your Offline Attendance Data ${onError.toString()}',
              iPad);
        });
      } else {
        log('----- no row in sql table');
        bool iPad = await isTablet(context);

        _infoDialog('Submit Attendance',
            'Your Offline Attendance Date submitted Successfully', iPad);
      }
    });
  }

  _confirmDialog(bool iPad) {
    if (iPad) {
      AwesomeDialog(
        context: context,
        width: 500,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Sync Data',
        desc: 'Sync Attendance Data. Are you sure?',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          setState(() => isLoading = true);
          _offlineSynchronization();
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Sync Data',
        desc: 'Sync Attendance Data. Are you sure?',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          setState(() => isLoading = true);
          _offlineSynchronization();
        },
      ).show();
    }
  }

  _infoDialog(String title, String message, bool iPad) {
    if (iPad) {
      setState(() => isLoading = false);
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

  _errorDialog(String title, String message, bool iPad) {
    if (iPad) {
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

class PopUpMen extends StatelessWidget {
  final List<PopupMenuEntry> menuList;
  final Widget? icon;

  const PopUpMen({Key? key, required this.menuList, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      itemBuilder: ((context) => menuList),
      icon: icon,
    );
  }
}
