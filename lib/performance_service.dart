import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> addPerformance(String userId, Map<String, dynamic> data) async {
  try {
    await FirebaseFirestore.instance.collection('performances').add({
      'userId': userId,
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Performance added successfully");
  } catch (e) {
    print("Error adding performance: $e");
  }
}
Future<void> updateGamification(String userId, Map<String, dynamic> updates) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
}



Future<void> savePerformanceResult(String userId, Map<String, dynamic> data) async {
  try {
    await FirebaseFirestore.instance.collection('performances').add({
      ...data,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Performance saved successfully");
  } catch (e) {
    print("Failed to save performance: $e");
  }
}


  Future<void> savePerformance(Map<String, dynamic> performanceData) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  await FirebaseFirestore.instance
      .collection('performances')
      .doc(userId)
      .set(performanceData, SetOptions(merge: true));
}


// class PerformanceService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Stream of users filtered by age range and gender
//   Stream<QuerySnapshot> getUsersByAgeGender({required int minAge, required int maxAge, required String gender}) {
//     return _firestore
//         .collection('users')
//         .where('age', isGreaterThanOrEqualTo: minAge)
//         .where('age', isLessThanOrEqualTo: maxAge)
//         .where('gender', isEqualTo: gender)
//         .snapshots();
//   }

//   // Stream of performances filtered by test type and optionally cheatDetected status
//   Stream<QuerySnapshot> getPerformancesByTestType({required String testType, bool? cheatStatus}) {
//     Query query = _firestore.collection('performances').where('testType', isEqualTo: testType);
//     if (cheatStatus != null) {
//       query = query.where('cheatDetected', isEqualTo: cheatStatus);
//     }
//     return query.snapshots();
//   }

//   // Stream user performances by userId with sorting by timestamp descending
//   Stream<QuerySnapshot> getPerformancesByUser(String userId) {
//     return _firestore
//         .collection('performances')
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }
// }


class PerformanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFilteredPerformances({
    String? ageGroup,
    String? gender,
    String? testType,
  }) {
    Query query = _firestore.collection('performances');

    if (testType != null && testType.isNotEmpty) {
      query = query.where('testType', isEqualTo: testType);
    }

    // NOTE: Assuming ageGroup and gender fields exist in the performances document for filtering.
    if (ageGroup != null && ageGroup.isNotEmpty) {
      query = query.where('ageGroup', isEqualTo: ageGroup);
    }

    if (gender != null && gender.isNotEmpty) {
      query = query.where('gender', isEqualTo: gender);
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }
}