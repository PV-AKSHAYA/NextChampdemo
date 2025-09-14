import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum VideoStatus { idle, recording, analyzing, pendingSync, uploaded }

class VideoRecorderWidget extends StatefulWidget {
  final CameraDescription camera;
  final String authToken; // Add authToken parameter here

  const VideoRecorderWidget({Key? key, required this.camera, required this.authToken}) : super(key: key);

  @override
  _VideoRecorderWidgetState createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  late CameraController _controller;
  bool _isRecording = false;
  VideoStatus _status = VideoStatus.idle;
  String? _videoPath;
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initCamera();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() => _connectivityStatus = status);
      if (status != ConnectivityResult.none && _status == VideoStatus.pendingSync) {
        _uploadVideo();
      }
    });
  }

  Future<void> _initCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    await _controller.initialize();
    if (mounted) {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _connectivityStatus = connectivityResult;
      });
    }
  }

  Future<String?> _getStorageDir() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return null;
    final dir = await getApplicationDocumentsDirectory();
    final videoDir = Directory(p.join(dir.path, 'videos'));
    if (!await videoDir.exists()) await videoDir.create(recursive: true);
    return videoDir.path;
  }

  Future<void> _startRecording() async {
    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
      _status = VideoStatus.recording;
    });
  }

  Future<void> _stopRecording() async {
    final file = await _controller.stopVideoRecording();
    setState(() {
      _isRecording = false;
      _status = VideoStatus.analyzing;
    });
    final storagePath = await _getStorageDir();
    if (storagePath == null) {
      setState(() => _status = VideoStatus.idle);
      return;
    }
    final newPath = p.join(storagePath, '${DateTime.now().millisecondsSinceEpoch}.mp4');
    await File(file.path).copy(newPath);
    _videoPath = newPath;
    // Simulated device-side preliminary analysis
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _status = VideoStatus.pendingSync);
    if (_connectivityStatus != ConnectivityResult.none) {
      await _uploadVideo();
    }

    // Navigate to UploadScreen with video file and auth token after recording
    if (_videoPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadScreen(
            videoFile: File(_videoPath!),
            authToken: widget.authToken, // pass auth token from widget property
          ),
        ),
      );
    }
  }

  Future<void> _uploadVideo() async {
    // Simulated upload delay and success
    setState(() => _status = VideoStatus.analyzing);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _status = VideoStatus.uploaded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    String statusText;
    Color statusColor;
    switch (_status) {
      case VideoStatus.recording:
        statusText = 'Recording...';
        statusColor = Colors.red;
        break;
      case VideoStatus.analyzing:
        statusText = 'Processing video...';
        statusColor = Colors.orange;
        break;
      case VideoStatus.pendingSync:
        statusText = 'Waiting for network to sync';
        statusColor = Colors.grey;
        break;
      case VideoStatus.uploaded:
        statusText = 'Uploaded';
        statusColor = Colors.green;
        break;
      case VideoStatus.idle:
      default:
        statusText = 'Ready to record';
        statusColor = Colors.blue;
        break;
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller),
        ),
        const SizedBox(height: 12),
        Text(
          statusText,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
          label: Text(_isRecording ? 'Stop' : 'Record'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(150, 48)),
        ),
      ],
    );
  }
}

/// Replace this stub with your actual UploadScreen implementation
class UploadScreen extends StatelessWidget {
  final File videoFile;
  final String authToken;

  const UploadScreen({required this.videoFile, required this.authToken, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Center(child: Text('Upload and Assessment UI here for ${videoFile.path}')),
    );
  }
}
