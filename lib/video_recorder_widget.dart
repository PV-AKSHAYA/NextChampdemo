
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'performance_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// enum VideoStatus { idle, recording, analyzing, pendingSync, uploaded }

// class VideoRecorderWidget extends StatefulWidget {
//   final CameraDescription camera;
//   final String authToken;

//   const VideoRecorderWidget({Key? key, required this.camera, required this.authToken}) : super(key: key);

//   @override
//   _VideoRecorderWidgetState createState() => _VideoRecorderWidgetState();
// }

// class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
//   late CameraController _controller;
//   bool _isRecording = false;
//   VideoStatus _status = VideoStatus.idle;
//   String? _videoPath;
//   List<ConnectivityResult> _connectivityStatus = [];

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();

//     Connectivity().onConnectivityChanged.listen((status) {
//       setState(() => _connectivityStatus = status);
//       if (status != ConnectivityResult.none && _status == VideoStatus.pendingSync) {
//         _uploadVideo();
//       }
//     });
//   }

//   Future<void> _initCamera() async {
//     _controller = CameraController(widget.camera, ResolutionPreset.medium);
//     await _controller.initialize();
//     if (mounted) {
//       final connectivityResult = await Connectivity().checkConnectivity();
//       setState(() {
//         _connectivityStatus = connectivityResult;
//       });
//     }
//   }

//   Future<String?> _getStorageDir() async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return null;

//     final dir = await getApplicationDocumentsDirectory();
//     final videoDir = Directory(p.join(dir.path, 'videos'));
//     if (!await videoDir.exists()) await videoDir.create(recursive: true);
//     return videoDir.path;
//   }

//   Future<void> _startRecording() async {
//     await _controller.startVideoRecording();
//     setState(() {
//       _isRecording = true;
//       _status = VideoStatus.recording;
//     });
//   }

//   Future<void> _stopRecording() async {
//     final file = await _controller.stopVideoRecording();
//     setState(() {
//       _isRecording = false;
//       _status = VideoStatus.analyzing;
//     });

//     final storagePath = await _getStorageDir();
//     if (storagePath == null) {
//       setState(() => _status = VideoStatus.idle);
//       return;
//     }

//     final newPath = p.join(storagePath, '${DateTime.now().millisecondsSinceEpoch}.mp4');
//     await File(file.path).copy(newPath);
//     _videoPath = newPath;

//     // Simulated preliminary analysis delay
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() => _status = VideoStatus.pendingSync);

//     if (_connectivityStatus.isNotEmpty && _connectivityStatus.first != ConnectivityResult.none) {
//       final videoUrl = await _uploadVideo();

//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId == null) {
//         print('User not logged in');
//         return;
//       }

//       const testType = 'vertical_jump'; // Replace with real test type
//       const score = 42.0; // Replace with real score
//       const cheatDetected = false; // Replace with real cheat detection result
//       final analysisResults = {'method': 'ml-model', 'confidence': 0.95};

//       if (videoUrl != null) {
//         await onTestComplete(
//           userId: userId,
//           testType: testType,
//           score: score,
//           videoUrl: videoUrl,
//           cheatDetected: cheatDetected,
//           analysisResults: analysisResults,
//         );
//       } else {
//         print('Video upload failed; cannot save performance data.');
//       }
//     }

//     if (_videoPath != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => UploadScreen(
//             videoFile: File(_videoPath!),
//             authToken: widget.authToken,
//           ),
//         ),
//       );
//     }
//   }

//   Future<String?> _uploadVideo() async {
//     setState(() => _status = VideoStatus.analyzing);

//     if (_videoPath == null) return null;

//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) {
//       print('User not logged in');
//       return null;
//     }

//     final videoUrl = await uploadFileToFirebase(_videoPath!, userId);

//     if (_videoPath!= null) {
//       File videoFile = File(_videoPath!);
//       final videoUrl = await uploadVideoToFirebase(videoFile, userId);

