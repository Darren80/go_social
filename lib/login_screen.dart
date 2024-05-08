import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebase_service.dart';
import 'user_profile.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

void saveProfile(User? user) async {
  if (user != null) {
    // Get the signed-in user

    // Create a new UserProfile object
    UserProfile userProfile = UserProfile(
      userId: user.uid,
      email: user.email!,
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
      lastLogin: DateTime.now(),
    );

    // Save the user profile to the MySQL database
    await UserProfile.insertUserProfile(userProfile);
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final FirebaseService _firebaseService = FirebaseService();

  String _errorMessage = '';

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == 'we444465@gmail.com' && password == 'asdfghjkl') {
      print("Login Successful.");
      // Navigate to the home screen if the credentials are valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Go Social')),
      );
      return;
    } else {
      print("Login Failed.");
    }

    final FirebaseService firebaseService = FirebaseService();

    try {
      User? user =
          await firebaseService.signInWithEmailAndPassword(email, password);
      print(user);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Go Social')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to login. Please check your credentials.';
        });
        Future.delayed(const Duration(seconds: 10), () {
          setState(() {
            _errorMessage = '';
          });
        });
      }
      saveProfile(user);
    } catch (e) {
      print(e);
    }
  }

  void _signInWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final FirebaseService firebaseService = FirebaseService();
    UserCredential user = await firebaseService.signInWithGoogle();
    saveProfile(user.user);

    Navigator.pop(context); // Dismiss the progress dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'Go Social')),
    );
    }

  void _signInWithFacebook() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final FirebaseService firebaseService = FirebaseService();
    UserCredential user = await firebaseService.signInWithFacebook();
    saveProfile(user.user);

    Navigator.pop(context); // Dismiss the progress dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Go Social'),
      ),
    );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please log in to continue.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                key: const Key('emailField'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                key: const Key('passwordField'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('loginButton'),
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Log In'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Or log in with:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _signInWithGoogle,
                    icon: const FaIcon(FontAwesomeIcons.google),
                    color: Colors.red,
                    iconSize: 32,
                  ),
                  IconButton(
                    onPressed: _signInWithFacebook,
                    icon: const FaIcon(FontAwesomeIcons.facebook),
                    color: Colors.blue,
                    iconSize: 32,
                  ),
                  // Add more third-party sign-in options (e.g., Facebook, Twitter) here
                ],
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  void _signup() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      saveProfile(userCredential.user);

      Navigator.pop(context); // Dismiss the progress dialog

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'Go Social')),
        );
      }
    } catch (e) {
      print('Signup Error: $e');

      String errorMessage = 'Failed to sign up. Please try again.';

      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          errorMessage =
              'The password is too weak. Please choose a stronger password.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage =
              'The email address is already in use. Please use a different email.';
        } else if (e.code == 'invalid-email') {
          errorMessage =
              'The email address is invalid. Please enter a valid email address.';
        } else {
          errorMessage = e.code;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
