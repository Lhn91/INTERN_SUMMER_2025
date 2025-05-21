import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:robot_ai/core/widgets/follow_controls.dart';

class FollowHumanPage extends StatefulWidget {
  const FollowHumanPage({Key? key}) : super(key: key);

  @override
  State<FollowHumanPage> createState() => _FollowHumanPageState();
}

class _FollowHumanPageState extends State<FollowHumanPage> {
  CameraController? _cameraController;
  bool _isFollowing = false;
  bool _isCameraInitialized = false;
  Rect? _humanBoundingBox;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      if (_isFollowing) {
        _startHumanDetection();
      } else {
        _stopHumanDetection();
      }
    });
  }

  void _startHumanDetection() {
    // Implement actual human detection logic
    // This is just a simulation - in real app you'd use ML Kit or similar
    _simulateHumanDetection();
  }

  void _simulateHumanDetection() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isFollowing || !mounted) return;

      setState(() {
        _humanBoundingBox = Rect.fromLTWH(
          MediaQuery.of(context).size.width * 0.3,
          MediaQuery.of(context).size.height * 0.3,
          200,
          300,
        );
      });

      _simulateHumanDetection();
    });
  }

  void _stopHumanDetection() {
    setState(() => _humanBoundingBox = null);
  }

  void _stopRobot() {
    setState(() {
      _isFollowing = false;
      _stopHumanDetection();
    });
    debugPrint("Robot stopped");
    // Implement actual stop command to robot
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Human'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Camera preview
            if (_isCameraInitialized && _cameraController != null)
              CameraPreview(_cameraController!)
            else
              const Center(child: CircularProgressIndicator()),

            // Human detection overlay
            if (_humanBoundingBox != null)
              Positioned.fromRect(
                rect: _humanBoundingBox!,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'PERSON',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),

            // Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FollowControls(
                isFollowing: _isFollowing,
                onToggleFollow: _toggleFollow,
                onStopPressed: _stopRobot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
