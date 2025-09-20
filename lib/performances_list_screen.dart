import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // for formatting timestamp

class PerformanceListScreen extends StatelessWidget {
  final String userId;

  const PerformanceListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Performances')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('performances')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final performances = snapshot.data!.docs;

          if (performances.isEmpty) {
            return const Center(child: Text('No performances found.'));
          }

          return ListView.builder(
            itemCount: performances.length,
            itemBuilder: (context, index) {
              var data = performances[index].data() as Map<String, dynamic>;
              var timestamp = data['timestamp'] as Timestamp?;
              String formattedTime = timestamp != null
                  ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                  : 'Unknown';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Test: ${data['testType'] ?? 'Unknown'}'),
                  subtitle: Text('Score: ${data['score']?.toString() ?? 'Unknown'}\nDate: $formattedTime'),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill),
                    color: Colors.blueAccent,
                    onPressed: () {
                      String? videoUrl = data['videoUrl'];
                      if (videoUrl != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlaybackScreen(videoUrl: videoUrl),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No video available to play')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPlaybackScreen extends StatelessWidget {
  final String videoUrl;

  const VideoPlaybackScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement video playback UI with a suitable video player plugin (e.g. chewie, video_player)
    return Scaffold(
      appBar: AppBar(title: const Text('Video Playback')),
      body: Center(child: Text('Video player for URL:\n$videoUrl')),
    );
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

class PerformanceView extends StatelessWidget {
  const PerformanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Center(child: Text('User not logged in'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('performances').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No performance data available'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // Access fields from data
        final score = data['score'] ?? 'N/A';
        final testType = data['testType'] ?? 'N/A';
        final timestamp = data['timestamp'] ?? 'N/A';
        final videoUrl = data['videoUrl'] ?? 'N/A';
        final cheatDetected = data['cheatDetected'] ?? false;

        final analysisResults = data['analysisResults'] as Map<String, dynamic>?;

        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: $score', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Test Type: $testType'),
                Text('Timestamp: $timestamp'),
                Text('Video URL: $videoUrl'),
                Text('Cheat Detected: ${cheatDetected ? "Yes" : "No"}'),
                SizedBox(height: 10),
                analysisResults != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exercise: ${analysisResults['exercise']}'),
                        Text('Exercise Confidence: ${analysisResults['exercise_confidence']}'),
                        Text('Tamper Label: ${analysisResults['tamper_label']}'),
                        Text('Tamper Confidence: ${analysisResults['tamper_confidence']}'),
                        Text('Tamper Scores:'),
                        ...((analysisResults['tamper_scores'] as Map<String, dynamic>).entries.map(
                          (e) => Text('${e.key}: ${e.value}'),
                        )),
                      ],
                    )
                  : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}

