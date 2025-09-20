import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> refreshUserIdToken() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.getIdToken(true); // Forces refresh of ID token with latest claims
  }
}

// Future<bool> isUserAdmin() async {
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     return false;
//   }
//   final idTokenResult = await user.getIdTokenResult();
//   return idTokenResult.claims?['admin'] == true;
// }


Future<void> checkUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final idTokenResult = await user.getIdTokenResult();
    bool isAdmin = idTokenResult.claims?['admin'] == true;
    if (isAdmin) {
      // Show admin UI or enable admin features
      print('User is an admin');
    } else {
      // Show regular user UI
      print('User is not an admin');
    }
  }
}

Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).set(data, SetOptions(merge: true));
}


Future<User?> signInWithEmailAndPassword(String email, String password, VoidCallback onAuthSuccess) async {
  try {
    UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    onAuthSuccess();
    return result.user;
  } catch (e) {
    print('Login failed: $e');
    return null;
  }
}

Future<User?> registerWithEmailAndPassword(String email, String password, VoidCallback onAuthSuccess) async {
  try {
    UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    onAuthSuccess();
    return result.user;
  } catch (e) {
    print('Registration failed: $e');
    return null;
  }
}

Future<void> saveUserData(String name, String email, int age, String gender, String mobile) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'mobile': mobile,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}


Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  print('User logged out');
}



class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  AuthScreen({required this.onAuthSuccess, Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _pageController = PageController();

  void _goToRegister() =>
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  void _goToLogin() =>
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            LoginPage(onRegisterTap: _goToRegister, onLoginSuccess: widget.onAuthSuccess),
            RegisterPage(onLoginTap: _goToLogin, onRegisterSuccess: widget.onAuthSuccess),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onLoginSuccess;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({
    required this.onRegisterTap,
    required this.onLoginSuccess,
    Key? key,
  }) : super(key: key);

  Future<bool> isUserAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    final idTokenResult = await user.getIdTokenResult();
    return idTokenResult.claims?['admin'] == true;
  }

  // Dummy signInWithEmailAndPassword method — replace with your actual Firebase login logic
  Future<User?> signInWithEmailAndPassword(
      String email, String password, VoidCallback onLoginSuccess) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      onLoginSuccess();
      return credential.user;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Login', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val != null && val.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                    validator: (val) => val != null && val.length >= 6 ? null : 'Enter min 6 characters',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = await signInWithEmailAndPassword(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          () async {
                            bool isAdmin = await isUserAdmin();
                            if (isAdmin) {
                              print('User is admin/official');
                              // TODO: Add your admin-specific logic here,
                              // e.g., navigate to admin dashboard or set admin state
                              Navigator.pushReplacementNamed(context, '/officialsDashboard');
                            } else {
                              print('User is a regular athlete');
                              Navigator.pushReplacementNamed(context, '/userDashboard');
                            }
                            onLoginSuccess();
                            Navigator.pushReplacementNamed(context, '/home');  // Call the original success callback
                          },
                        );

                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login failed. Please check your credentials.')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    child: const Text('Don’t have an account? Register'),
                    onPressed: onRegisterTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterSuccess;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterPage({
    required this.onLoginTap,
    required this.onRegisterSuccess,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Register', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Enter your name',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter your age';
                      final age = int.tryParse(val);
                      if (age == null || age <= 0) return 'Enter valid age';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) => genderController.text = value ?? '',
                    validator: (val) => val == null || val.isEmpty ? 'Select gender' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter mobile number';
                      if (!RegExp(r'^\d{10}$').hasMatch(val)) return 'Enter valid 10-digit number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val != null && val.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val != null && val.length >= 6 ? null : 'Enter min 6 characters',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Add your registration logic here
                            final user = await registerWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim(), onRegisterSuccess);
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Registration failed. Please try again.')),

                               );
                                } else {
                                  await saveUserData(
                                    nameController.text.trim(),
                                    emailController.text.trim(),
                                    int.parse(ageController.text.trim()),
                                    genderController.text.trim(),
                                    mobileController.text.trim(),
                                  );
                                  Navigator.pushReplacementNamed(context, '/home');
                                  print('User registered and data saved');
                               }
                               }
                    }
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    child: const Text('Already have an account? Login'),
                    onPressed: onLoginTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
