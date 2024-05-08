import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:go_social/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widget_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  // late MockFirebaseAuth mockFirebaseAuth;

  // setUp(() async {
  //   mockFirebaseAuth = MockFirebaseAuth();
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // });

  // testWidgets('Login with valid credentials', (WidgetTester tester) async {
  //   try {
  //     await tester.pumpWidget(
  //       MaterialApp(
  //         home: LoginScreen(),
  //       ),
  //     );

  //     // Print the widget tree before entering the credentials
  //     print('Widget tree before login:');
  //     debugPrint(tester.elementList(find.byType(LoginScreen)).toString());

  //     // Enter valid email and password
  //     await tester.enterText(
  //         find.byKey(Key('emailField')), 'we444465@gmail.com');
  //     await tester.enterText(find.byKey(Key('passwordField')), 'asdfghjkl');

  //     // Tap the login button
  //     await tester.tap(find.byKey(Key('loginButton')));
  //     await tester.pumpAndSettle();

  //     // Print the widget tree before entering the credentials
  //     print('Widget tree after login:');
  //     debugPrint(tester.elementList(find.byType(MyHomePage)).toString());

  //     // Verify that the login is successful and the user is navigated to the home screen
  //     expect(find.byType(MyHomePage), findsOneWidget);
  //   } catch (e) {
  //     // Ignore any exceptions that occur during the test execution
  //     print('Exception occurred during the test: $e');
  //   }
  // });

  group('MyHomePageState', () {
    test('sendFcmNotification should send notification successfully', () async {
      const String token = 'mock_token';
      const String title = 'Test Title';
      const String body = 'Test Body';
      final Map<String, dynamic> data = {'key': 'value'};

      final mockClient = MockClient();
      final myHomePageState = MyHomePageState();

      // Mock the post method of the mock client
      when(mockClient.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 200));

      // Call the function
      await myHomePageState.sendFcmNotification(token, title, body, data,
          client: mockClient);

      // Verify that post was called with the correct arguments
      verify(mockClient.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAW19xJrk:APA91bGcgqY2CknUP2tqGTGhSsfHnHIfSs6j3lAhHMY5D00CKO4-HQyyZXiU0qjHEgf-Fa-D2vw5V_bE7s6hllpqx2pAi6OXjivFyTCs-l9QUM6PSKra4hkx6VWz78HJr58ho6vJdc-r',
        },
        body: json.encode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data,
        }),
      )).called(1);
    });
  });
}

class MockUserCredential extends Mock implements UserCredential {}

class MockDataSnapshot extends Mock implements DataSnapshot {
  final Map<dynamic, dynamic> _data;

  MockDataSnapshot(this._data);

  @override
  Map<dynamic, dynamic> get value => _data;
}
