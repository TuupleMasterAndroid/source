import 'package:archlighthr/leave_apply_page.dart';
import 'package:archlighthr/leave_status_page.dart';
import 'package:flutter/material.dart';

import 'color_constant.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage>
    with AutomaticKeepAliveClientMixin<LeavePage> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColorConstant.pageBackGround,
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // <-- SEE HERE
          ),
          title: const Text('Leave', style: TextStyle(color: Colors.white)),
          backgroundColor: ColorConstant.darkColor,
          elevation: 0.0),
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                height: 45,
                margin: const EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  tabs: const [Text('Status'), Text('Apply')],
                ),
              ),
              const Expanded(
                  child: TabBarView(
                children: [LeaveStatusPage(), LeaveApplyPage()],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
