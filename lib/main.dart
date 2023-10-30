import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:archlighthr/home_page.dart';
import 'package:archlighthr/login_page.dart';
import 'package:archlighthr/my_constant/api_data.dart';
import 'package:archlighthr/my_service/check_innetnet.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArchlightHR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      //home: const LoginPage(),
      //home: const TestPage(),
      home: const MySplashScreen(),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  late StreamSubscription internetSubscription;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final hasInternet = event == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });
    });

    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (hasInternet) {
        _isLogIn();
      } else {
        log('----- offline mode -----');
        _offlineModeCheckLogin();
      }
    });
  }

  _checkInternet() async {
    CheckNetOneTime().hasNetwork().then((bool isConnected) {
      if (isConnected) {
        log('----- online mode -----');
        _isLogIn();
      } else {
        log('----- offline mode -----');
        _isLogIn();
      }
    }).catchError((error) {
      _isLogIn();
    });
  }

  _isLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? emp_ID = prefs.getString('emp_ID');
    final String? password = prefs.getString('password');
    final String? loginDeviceID = prefs.getString('loginDeviceID');
    if (emp_ID != null && password != null && loginDeviceID != null) {
      log('----- you are log in -----');
      _logInApi(emp_ID, password, loginDeviceID);
    } else {
      log('----- you are not log in -----');
      _goToLogInPage();
    }
  }

  _offlineModeCheckLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? emp_ID = prefs.getString('emp_ID');
    final String? password = prefs.getString('password');
    final String? loginDeviceID = prefs.getString('loginDeviceID');
    if (emp_ID != null && password != null && loginDeviceID != null) {
      log('----- you are log in -----');
      _goToHomeScreen();
    } else {
      log('----- you are not log in -----');
      _goToLogInPage();
    }
  }

  _logInApi(String emp_id, String password, String logindeviceid) async {
    String uri =
        '${APIData().getBaseUrl()}Arclight_Commun_Func?Report_Name=Get_Emp_With_Emp_ID&Sp_Name=SP_Common_Control';
    var body =
        '{"emp_id": "$emp_id","password": "$password","logindeviceid": "$logindeviceid"}';
    try {
      final response = await http.post(Uri.parse(uri),
          headers: APIData().getAPIHeader(), body: body);
      if (response.statusCode == 200) {
        String s = response.body;

        Map<String, dynamic> map = json.decode(s);
        List list = map['data'];

        Map<String, dynamic> mp = list[0];
        if (mp['return_Status'] == 'True') {
          //log('------ success');
          _goToHomeScreen();
        } else {
          //log('--------- fail');
          //log(mp['return_Message']);
          _showError('Login Fail', mp['return_Message']);
        }
      } else {
        log('can not login');
        _showError('Login Fail', 'Can not login');
      }
    } catch (e) {
      log(e.toString());
      _showError('Login Fail', 'Please Contact...');
    }
  }

  _goToHomeScreen() {
    Navigator.pop(context);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
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
        debugPrint('OnClick');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        _goToLogInPage();
      },
    ).show();
  }

  _goToLogInPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void dispose() {
    internetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            const Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/app_icon.jpg'),
                radius: 70,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              /* child: Image.asset(
                'assets/dart.png',
                height: 100,
              ),*/
              child: Text(
                'Arclight HR',
                style: GoogleFonts.titilliumWeb(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    letterSpacing: .5,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
