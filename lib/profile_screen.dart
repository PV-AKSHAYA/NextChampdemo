import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot> getUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }
  throw Exception('User not logged in');
}

class ProfileScreen extends StatelessWidget {
  final String userId;
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found.'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          // body: Center(child: Text('Profile data for user: $userId')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name']}'),
                Text('Email: ${userData['email']}'),
                Text('Age: ${userData['age']}'),
                Text('Gender: ${userData['gender']}'),
                Text('Mobile: ${userData['mobile']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
