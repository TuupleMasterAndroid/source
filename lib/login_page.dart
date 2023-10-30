import 'dart:convert';

import 'package:archlighthr/my_service/check_innetnet.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:keyboard_service/keyboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_constant.dart';
import 'home_page.dart';

enum FormData {
  Email,
  password,
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color enabled = const Color(0xFF608D99);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.white54;
  Color backgroundColor = const Color(0xFF608D99); //608D99
  bool ispasswordev = true;
  FormData? selected;
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return KeyboardAutoDismiss(
      scaffold: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login_back.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/app_icon.jpg'),
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Arclight HR',
                    style: GoogleFonts.titilliumWeb(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          letterSpacing: .5,
                          fontSize: 30,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 5,
                    //color: HexColor('#7a49a5').withOpacity(0.6),
                    color: ColorConstant.lightColor.withOpacity(0.5),
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10.0),
                          const Text(
                            "Please sign in to continue",
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.5,
                                fontSize: 24),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: selected == FormData.Email
                                  ? enabled
                                  : backgroundColor,
                            ),
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: emailController,
                              onTap: () {
                                setState(() {
                                  selected = FormData.Email;
                                });
                              },
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: selected == FormData.Email
                                      ? enabledtxt
                                      : deaible,
                                  size: 20,
                                ),
                                hintText: 'User ID',
                                hintStyle: TextStyle(
                                    color: selected == FormData.Email
                                        ? enabledtxt
                                        : deaible,
                                    fontSize: 12),
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              style: TextStyle(
                                  color: selected == FormData.Email
                                      ? enabledtxt
                                      : deaible,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: selected == FormData.password
                                    ? enabled
                                    : backgroundColor),
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              controller: passwordController,
                              onTap: () {
                                setState(() {
                                  selected = FormData.password;
                                });
                              },
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.lock_open_outlined,
                                  color: selected == FormData.password
                                      ? enabledtxt
                                      : deaible,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: ispasswordev
                                      ? Icon(
                                          Icons.visibility_off,
                                          color: selected == FormData.password
                                              ? enabledtxt
                                              : deaible,
                                          size: 20,
                                        )
                                      : Icon(
                                          Icons.visibility,
                                          color: selected == FormData.password
                                              ? enabledtxt
                                              : deaible,
                                          size: 20,
                                        ),
                                  onPressed: () => setState(
                                      () => ispasswordev = !ispasswordev),
                                ),
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                    color: selected == FormData.password
                                        ? enabledtxt
                                        : deaible,
                                    fontSize: 12),
                              ),
                              obscureText: ispasswordev,
                              textAlignVertical: TextAlignVertical.center,
                              style: TextStyle(
                                  color: selected == FormData.password
                                      ? enabledtxt
                                      : deaible,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white))
                              : TextButton(
                                  onPressed: () {
                                    if (emailController.text
                                            .trim()
                                            .isNotEmpty &&
                                        passwordController.text
                                            .trim()
                                            .isNotEmpty) {
                                      KeyboardService.dismiss();
                                      CheckNetOneTime()
                                          .hasNetwork()
                                          .then((bool result) {
                                        if (result) {
                                          setState(() => isLoading = true);
                                          _logInApi();
                                        } else {
                                          _infoDialog('User Login',
                                              'Your Internet is disconnected. Please connect and then login');
                                        }
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: ColorConstant.darkColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14.0, horizontal: 80),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0))),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.only(left: 50.0, right: 50.0),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                                text: "Our ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: "Terms & Conditions ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline)),
                            TextSpan(
                                text: "| ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                /*recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },*/
                                text: "Privacy Policy",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _logInApi() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    String? deviceID = sharedPreferences.getString('loginDeviceID');
    //String? deviceID = 'GF17BPFHMT'; shankha
    //String? deviceID = 'DFJ5I4QVUW'; //nilanjan

    deviceID ??= '';
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };

    String uri =
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func?Report_Name=Get_Emp_With_Mobile&Sp_Name=SP_Common_Control';
    var body =
        '{"mobile": "${emailController.text.trim()}","password": "${passwordController.text.trim()}", "logindeviceid":"$deviceID"}';
    //'{"mobile": "9830083322","password": "s1"}';
    //'{"mobile": "9903423570","password": "n1"}';

    try {
      final response =
          await http.post(Uri.parse(uri), headers: headers, body: body);
      if (response.statusCode == 200) {
        String s = response.body;

        Map<String, dynamic> map = json.decode(s);
        List list = map['data'];

        Map<String, dynamic> mp = list[0];
        if (mp['return_Status'] == 'True') {
          //log('------ success');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('comp_ID', mp['comp_ID']);
          await prefs.setString('br_ID', mp['br_ID']);
          await prefs.setString('emp_ID', mp['emp_ID']);
          await prefs.setString('emp_Code', mp['emp_Code']);
          await prefs.setString('emP_Name', mp['emP_Name']);
          await prefs.setString('mobile', mp['mobile']);
          await prefs.setString('password', mp['password']);
          await prefs.setString('loginDeviceID', mp['loginDeviceID']);
          setState(() => isLoading = false);
          _goToHomeScreen();
        } else {
          setState(() => isLoading = false);
          _showError('Login Fail', mp['return_Message']);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
    //LoginModel loginModel = LoginModel.fromJson(map['data']);

    /*
      return_Status: True,
      comp_ID: YAAPTCYRKC,
      br_ID: Q5KKS8M695,
      emp_ID: 5DOM5HKN4N,
      emp_Code: E001,
      emP_Name: Sankha,
      mobile: 9830083322,
      password: s1,
      loginDeviceID: GF17BPFHMT
      return_Message": "Invalid Employee or Access denied
    */
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
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
      onDismissCallback: (type) {
        debugPrint('Dialog Dissmiss from callback $type');
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
}
