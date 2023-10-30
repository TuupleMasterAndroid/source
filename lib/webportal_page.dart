import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'color_constant.dart';

class WebPortalPage extends StatefulWidget {
  const WebPortalPage({Key? key}) : super(key: key);

  @override
  State<WebPortalPage> createState() => _WebPortalPageState();
}

class _WebPortalPageState extends State<WebPortalPage> {
  late WebViewController _controller;
  final String link = 'https://flutter.dev';
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            if (host.contains('youtube.com')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Blocking navigator $host',
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('SnackBar', onMessageReceived: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.message)));
      })
      ..loadRequest(Uri.parse(link));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: _controller,
                    ),
                    if (loadingPercentage < 100)
                      LinearProgressIndicator(
                        backgroundColor: ColorConstant.darkColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            ColorConstant.lightColor),
                        color: Colors.red,
                        minHeight: 10,
                        value: loadingPercentage / 100.0,
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                            color: Colors.deepPurpleAccent.withOpacity(0.5),
                            icon: const Icon(
                              Icons.home,
                              size: 50.0,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _showMessage();
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _goBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      _showMessage();
      return Future.value(true);
    }
  }

  _showMessage() {
    if (mounted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: const Text('Do you want to Back to Dashboard ?'),
                  actions: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No'),
                    ),
                    MaterialButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            Navigator.pop(context);
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              SystemNavigator.pop();
                            }
                            //SystemNavigator.pop();
                          } else if (Platform.isIOS) {
                            exit(0);
                          }
                        },
                        child: const Text('Yes'))
                  ]));
    }
  }
}
