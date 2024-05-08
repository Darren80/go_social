import 'package:mysql1/mysql1.dart';
import 'package:flutter/material.dart';

class UserProfile {
  final String userId;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime lastLogin;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'last_login': lastLogin.toIso8601String(),
    };
  }

  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: '',
      db: 'your_database',
    );
    return await MySqlConnection.connect(settings);
  }

  static Future<void> createTable() async {
    final conn = await getConnection();
    await conn.query('''
      CREATE TABLE IF NOT EXISTS user_profiles (
        user_id INT AUTO_INCREMENT PRIMARY KEY,
        email TEXT,
        name TEXT,
        photo_url TEXT,
        last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    ''');
    await conn.close();
  }

  static Future<void> insertUserProfile(UserProfile userProfile) async {
    final conn = await getConnection();
    await conn.query(
      'INSERT INTO user_profiles (email, name, photo_url) VALUES (?, ?, ?)',
      [userProfile.email, userProfile.name, userProfile.photoUrl],
    );
    await conn.close();
  }

  static Future<UserProfile?> getUserProfile(int userId) async {
    final conn = await getConnection();
    final results = await conn.query(
      'SELECT * FROM user_profiles WHERE user_id = ?',
      [userId],
    );
    await conn.close();

    if (results.isNotEmpty) {
      final row = results.first;
      return UserProfile(
        userId: row['user_id'],
        email: row['email'],
        name: row['name'],
        photoUrl: row['photo_url'],
        lastLogin: row['last_login'],
      );
    }

    return null;
  }
}

class UserProfileScreen extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfileScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display user profile information
            Text('User ID: ${userProfile.userId}'),
            Text('Email: ${userProfile.email}'),
            Text('Name: ${userProfile.name}'),
            // Add more profile fields as needed
          ],
        ),
      ),
    );
  }
}