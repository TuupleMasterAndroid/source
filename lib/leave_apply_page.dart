import 'dart:convert';
import 'dart:developer';

import 'package:archlighthr/model/getbalance_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_constant.dart';
import 'model/leavetype_model.dart';
import 'model/totaldaysdodel.dart';
import 'model/year_model.dart';
import 'my_constant/api_data.dart';

class LeaveApplyPage extends StatefulWidget {
  const LeaveApplyPage({super.key});

  @override
  State<LeaveApplyPage> createState() => _LeaveApplyPageState();
}

class _LeaveApplyPageState extends State<LeaveApplyPage>
    with AutomaticKeepAliveClientMixin<LeaveApplyPage> {
  @override
  bool get wantKeepAlive => true;
  List<String> yearList = [];
  List<int> yearIdList = [];
  List<int> attendanceTypeIdList = [];
  List<String> attendanceTypeList = [];
  TextEditingController yearController = TextEditingController();
  TextEditingController leaveController = TextEditingController();

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  String? yearValue, leaveValue;
  int balanceAmount = 0;
  int getYearID = -1;
  int getAttendanceTypeID = -1;
  StateSetter? balState = null;
  StateSetter? totalState = null;
  int totalDays = 0;

  @override
  void initState() {
    fromDateController.text = '';
    toDateController.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColorConstant.pageBackGround,
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: FutureBuilder(
                        future: getAPI(),
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
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return bodyWidget();
                          }
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                )
              ],
            )),
      ),
    );
  }

  Widget bodyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        balanceWidget(),
        const Text('Year',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        yearDropDown(),
        const SizedBox(height: 15.0),
        const Text('Leave Type',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        leaveDropDown(),
        const SizedBox(height: 15.0),
        const Text('Leave from Date',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        fromDateBox(),
        const SizedBox(height: 15.0),
        const Text('Leave to Date',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        toDateBox(),
        const SizedBox(height: 6.0),
        noOfDaysWidget(),
        const SizedBox(height: 15.0),
        const Text('Remarks',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        TextField(
          controller: remarksController,
          maxLines: 2,
          style: const TextStyle(fontSize: 16.0),
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white70,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
        ),
        const SizedBox(height: 25.0),
        Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 15.0),
                backgroundColor: ColorConstant.buttonColor,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                /*var body = '{"emp_code": "131",'
                    '"Atten_Type_ID": $getAttendanceTypeID,'
                    '"Apply_From_Date": "${fromDateController.text}",'
                    '"Apply_To_Date": "${toDateController.text}",'
                    '"No_Of_Days_Apply": $totalDays,'
                    '"Remarks": "${remarksController.text.trim()}",'
                    '"HR_Year_ID": $getYearID}';

                print(body);*/

                saveAPI().then((value) {
                  if (value) {
                    debugPrint('------ ');
                  } else {
                    debugPrint('********');
                  }
                });
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              )),
        )
      ],
    );
  }

  Widget balanceWidget() {
    return StatefulBuilder(
      builder: (context, bState) {
        balState = bState;
        return Align(
          alignment: Alignment.centerRight,
          child: Text('Balance: $balanceAmount',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget noOfDaysWidget() {
    return StatefulBuilder(
      builder: (context, tState) {
        totalState = tState;
        return Center(
          child: Text(
            'No of Days: $totalDays',
            style: const TextStyle(fontSize: 16.0),
          ),
        );
      },
    );
  }

  Widget yearDropDown() {
    return StatefulBuilder(
      builder: (context, mState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select Year',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: yearList
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ))
                        .toList(),
                    value: yearValue,
                    onChanged: (value) {
                      if (value != null) {
                        try {
                          int position = yearList.indexOf(value);
                          if (position != -1) {
                            getYearID = yearIdList[position];
                          } else {
                            getYearID = -1;
                          }
                          yearValue = value;
                          mState(() {});
                        } catch (e) {
                          getYearID = -1;
                        }
                      }

                      getBalanceAPI().then((value) {
                        if (value) {
                          log('done=====>');
                          if (!mounted || balState == null) return;
                          balState!(() {});
                        } else {
                          log('fail api ======>');
                          if (!mounted || balState == null) return;
                          balState!(() {});
                        }
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(8),
                        )),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 200,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: yearController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 4, right: 8, left: 8),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: yearController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an item...',
                            hintStyle: const TextStyle(fontSize: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        yearController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget leaveDropDown() {
    return StatefulBuilder(
      builder: (context, mState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select Leave Type',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: attendanceTypeList
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: leaveValue,
                    onChanged: (value) {
                      if (value != null) {
                        try {
                          leaveValue = value;
                          int position = attendanceTypeList.indexOf(value);
                          getAttendanceTypeID = attendanceTypeIdList[position];
                          mState(() {});
                        } catch (e) {
                          getAttendanceTypeID = -1;
                        }
                      }

                      getBalanceAPI().then((value) {
                        if (value) {
                          log('done=====>');
                          if (!mounted || balState == null) return;
                          balState!(() {});
                          log('$balanceAmount');
                        } else {
                          log('fail api ======>');
                        }
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(8),
                        )),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 200,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: leaveController,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 4, right: 8, left: 8),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: leaveController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for an item...',
                            hintStyle: const TextStyle(fontSize: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        leaveController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget fromDateBox() {
    return StatefulBuilder(
      builder: (context, fState) {
        return Container(
          //height: ScreenUtil().setHeight(57),
          height: 40.0,
          decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all()),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Text(
                  fromDateController.text,
                  style: const TextStyle(
                    //color: Color(0xFF858585),
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.94,
                  ),
                ),
              )),
              InkWell(
                onTap: () => datePicker(1, fState),
                child: Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0),
                  child: Image.asset(
                    'assets/date_icon.png',
                    width: 25.0,
                    height: 25.0,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget toDateBox() {
    return StatefulBuilder(
      builder: (context, tState) {
        return Container(
          //height: ScreenUtil().setHeight(57),
          height: 40.0,
          decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all()),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Text(
                  toDateController.text,
                  style: const TextStyle(
                    //color: Color(0xFF858585),
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.94,
                  ),
                ),
              )),
              InkWell(
                onTap: () => datePicker(2, tState),
                child: Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0),
                  child: Image.asset(
                    'assets/date_icon.png',
                    width: 25.0,
                    height: 25.0,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool> getHRYearAPI() async {
    try {
      String serverURL = APIData().getServer('get_hr_year');
      final response = await http.get(
        Uri.parse(serverURL),
        headers: APIData().getAPIHeader(),
      );
      if (response.statusCode == 200) {
        YearModel yearModel = YearModel.fromJson(jsonDecode(response.body));
        yearList.clear();
        yearIdList.clear();
        for (int i = 0; i < yearModel.data.length; ++i) {
          yearList.add(yearModel.data[i].hRYearName);
          yearIdList.add(yearModel.data[i].hRYearID);
        }
        debugPrint('----> complete year api ${yearList.length}');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> getLeaveTypeAPI() async {
    try {
      String serverURL = APIData().getServer('get_leave_type');
      final response = await http.get(Uri.parse(serverURL),
          headers: APIData().getAPIHeader());
      if (response.statusCode == 200) {
        LeaveTypeModel leaveTypeModel =
            LeaveTypeModel.fromJson(jsonDecode(response.body));
        attendanceTypeIdList.clear();
        attendanceTypeList.clear();
        for (int i = 0; i < leaveTypeModel.data.length; ++i) {
          attendanceTypeIdList.add(leaveTypeModel.data[i].attenTypeID);
          attendanceTypeList.add(leaveTypeModel.data[i].attenType);
        }
        debugPrint('----> complete leave api ${attendanceTypeList.length}');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> getBalanceAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return false;
    }

    String hRYearId = getYearID.toString();
    String attendanceTypeId = getAttendanceTypeID.toString();
    /*var body =
        '{"emp_code": "EJOH041", "Atten_Type_ID": "${attendanceTypeId}", "HR_Year_ID": "${hRYearId}"}';*/
    var body =
        '{"emp_code": "$empCode", "Atten_Type_ID": "${attendanceTypeId}", "HR_Year_ID": "${hRYearId}"}';
    try {
      String serverURL = APIData().getServer('get_balance');

      final response = await http.post(Uri.parse(serverURL),
          headers: APIData().getAPIHeader(), body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        GetBalanceModel getBalanceModel =
            GetBalanceModel.fromJson(jsonDecode(response.body));
        if (getBalanceModel.data.length > 0) {
          log('yes');
          log(map.toString());
          log('${getBalanceModel.data.length}');
          log('${getBalanceModel.data[0].balance}');
          balanceAmount = getBalanceModel.data[0].balance.toInt();
        } else {
          log('no');
          balanceAmount = 0;
        }
        return true;
      } else {
        print('fail1 ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> getNoOfDays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return false;
    }
    try {
      /*var body = '{"emp_code":"EJOH041",'
          '"Atten_Type_ID":6,'
          '"Issued_From_Date":"${fromDateController.text}",'
          '"Issued_To_Date":"${toDateController.text}"}';*/
      var body = '{"emp_code":"$empCode",'
          '"Atten_Type_ID":6,'
          '"Issued_From_Date":"${fromDateController.text}",'
          '"Issued_To_Date":"${toDateController.text}"}';

      String serverURL = APIData().getServer('get_no_of_days');
      final response = await http.post(Uri.parse(serverURL),
          headers: APIData().getAPIHeader(), body: body);

      if (response.statusCode == 200) {
        debugPrint('------- success');

        TotalDaysModel totalDaysModel =
            TotalDaysModel.fromJson(jsonDecode(response.body));
        jsonDecode(response.body);
        if (totalDaysModel.data.length > 0) {
          //print(totalDaysModel.data[0].column1);
          totalDays = totalDaysModel.data[0].column1 != null
              ? totalDaysModel.data[0].column1!
              : 0;
        }
        return true;
      } else {
        debugPrint('------- fail-1');
        totalDays = 0;
        return false;
      }
    } catch (e) {
      debugPrint('------- fail-2');
      debugPrint(e.toString());
      totalDays = 0;
      return false;
    }
  }

  getAPI() async {
    try {
      String serverURL = APIData().getServer('get_hr_year');
      final response = await http.get(
        Uri.parse(serverURL),
        headers: APIData().getAPIHeader(),
      );
      if (response.statusCode == 200) {
        YearModel yearModel = YearModel.fromJson(jsonDecode(response.body));
        yearList.clear();
        yearIdList.clear();
        for (int i = 0; i < yearModel.data.length; ++i) {
          if (i == 0) {
            yearValue = yearModel.data[i].hRYearName;
            getYearID = yearModel.data[i].hRYearID;
          }
          yearList.add(yearModel.data[i].hRYearName);
          yearIdList.add(yearModel.data[i].hRYearID);
        }
        debugPrint('----> complete year api ${yearList.length}');
        //-------------------------------------------

        try {
          String serverURL = APIData().getServer('get_leave_type');
          final response = await http.get(
            Uri.parse(serverURL),
            headers: APIData().getAPIHeader(),
          );
          if (response.statusCode == 200) {
            LeaveTypeModel leaveTypeModel =
                LeaveTypeModel.fromJson(jsonDecode(response.body));
            attendanceTypeIdList.clear();
            attendanceTypeList.clear();
            for (int i = 0; i < leaveTypeModel.data.length; ++i) {
              attendanceTypeIdList.add(leaveTypeModel.data[i].attenTypeID);
              attendanceTypeList.add(leaveTypeModel.data[i].attenType);
            }
            debugPrint('----> complete leave api ${attendanceTypeList.length}');
            return [];
          } else {
            return [];
          }
        } catch (e) {
          debugPrint(e.toString());
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> saveAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return false;
    }

    try {
      String serverURL = APIData().getServer('save_leave_apply');

      /*var body =
          '{"emp_code": "131","Atten_Type_ID": $getAttendanceTypeID,"Apply_From_Date": "${fromDateController.text}","Apply_To_Date": "${toDateController.text}","No_Of_Days_Apply": $totalDays,"Remarks": "${remarksController.text.trim()}","HR_Year_ID": $getYearID}';*/
      var body =
          '{"emp_code": "$empCode","Atten_Type_ID": $getAttendanceTypeID,"Apply_From_Date": "${fromDateController.text}","Apply_To_Date": "${toDateController.text}","No_Of_Days_Apply": "$totalDays","Remarks": "${remarksController.text.trim()}","HR_Year_ID": "$getYearID"}';
      //print(body);

      final response = await http.post(Uri.parse(serverURL),
          headers: APIData().getAPIHeader(), body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        /*print(map);
        LeaveApplyModel leaveApplyModel =
            LeaveApplyModel.fromJson(jsonDecode(response.body));
        if (leaveApplyModel.data != null) {
          leaveApplyModel.data![0].msg;
        }*/
        //{status: true, statusCode: 200, message: save_leave_apply, data: [{status: True, msg: Done}], pagination: {loadMore: 0, lastRow: 1, total: 1}}

        _showDialog("Success", "Successfully sumitted your leave application");

        return true;
      } else {
        debugPrint('fail-1');
        debugPrint(response.statusCode.toString());
        return false;
      }
    } catch (e) {
      debugPrint('fail-2');
      debugPrint(e.toString());
      return false;
    }
  }

  datePicker(int who, StateSetter changeState) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime(2050));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
      if (who == 1) {
        changeState(() => fromDateController.text = formattedDate);
      } else {
        changeState(() => toDateController.text = formattedDate);
      }
      if (fromDateController.text.length > 0 &&
          toDateController.text.length > 0) {
        getNoOfDays().then((value) {
          if (value) {
            if (!mounted || totalState == null) return;
            totalState!(() {});
          }
        });
      }
    }
  }

  _showDialog(String title, String message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
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
