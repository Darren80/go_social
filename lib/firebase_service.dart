import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// ...

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }


Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    // Handle authentication errors
    return null;
  }
}
}

StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
    if (snapshot.connectionState == ConnectionState.active) {
      User? user = snapshot.data;
      if (user == null) {
        // User is signed out
        return LoginScreen();
      } else {
        // User is signed in
        return HomeScreen();
      }
    }
    return CircularProgressIndicator();
  },
)

