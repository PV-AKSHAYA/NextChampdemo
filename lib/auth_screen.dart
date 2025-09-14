import 'package:flutter/material.dart';

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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Add your login logic here
                        onLoginSuccess();
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
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        // Add your registration logic here
                        onRegisterSuccess();
                      }
                    },
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
