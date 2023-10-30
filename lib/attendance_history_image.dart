import 'package:flutter/material.dart';

import 'color_constant.dart';
import 'home_page.dart';

class AttendanceHistoryImage extends StatefulWidget {
  const AttendanceHistoryImage({super.key, required this.imageURL});
  final String imageURL;
  @override
  State<AttendanceHistoryImage> createState() => _AttendanceHistoryImageState();
}

class _AttendanceHistoryImageState extends State<AttendanceHistoryImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Image'),
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: ColorConstant.lightColor.withOpacity(0.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    widget.imageURL,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
