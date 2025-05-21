import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MiniCameraPreview extends StatefulWidget {
  const MiniCameraPreview({Key? key}) : super(key: key);

  @override
  _MiniCameraPreviewState createState() => _MiniCameraPreviewState();
}

class _MiniCameraPreviewState extends State<MiniCameraPreview> {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
    );

    await _controller.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            if (_isCameraInitialized)
              CameraPreview(_controller)
            else
              Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(
                Icons.videocam,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
