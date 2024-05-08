import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:go_social/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widget_test.mocks.dart';

@GenerateMocks([http.Client])
@GenerateMocks([User])
@GenerateMocks([SearchService])
@GenerateMocks([Prediction])
void main() {
  final myHomePageState = MyHomePageState();
  myHomePageState.isTestEnvironment = true;

  group('MyHomePageState', () {
    test('sendFcmNotification should send notification successfully', () async {
      const String token = 'mock_token';
      const String title = 'Test Title';
      const String body = 'Test Body';
      final Map<String, dynamic> data = {'key': 'value'};

      final mockClient = MockClient();

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

    test('_createTrip should create a new trip', () async {
      final mockUser = MockUser();

      // Set up the mock user
      when(mockUser.uid).thenReturn('test_user_id');
      myHomePageState.user = mockUser;

      // Set up the mock result from CreateTripScreen
      final result = {
        'title': 'Test Trip',
        'description': 'Test Description',
      };

      // Call the function
      final trip = await myHomePageState?.createTrip(true);

      // Verify that the trip was created with the correct data
      expect(trip, isNotNull);
      expect(trip!.title, 'Test Trip');
      expect(trip!.description, 'Test Description');
      expect(trip!.userId, 'test_user_id');
      expect(trip!.sharedWithUserIds, isEmpty);
      expect(trip!.stops, isEmpty);
    });

    test('fetchPredictions should update predictions based on search query',
        () async {
      final mockSearchService = MockSearchService();

      // Set up the mock search service
// Set up the mock search service
      when(mockSearchService.fetchPlaces('test')).thenAnswer((_) async => [
            Prediction(
              description: 'Test Description',
              id: 'test_id',
              matchedSubstrings: [],
              placeId: 'test_place_id',
              reference: 'test_reference',
              structuredFormatting: StructuredFormatting(
                mainText: 'Test Main Text',
                secondaryText: 'Test Secondary Text',
              ),
              terms: [],
              types: [],
            ),
          ]);

      // Call the function with a search query
      await myHomePageState.fetchPredictions('test', mockSearchService);

      // Verify that predictions were updated
      expect(myHomePageState.currentPredictions, hasLength(1));
      expect(myHomePageState.currentPredictions[0].placeId, 'test_place_id');

      // Call the function with an empty search query
      await myHomePageState.fetchPredictions('', mockSearchService);

      // Verify that predictions were cleared
      expect(myHomePageState.currentPredictions, isEmpty);
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
