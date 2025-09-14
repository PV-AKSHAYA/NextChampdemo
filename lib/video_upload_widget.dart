import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class VideoUploadWidget extends StatefulWidget {
  final File videoFile;
  final String authToken; // Auth token for backend if required

  const VideoUploadWidget({required this.videoFile, required this.authToken, Key? key}) : super(key: key);

  @override
  _VideoUploadWidgetState createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  bool _isUploading = false;
  double _progress = 0;
  String? _uploadStatus;

  Future<void> _uploadVideo() async {
    setState(() {
      _isUploading = true;
      _progress = 0;
      _uploadStatus = null;
    });

    try {
      var uri = Uri.parse('http://192.168.29.24/videos/upload'); // Replace with your backend API
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${widget.authToken}';

      request.files.add(await http.MultipartFile.fromPath(
        'video',
        widget.videoFile.path,
        filename: path.basename(widget.videoFile.path),
      ));

var response = await request.send();

if (response.statusCode == 200) {
    setState(() {
      _uploadStatus = "Video uploaded and assessment started successfully!";
    });
}else {
    setState(() {
        _uploadStatus = "Upload failed with status ${response.statusCode}";
     });
    }
setState(() => _isUploading = false);

    } catch (e) {
      setState(() {
        _uploadStatus = "Upload failed: $e";
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Selected Video: ${path.basename(widget.videoFile.path)}'),
        const SizedBox(height: 12),
        _isUploading
            ? LinearProgressIndicator(value: _progress)
            : ElevatedButton.icon(
                onPressed: _uploadVideo,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Video & Assess'),
              ),
        if (_uploadStatus != null) ...[
          const SizedBox(height: 12),
          Text(_uploadStatus!, style: TextStyle(color: _uploadStatus!.contains('failed') ? Colors.red : Colors.green)),
        ],
      ],
    );
  }
}
