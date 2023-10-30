import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MyCamera extends StatefulWidget {
  const MyCamera({Key? key}) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> {
  late CameraController _cameraController;
  final ValueNotifier<bool> onCameraReady = ValueNotifier(false);
  bool _isRearCameraSelected = false;

  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    requestCameras();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    onCameraReady.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  Future requestCameras() async {
    try {
      final cameras = await availableCameras();
      final description = _isRearCameraSelected ? cameras[0] : cameras[1];
      // create a CameraController
      _cameraController = CameraController(description, ResolutionPreset.high,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      //await _cameraController.initialize();

      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          onCameraReady.value = true;
        });
      });
    } on CameraException catch (e) {
      onCameraReady.value = false;
      _logError(e.code, e.description);
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: onCameraReady,
          builder: (ctx, value, _) {
/*            return value
                ? SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                        aspectRatio: 1 / _cameraController.value.aspectRatio,
                        child: CameraPreview(_cameraController)))
                : const Center(child: CircularProgressIndicator());*/
            return Stack(
              children: [
                value
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRect(
                              child: Transform.scale(
                                scale: 1 / _cameraController.value.aspectRatio,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio:
                                        _cameraController.value.aspectRatio,
                                    child: CameraPreview(_cameraController),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CameraPreview(_cameraController),
                          cameraOverlay(
                              padding: 20,
                              aspectRatio: 1,
                              color: const Color(0x55000000))
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                          color: Colors.black),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              padding: const EdgeInsets.only(left: 15.0),
                              onPressed: () {},
                              iconSize: 50,
                              icon: Icon(
                                _isRearCameraSelected
                                    ? Icons.camera_alt_outlined
                                    : Icons.switch_camera_outlined,
                                color: Colors.transparent,
                              )),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              takePicture();
                            },
                            iconSize: 50,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                              padding: const EdgeInsets.only(right: 15.0),
                              onPressed: () {
                                setState(() {
                                  _isRearCameraSelected =
                                      !_isRearCameraSelected;
                                  requestCameras();
                                });
                              },
                              iconSize: 50,
                              icon: Icon(
                                _isRearCameraSelected
                                    ? Icons.camera_alt_outlined
                                    : Icons.switch_camera_outlined,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget cameraOverlay(
      {required double padding,
      required double aspectRatio,
      required Color color}) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentAspectRatio = constraints.maxWidth / constraints.maxHeight;
      double horizontalPadding;
      double verticalPadding;
      if (parentAspectRatio < aspectRatio) {
        horizontalPadding = padding;
        verticalPadding = (constraints.maxHeight -
                ((constraints.maxWidth - 2 * padding) / aspectRatio)) /
            2;
      } else {
        verticalPadding = padding;
        horizontalPadding = (constraints.maxWidth -
                ((constraints.maxHeight - 2 * padding) * aspectRatio)) /
            2;
      }
      log('mobile width ${constraints.maxWidth}');
      log('mobile height ${constraints.maxHeight}');
      log('hpadding $horizontalPadding');
      log('vpadding $verticalPadding');
      double a = constraints.maxWidth - (horizontalPadding * 2);
      double b = constraints.maxHeight - (verticalPadding * 2);
      log(' box $a $b');
      /*
      [log] mobile width 411.42857142857144
      [log] mobile height 683.4285714285714
      [log] hpadding 20.0
      [log] vpadding 156.0
            box 371.42857142857144 371.42857142857144
      // BODMAS
       */

      return Stack(fit: StackFit.expand, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(width: horizontalPadding, color: color)),
        Align(
            alignment: Alignment.centerRight,
            child: Container(width: horizontalPadding, color: color)),
        Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: EdgeInsets.only(
                    left: horizontalPadding, right: horizontalPadding),
                height: verticalPadding,
                color: color)),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(
                    left: horizontalPadding, right: horizontalPadding),
                height: verticalPadding,
                color: color)),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
        )
      ]);
    });
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();

      cropImage0(picture.path);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  cropImage0(String newPath) async {
    final image = await img.decodeImageFile(File(newPath).path);
    if (image != null) {
      double width = double.parse(image.data!.width.toString());
      double height = double.parse(image.data!.height.toString());
      int finalX = ((width.round() / 2).round()) - 340;
      int finalY = ((height.round() / 2).round()) - 380;

      double imageWidth = double.parse(image.data!.width.toString());
      double imageHeight = double.parse(image.data!.height.toString());
      double horizontalPadding = 62;
      double verticalPadding = (imageHeight - ((imageWidth - 2 * 62) / 1)) / 2;

      log('image width $imageWidth image height $imageHeight');
      log('${verticalPadding} ${horizontalPadding}');
      //int finalX = 20;
      //int finalY = 156 * 2;

      //[log] image width 720.0 image height 1280.0
      //[log] 300.0 20.0
      // **** 596.0  596.0
      // final 20 260

      double mWidth = imageWidth - (62 * 2);
      double mHeight = imageHeight - (verticalPadding * 2);
      log('final $finalX $finalY');
      log('**** $mWidth  $mHeight');
      final croppedImage =
          img.copyCrop(image, x: finalX, y: finalY, width: 740, height: 780);
      final newFile = _convertImageToFile(croppedImage, File(newPath).path);

      newFile.then((value) async {
        if (await File(newPath).exists()) {
          await File(newPath).delete();
        }

        _closeScreen();
      });
    }
  }

  cropImage(String newPath) async {
    final image = await img.decodeImageFile(File(newPath).path);
    if (image != null) {
      double width = double.parse(image.data!.width.toString());
      double height = double.parse(image.data!.height.toString());
      int finalX = ((width.round() / 2).round()) - 250;
      int finalY = ((height.round() / 2).round()) - 250;

      final croppedImage =
          img.copyCrop(image, x: finalX, y: finalY, width: 500, height: 500);
      final newFile = _convertImageToFile(croppedImage, File(newPath).path);
      //print(newFile.toString());
      newFile.then((value) {
        print(value.toString());
      });
    }
  }

  _closeScreen() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<File> _convertImageToFile(img.Image image, String path) async {
    final newPath = await _croppedFilePath(path);
    final jpegBytes = img.encodeJpg(image);

    final convertedFile = await File(newPath).writeAsBytes(jpegBytes);

    return convertedFile;
  }

  Future<String> _croppedFilePath(String path) async {
    final tempDir = await getTemporaryDirectory();
    String newFilePath = p.join(
        tempDir.path,
        /*'${p.basenameWithoutExtension(path)}_new.jpg',*/
        'myImage.jpg');

    return newFilePath;
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<File> copyFile(String newPath, String newFileName) async {
    final path = await _localPath;

    return File('$newPath').copy('$path/$newFileName');
  }

  Future<String> get _localPath async {
    //Get external storage directory
    var directory = await getExternalStorageDirectory();
    //Check if external storage not available. If not available use
    //internal applications directory
    directory ??= await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('------------------');
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}
