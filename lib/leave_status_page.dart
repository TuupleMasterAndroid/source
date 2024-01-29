import 'dart:convert';

import 'package:archlighthr/model/leavestatus_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'color_constant.dart';
import 'model/leavetype_model.dart';
import 'model/year_model.dart';
import 'my_constant/api_data.dart';

class LeaveStatusPage extends StatefulWidget {
  const LeaveStatusPage({super.key});

  @override
  State<LeaveStatusPage> createState() => _LeaveStatusPageState();
}

class _LeaveStatusPageState extends State<LeaveStatusPage>
    with AutomaticKeepAliveClientMixin<LeaveStatusPage> {
  @override
  bool get wantKeepAlive => true;
  TextEditingController yearController = TextEditingController();
  TextEditingController leaveController = TextEditingController();
  List<String> yearList = [];
  List<int> yearIdList = [];

  List<int> attendanceTypeIdList = [];
  List<String> attendanceTypeList = [];
  String? yearValue, leaveValue;
  int getYearID = -1;
  int getAttendanceTypeID = -1;
  List<LeaveData> leaveStatus = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColorConstant.pageBackGround,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            FutureBuilder(
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
                if (snapshot.connectionState == ConnectionState.done &&
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
          ],
        ),
      ),
    );
  }

  bool isReading = false;

  Widget bodyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Year',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        yearDropDown(),
        const SizedBox(height: 15.0),
        const Text('Leave Type',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        leaveDropDown(),
        const SizedBox(height: 25),
        Center(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 15.0),
                backgroundColor: ColorConstant.buttonColor,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                isReading = true;
                if (lState != null) lState!(() {});
                getLeaveAPI();
              },
              child: const Text(
                'Search',
                style: TextStyle(color: Colors.white),
              )),
        ),
        const SizedBox(height: 25),
        StatefulBuilder(
          builder: (context, setState) {
            lState = setState;
            return !isReading
                ? Expanded(
                    child: ListView.builder(
                      itemCount: leaveStatus.length,
                      itemBuilder: (context, index) {
                        Color statusColor = const Color(0xFFEA9276);
                        if (leaveStatus[index].status.toLowerCase() ==
                            'pending') {
                          statusColor = const Color(0xFFF3E96D);
                        } else if (leaveStatus[index].status.toLowerCase() ==
                            'approve') {
                          statusColor = const Color(0xFF2FADCC);
                        } else {
                          statusColor = const Color(0xFFFFDCD1);
                        }

                        return Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(
                              top: 0.0, bottom: 20.0, left: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 20.0,
                                decoration: BoxDecoration(color: statusColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0, top: 12.0),
                                child: Text(
                                    'Range: ${leaveStatus[index].applicationDateRange}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Text(
                                    'Days: ${leaveStatus[index].noOfDaysApply.toInt()}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Text(
                                    'Remarks: ${leaveStatus[index].remarks}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0, bottom: 12.0),
                                child: Text(
                                    'Status: ${leaveStatus[index].status}'),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          },
        )
      ],
    );
  }

  StateSetter? lState;

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

  getAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return [];
    }
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

  Future getLeaveAPI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? empCode = prefs.getString('emp_Code');
    if (empCode == null) {
      debugPrint('error1');
      return [];
    }

    try {
      String serverURL = APIData().getServer('get_status');
      //var body = '{"emp_code": "131", "Atten_Type_ID": 6, "HR_Year_ID": 3}';
      var body =
          '{"emp_code": "$empCode", "Atten_Type_ID": $getAttendanceTypeID, "HR_Year_ID": $getYearID}';

      final response = await http.post(Uri.parse(serverURL),
          headers: APIData().getAPIHeader(), body: body);
      if (response.statusCode == 200) {
        LeaveStatusModel leaveStatusModel =
            LeaveStatusModel.fromJson(jsonDecode(response.body));
        leaveStatus.clear();
        if (leaveStatusModel.data != null) {
          debugPrint('not null data');
          //print(leaveStatusModel.data!.length);
          leaveStatus = leaveStatusModel.data!;
          if (!mounted) {
            return [];
          } else {
            isReading = false;
            if (lState != null) lState!(() {});
          }
        } else {
          debugPrint('null data');
          isReading = false;
          if (lState != null) lState!(() {});
          return [];
        }
      } else {
        isReading = false;
        if (lState != null) lState!(() {});
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      isReading = false;
      if (lState != null) lState!(() {});
      return [];
    }
  }
}
