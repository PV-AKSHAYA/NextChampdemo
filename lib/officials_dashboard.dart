// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'performance_service.dart';

// // class OfficialsDashboard extends StatefulWidget {
// //   @override
// //   _OfficialsDashboardState createState() => _OfficialsDashboardState();
// // }

// // class _OfficialsDashboardState extends State<OfficialsDashboard> {
// //   final PerformanceService _performanceService = PerformanceService();

// //   String? _selectedTestType;
// //   String? _selectedGender;
// //   String? _selectedAgeGroup;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Officials Dashboard')),
// //       body: Column(
// //         children: [
// //           // Filters (Dropdowns or TextFields)
// //           DropdownButton<String>(
// //             hint: Text('Select Test Type'),
// //             value: _selectedTestType,
// //             items: ['vertical_jump', 'shuttle_run', 'sit_ups'].map((String value) {
// //               return DropdownMenuItem(value: value, child: Text(value));
// //             }).toList(),
// //             onChanged: (val) => setState(() => _selectedTestType = val),
// //           ),
// //           DropdownButton<String>(
// //             hint: Text('Select Gender'),
// //             value: _selectedGender,
// //             items: ['male', 'female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
// //             onChanged: (val) => setState(() => _selectedGender = val),
// //           ),
// //           DropdownButton<String>(
// //             hint: Text('Select Age Group'),
// //             value: _selectedAgeGroup,
// //             items: ['12-15', '16-18', '19-22'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
// //             onChanged: (val) => setState(() => _selectedAgeGroup = val),
// //           ),
// //           Expanded(
// //             child: StreamBuilder<QuerySnapshot>(
// //               stream: _performanceService.getFilteredPerformances(
// //                 ageGroup: _selectedAgeGroup,
// //                 gender: _selectedGender,
// //                 testType: _selectedTestType,
// //               ),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }
// //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                   return Center(child: Text('No data found'));
// //                 }
// //                 final performances = snapshot.data!.docs;
// //                 return ListView.builder(
// //                   itemCount: performances.length,
// //                   itemBuilder: (context, index) {
// //                     var data = performances[index].data() as Map<String, dynamic>;
// //                     return ListTile(
// //                       title: Text('User ID: ${data['userId']}'),
// //                       subtitle: Text('Test: ${data['testType']}, Score: ${data['score']}'),
// //                       trailing: data['cheatDetected'] == true
// //                           ? Icon(Icons.warning, color: Colors.red)
// //                           : null,
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'performance_service.dart';

// class OfficialsDashboard extends StatefulWidget {
//   @override
//   _OfficialsDashboardState createState() => _OfficialsDashboardState();
// }

// class _OfficialsDashboardState extends State<OfficialsDashboard> {
//   final PerformanceService _performanceService = PerformanceService();

//   String? _selectedTestType;
//   String? _selectedGender;
//   String? _selectedAgeGroup;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Officials Dashboard')),
//       body: Column(
//         children: [
//           // Filters Row
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: DropdownButton<String>(
//                     hint: Text('Test Type'),
//                     value: _selectedTestType,
//                     isExpanded: true,
//                     items: ['vertical_jump', 'shuttle_run', 'sit_ups']
//                         .map((type) => DropdownMenuItem(
//                               value: type,
//                               child: Text(type),
//                             ))
//                         .toList(),
//                     onChanged: (val) => setState(() => _selectedTestType = val),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: DropdownButton<String>(
//                     hint: Text('Gender'),
//                     value: _selectedGender,
//                     isExpanded: true,
//                     items: ['male', 'female','other']
//                         .map((gender) => DropdownMenuItem(
//                               value: gender,
//                               child: Text(gender),
//                             ))
//                         .toList(),
//                     onChanged: (val) => setState(() => _selectedGender = val),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: DropdownButton<String>(
//                     hint: Text('Age Group'),
//                     value: _selectedAgeGroup,
//                     isExpanded: true,
//                     items: ['12-15', '16-18', '19-22']
//                         .map((age) => DropdownMenuItem(
//                               value: age,
//                               child: Text(age),
//                             ))
//                         .toList(),
//                     onChanged: (val) => setState(() => _selectedAgeGroup = val),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _performanceService.getFilteredPerformances(
//                 testType: _selectedTestType,
//                 gender: _selectedGender,
//                 ageGroup: _selectedAgeGroup,
//               ),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No data found'));
//                 }
//                 final performances = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: performances.length,
//                   itemBuilder: (context, index) {
//                     final data = performances[index].data() as Map<String, dynamic>;
//                     return ListTile(
//                       title: Text('User ID: ${data['userId'] ?? 'N/A'}'),
//                       subtitle: Text(
//                           'Test: ${data['testType'] ?? ''}, Score: ${data['score'] ?? 'N/A'}'),
//                       trailing: (data['cheatDetected'] == true)
//                           ? Icon(Icons.warning, color: Colors.red)
//                           : null,
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'performance_service.dart';

class OfficialsDashboard extends StatefulWidget {
  const OfficialsDashboard({Key? key}) : super(key: key);

  @override
  State<OfficialsDashboard> createState() => _OfficialsDashboardState();
}

class _OfficialsDashboardState extends State<OfficialsDashboard> {
  final PerformanceService _performanceService = PerformanceService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedTestType;
  String? _selectedGender;
  String? _selectedAgeGroup;

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    // Navigate to login route and clear stack, adjust '/' if your route differs
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officials Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdowns row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Test Type'),
                    value: _selectedTestType,
                    isExpanded: true,
                    items: ['curls', 'pushup', 'jumps','situps','squats']
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedTestType = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Gender'),
                    value: _selectedGender,
                    isExpanded: true,
                    items: ['male', 'female','other']
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Age Group'),
                    value: _selectedAgeGroup,
                    isExpanded: true,
                    items: ['12-15', '16-18', '19-22']
                        .map((age) => DropdownMenuItem<String>(
                              value: age,
                              child: Text(age),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedAgeGroup = val),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _performanceService.getFilteredPerformances(
                testType: _selectedTestType,
                gender: _selectedGender,
                ageGroup: _selectedAgeGroup,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data found'));
                }
                final performances = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: performances.length,
                  itemBuilder: (context, index) {
                    final data = performances[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('User ID: ${data['userId'] ?? 'N/A'}'),
                      subtitle: Text(
                          'Test: ${data['testType'] ?? ''}, Score: ${data['score'] ?? 'N/A'}'),
                      trailing: (data['cheatDetected'] == true)
                          ? const Icon(Icons.warning, color: Colors.red)
                          : null,
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
