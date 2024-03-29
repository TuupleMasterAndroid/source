import 'package:flutter/material.dart';

import 'color_constant.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  final double radius = 12.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // <-- SEE HERE
          ),
          title: const Text('Payslip', style: TextStyle(color: Colors.white)),
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
                margin: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  tabs: [Text('Apply'), Text('Status')],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
