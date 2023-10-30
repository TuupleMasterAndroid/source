import 'dart:io';

import 'package:archlighthr/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_constant.dart';

class AttendanceStatusPage extends StatefulWidget {
  const AttendanceStatusPage(
      {Key? key,
      required String empName,
      required String status,
      required String imagePath})
      : _empName = empName,
        _status = status,
        _imagePath = imagePath,
        super(key: key);
  final String _empName;
  final String _status;
  final String _imagePath;
  @override
  State<AttendanceStatusPage> createState() => _AttendanceStatusPageState();
}

class _AttendanceStatusPageState extends State<AttendanceStatusPage> {
  late String newPath = 'blank';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Attendance Status'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const HomePage()),
                    ModalRoute.withName('/'));
              },
              icon: const Icon(Icons.home_filled),
              tooltip: 'Back to Home',
            )
          ],
          backgroundColor: ColorConstant.darkColor,
          elevation: 0.0),
      body: SafeArea(
        child: Stack(children: [
          Positioned(
            //top: 100,
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height - 120,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0),
                //color: ColorConstant.lightColor.withOpacity(0.5),
                color: ColorConstant.lightColor.withOpacity(0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _getImage(),
                  const SizedBox(height: 10.0),
                  Text(
                    widget._empName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSans(
                        fontSize: 25, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Attendance Status: ${widget._status}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60.0, vertical: 15.0),
                          backgroundColor: ColorConstant.darkColor,
                          shape: const StadiumBorder()),
                      onPressed: () {
                        if (mounted) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        }
                      },
                      child: const Text('Back')),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  _getImage() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(width: 4.0, color: Colors.grey)),
      child: Image.file(File(widget._imagePath),
          width: 150, height: 150, fit: BoxFit.cover, errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/self.png',
          ),
        );
      }),
    );
  }
}
