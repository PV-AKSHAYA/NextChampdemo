import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserPerformances() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('performances')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login'); // Or navigate to login screen
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserPerformances(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No performances found'));
          }
          final performances = snapshot.data!.docs;
          return ListView.builder(
            itemCount: performances.length,
            itemBuilder: (context, index) {
              final data = performances[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Test: ${data['testType'] ?? 'N/A'}'),
                subtitle: Text('Score: ${data['score'] ?? 'N/A'}'),
                trailing: data['cheatDetected'] == true
                    ? Icon(Icons.warning, color: Colors.red)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
