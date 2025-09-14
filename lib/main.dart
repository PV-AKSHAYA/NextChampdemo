import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'leaderboard_page.dart'; // Make sure this file exists and provides UserScore
import 'widgets/animated_badge.dart';
import 'widgets/progress_badge.dart';
import 'auth_screen.dart';
import 'video_playback_screen.dart';
import 'performance_chart.dart'; // Ensure this exports PerformanceChart widget
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gamification_bloc.dart';
import 'gamification_widgets.dart'; // Contains BadgeWidget and ProgressBarWidget
import 'video_recorder_widget.dart';
import 'gamification_screen.dart';
import 'video_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 👈 Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("✅ Firebase Android Connected")),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(NextChampApp(cameras: cameras));
}

class NextChampApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const NextChampApp({Key? key, required this.cameras}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextChamp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, height: 1.5),
          headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      home: AuthWrapper(cameras: cameras),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AuthWrapper({Key? key, required this.cameras}) : super(key: key);
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isAuthenticated = false;
  void onAuthSuccess() {
    setState(() => isAuthenticated = true);
  }
  @override
  Widget build(BuildContext context) {
    return isAuthenticated
        ? HomeScreen(cameras: widget.cameras, authToken: 'your_auth_token_here') // pass your auth token here
        : AuthScreen(onAuthSuccess: onAuthSuccess);
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String authToken; // Added auth token to HomeScreen
  const HomeScreen({Key? key, required this.cameras, required this.authToken}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;
  bool isRecording = false;
  String? videoPath;
  final List<UserScore> leaderboardData = [
    UserScore(rank: 1, username: 'Alice', score: 150),
    UserScore(rank: 2, username: 'Bob', score: 120),
    UserScore(rank: 3, username: 'You', score: 110),
    UserScore(rank: 4, username: 'Dana', score: 100),
  ];
  final String currentUser = 'You';
  final List<FlSpot> performanceSamples = [
    FlSpot(0, 55),
    FlSpot(1, 75),
    FlSpot(2, 65),
    FlSpot(3, 85),
    FlSpot(4, 95),
  ];
  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }
  Future<String?> _getStoragePath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) return null;
    }
    final dir = await getExternalStorageDirectory();
    if (dir == null) return null;
    final movies = Directory(p.join(dir.path, 'Movies'));
    if (!await movies.exists()) await movies.create(recursive: true);
    return movies.path;
  }
  Future<void> toggleRecording() async {
    if (isRecording) {
      final file = await controller.stopVideoRecording();
      setState(() => isRecording = false);
      final storagePath = await _getStoragePath();
      if (storagePath != null) {
        final newPath =
            p.join(storagePath, '${DateTime.now().millisecondsSinceEpoch}.mp4');
        await File(file.path).copy(newPath);
        videoPath = newPath;
      } else {
        videoPath = file.path;
      }
      setState(() {});
      bool fileExists = false;
      if (videoPath != null) {
        fileExists = await File(videoPath!).exists();
      }
      if (fileExists) {
        print('Video file exists at $videoPath');
      } else {
        print('Video file does NOT exist at $videoPath');
      }
      print('Navigating to VideoPlaybackScreen with path: $videoPath');
      if (videoPath != null && fileExists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlaybackScreen(videoPath: videoPath!),
          ),
        );
      } else {
        print('Video path is null or file does not exist, cannot navigate to playback.');
      }
    } else {
      await controller.startVideoRecording();
      setState(() => isRecording = true);
    }
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('NextChamp')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Pass the camera instance and auth token to VideoRecorderWidget
              VideoRecorderWidget(camera: widget.cameras.first, authToken: widget.authToken),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  AnimatedBadge(
                    badge: ProgressBadge(
                      label: 'Rising Star',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  AnimatedBadge(
                    badge: ProgressBadge(
                      label: 'Marathoner',
                      icon: Icons.directions_run,
                      color: Colors.green,
                    ),
                  ),
                  AnimatedBadge(
                    badge: ProgressBadge(
                      label: 'Achiever',
                      icon: Icons.emoji_events,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PerformanceChart(performancePoints: performanceSamples),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LeaderboardPage(
                              leaderboard: leaderboardData,
                              currentUser: currentUser)));
                },
                child: const Text('Show Leaderboard'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GamificationScreen()));
                },
                child: const Text('View Achievements'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewVideoScreen extends StatelessWidget {
  final String videoPath;
  final String authToken;

  const ReviewVideoScreen({required this.videoPath, required this.authToken, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Upload Video')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Your existing video player widget, e.g.:
            VideoPlaybackScreen(videoPath: videoPath),

            const SizedBox(height: 20),

            // Place the upload widget here
            VideoUploadWidget(
              videoFile: File(videoPath),
              authToken: authToken,
            ),
          ],
        ),
      ),
    );
  }
}