//       if (videoUrl != null) {
//       // await Future.delayed(const Duration(seconds: 3));
//       setState(() => _status = VideoStatus.uploaded);
//       await onTestComplete(
//        userId: userId,
//        testType: 'vertical_jump', // replace with your real test type
//        score: 42.0, // replace with analysis score
//        videoUrl: videoUrl,
//        cheatDetected: false, // replace with real flag
//        analysisResults: {'method': 'ml-model', 'confidence': 0.95},
//   );
//     } else {
//       setState(() => _status = VideoStatus.pendingSync);
//       print('Video upload failed');
//     }
//     }
//     return videoUrl;
//   }
    
//   Future<String?> uploadVideoToFirebase(File videoFile, String userId) async {
//    try {
//     String path = 'videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
//     Reference ref = FirebaseStorage.instance.ref().child(path);
//     UploadTask uploadTask = ref.putFile(videoFile);
//     await uploadTask;
//     String downloadUrl = await ref.getDownloadURL();
//     return downloadUrl;
//   } catch (e) {
//     print('Upload error: $e');
//     return null;
//   }
// }


//   Future<String?> uploadFileToFirebase(String filePath, String userId) async {
//     try {
//       File file = File(filePath);
//       String storagePath = 'videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
//       Reference ref = FirebaseStorage.instance.ref().child(storagePath);
//       UploadTask uploadTask = ref.putFile(file);
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//       String downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       print('Upload failed: $e');
//       return null;
//     }
//   }

//   Future<void> onTestComplete({
//     required String userId,
//     required String testType,
//     required double score,
//     required String videoUrl,
//     required bool cheatDetected,
//     required Map<String, dynamic> analysisResults,
//   }) async {
//     Map<String, dynamic> performanceData = {
//       'testType': testType,
//       'score': score,
//       'videoUrl': videoUrl,
//       'cheatDetected': cheatDetected,
//       'analysisResults': analysisResults,
//       'timestamp': FieldValue.serverTimestamp(),
//     };
//     await addPerformance(userId, performanceData);
//     // Optionally update UI or notify user
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     String statusText;
//     Color statusColor;

//     switch (_status) {
//       case VideoStatus.recording:
//         statusText = 'Recording...';
//         statusColor = Colors.red;
//         break;
//       case VideoStatus.analyzing:
//         statusText = 'Processing video...';
//         statusColor = Colors.orange;
//         break;
//       case VideoStatus.pendingSync:
//         statusText = 'Waiting for network to sync';
//         statusColor = Colors.grey;
//         break;
//       case VideoStatus.uploaded:
//         statusText = 'Uploaded';
//         statusColor = Colors.green;
//         break;
//       case VideoStatus.idle:
//       default:
//         statusText = 'Ready to record';
//         statusColor = Colors.blue;
//         break;
//     }

//     return Column(
//       children: [
//         AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: CameraPreview(_controller),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           statusText,
//           style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//           onPressed: _isRecording ? _stopRecording : _startRecording,
//           icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
//           label: Text(_isRecording ? 'Stop' : 'Record'),
//           style: ElevatedButton.styleFrom(minimumSize: const Size(150, 48)),
//         ),
//       ],
//     );
//   }
// }

// /// Replace this stub with your actual UploadScreen implementation
// class UploadScreen extends StatelessWidget {
//   final File videoFile;
//   final String authToken;

//   const UploadScreen({required this.videoFile, required this.authToken, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload Video')),
//       body: Center(child: Text('Upload and Assessment UI here for ${videoFile.path}')),
//     );
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'performance_service.dart';

enum VideoStatus { idle, recording, analyzing, pendingSync, uploaded }

class VideoRecorderWidget extends StatefulWidget {
  final CameraDescription camera;
  final String authToken;

  const VideoRecorderWidget({Key? key, required this.camera, required this.authToken}) : super(key: key);

  @override
  _VideoRecorderWidgetState createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  late CameraController _controller;
  bool _isRecording = false;
  VideoStatus _status = VideoStatus.idle;
  String? _videoPath;
  List<ConnectivityResult> _connectivityStatus = [];

