// @dart=2.9
import 'package:camera/camera.dart';
import 'package:chat_app/widgets/camera_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCameraPage extends StatefulWidget {
  @override
  _MyCameraPage createState() => _MyCameraPage();
}

class _MyCameraPage extends State<MyCameraPage> with WidgetsBindingObserver {
  CameraController _controller;
  Future<void> initController;
  var isCameraReady = false;
  XFile imageFile;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initController = _controller != null ? _controller.initialize() : null;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: initController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                cameraWidget(context, _controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Color(0xAA333639),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                            iconSize: 40,
                            onPressed: () => captureImage(context),
                            icon: Icon(Icons.camera_alt, color: Colors.white))
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    initController = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  captureImage(BuildContext context) {
    _controller.takePicture().then((file) => Navigator.pop(context, file));
  }
}