  @override
  void initState() {
    super.initState();
    _initCamera();

    Connectivity().onConnectivityChanged.listen((status) {
      setState(() => _connectivityStatus = status);
      if (status != ConnectivityResult.none && _status == VideoStatus.pendingSync) {
        _uploadVideoAndSavePerformance();
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

    // Simulated preliminary analysis delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _status = VideoStatus.pendingSync);

    // Upload and save only when connectivity is available
    if (_connectivityStatus.isNotEmpty && _connectivityStatus.first != ConnectivityResult.none) {
      await _uploadVideoAndSavePerformance();
    }

    // Optionally, navigate to UploadScreen with local video
    if (_videoPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadScreen(
            videoFile: File(_videoPath!),
            authToken: widget.authToken,
          ),
        ),
      );
    }
  }


//   Future<void> savePerformance(Map<String, dynamic> performanceData) async {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) return;

//   await FirebaseFirestore.instance
//       .collection('performances')
//       .doc(userId)
//       .set(performanceData, SetOptions(merge: true));
// }





//   Future<void> _uploadVideoAndSavePerformance() async {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null || _videoPath == null) {
//     print('User not logged in or video path null');
//     return;
//   }

//   final videoFile = File(_videoPath!);
//   final videoUrl = await uploadFileToFirebase(videoFile, userId);
//   print('Video uploaded: $videoUrl');

//   if (videoUrl != null) {
//     setState(() => _status = VideoStatus.uploaded);

//     // Example AI/ML results:
//     final testType = 'vertical_jump';
//     final score = 42.0;
//     final cheatDetected = false;
//     final analysisResults = {'method': 'ml-model', 'confidence': 0.95};

//     try {
//       await savePerformanceResult(userId, {
//         'testType': testType,
//         'score': score,
//         'videoUrl': videoUrl,
//         'cheatDetected': cheatDetected,
//         'analysisResults': analysisResults,
//       });
//       print('Performance data saved');
//     } catch (e) {
//       print('Error saving performance data: $e');
//     }
//   } else {
//     print('Video upload failed');
//     setState(() => _status = VideoStatus.pendingSync);
//   }
// }


Future<void> _uploadVideoAndSavePerformance() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || _videoPath == null) {
    print('User not logged in or video path null');
    return;
  }

  final videoFile = File(_videoPath!);
  
  print('Uploading video...');
  final videoUrl = await uploadFileToFirebase(videoFile, userId);
  print('Uploaded URL: $videoUrl');

  if (videoUrl != null) {
    setState(() => _status = VideoStatus.uploaded);

    // Example AI/ML results:
    final testType = 'vertical_jump';
    final score = 42.0;
    final cheatDetected = false;
    final analysisResults = {'method': 'ml-model', 'confidence': 0.95};

    try {
      print('Saving performance data...');
      await savePerformanceResult(userId, {
        'testType': testType,
        'score': score,
        'videoUrl': videoUrl,
        'cheatDetected': cheatDetected,
        'analysisResults': analysisResults,
      });
      print('Performance saved.');
    } catch (e) {
      print('Error saving performance data: $e');
    }
  } else {
    print('Video upload failed');
    setState(() => _status = VideoStatus.pendingSync);
  }
}



  // Future<String?> uploadFileToFirebase(File videoFile, String userId) async {
  //   try {
  //     String path = 'videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
  //     Reference ref = FirebaseStorage.instance.ref().child(path);
  //     UploadTask uploadTask = ref.putFile(videoFile);
  //     await uploadTask;
  //     return await ref.getDownloadURL();
  //   } catch (e) {
  //     print('Upload error: $e');
  //     return null;
  //   }

    
  // }

  Future<String?> uploadFileToFirebase(File videoFile, String userId) async {
  try {
    final path = 'videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(videoFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
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

/// Stub for upload/review screen; customize as needed
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
