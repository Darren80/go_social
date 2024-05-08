import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cache.dart';
import 'package:firebase_performance/firebase_performance.dart';

import 'firebase_service.dart';
import 'firebase_options.dart';
import 'notification_handler.dart';

import 'trip_plan.dart';
import 'login_screen.dart';
import 'create_trip_screen.dart';

Future<void> logToFile(dynamic thing) async {
  final directory = await Directory.systemTemp.createTemp('debug_logs_');
  final file = File('${directory.path}/debug_log.txt');

  // Convert 'thing' to a string and write/append it to the file.
  await file.writeAsString('${DateTime.now()}: $thing\n',
      mode: FileMode.append);
  print("Log file saved to: ${file.path}");
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Firebase Performance Analysis

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // Optionally, add code here to log the errors to an external service or storage
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final performance = FirebasePerformance.instance;

  // Request permission for notifications (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle incoming FCM notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Received FCM notification: ${message.notification?.title}');
    try {
      // Fetch the trip details using the tripId
      String tripId = message.data['tripId'];
      Trip trip = await Trip.fetchTrip(tripId);

      // Navigate to the appropriate screen based on the trip ID and requestee user ID
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ShareTripScreen(tripId: tripId),
        ),
      );

      // Show a notification with the trip title and creation date
      showNotification(
        'Trip Share Request',
        'Someone requested to share your trip called: ${trip.title} created on ${trip.createdAt}',
      );
    } catch (error) {
      // Handle any errors that occurred while fetching the trip details
      print('Failed to fetch trip details: $error');
      // Show a generic notification if the trip details couldn't be fetched
      showNotification(
        'Trip Share Request',
        'Someone requested to share a trip with you',
      );
    }
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onMessage.listen((RemoteMessage event) {});
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

  NotificationHandler.initialize();

  runApp(const MyApp());
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchService {
  final GoogleMapsPlaces places;
  SearchService(this.places);

  Future<List<Prediction>> fetchPlaces(String input) async {
    final response = await places.autocomplete(input);
    return response.predictions;
  }

  Future<PlacesDetailsResponse> fetchPlaceDetails(String placeId) async {
    return await places.getDetailsByPlaceId(placeId);
  }

  // Handles dynamic search predictions as user types
  void fetchPredictions(String value) async {
    if (value.isNotEmpty) {
      final predictions = await fetchPlaces(value);
      logToFile(predictions[0]);
      print("Predictions: $predictions");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyHomePage(title: 'Go Social');
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // State/Variables (put these in SQL DB later)
  List<Stop> _stops = [];
  Trip? _currentTrip;
  User? _user;

  final Set<Marker> _markers = {};
  Prediction? _selectedPrediction;
  DateTime _selectedDate = DateTime.now();
  bool _showPredictions = true;
  GoogleMapController? _mapController;
  final LatLng _center =
      const LatLng(45.521563, -122.677433); // Initial location
  List<Prediction> _currentPredictions = [];
  bool _isLoading = false;
  bool _isListening = false;
  final String _text = 'Press the button and start speaking';
  final _speech = stt.SpeechToText();
  final _debouncer = Debouncer(milliseconds: 500); // Adjust the delay as needed

  final _places =
      GoogleMapsPlaces(apiKey: "AIzaSyACUp2e0eMW5lbJIGx3CxmncPEv7ub99EM");
  final _searchService = SearchService(
    GoogleMapsPlaces(apiKey: "AIzaSyACUp2e0eMW5lbJIGx3CxmncPEv7ub99EM"),
  );
  StreamSubscription<String?>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _performAsyncWork();
    final Trace trace = FirebasePerformance.instance.newTrace('my_trace');
    trace.start();
  }

  void _performAsyncWork() async {
    _listenToAuthStateChanges();
    initUniLinks();
    final cacheManager = CacheManager();
    await cacheManager.connect('localhost', 6379);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _listenToAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        if (_user != null) {
          _saveFcmToken();
        }
      });
    });
  }

  Future<void> _saveFcmToken() async {
    print("+-+-+-+-+-Setting FCM+-+-+-+-+-+-");
    if (_user != null) {
      print("+-+-+-+-+-Setting FCM2+-+-+-+-+-+-");
      // Get the FCM token for the current device
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print(fcmToken);
      if (fcmToken != null) {
        // Save the FCM token to Firestore
        FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
          'fcmToken': fcmToken,
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> initUniLinks() async {
    uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        String tripId = uri.pathSegments.last;
        if (tripId.isNotEmpty) {
          try {
            Trip trip = await Trip.fetchTrip(tripId);
            // Get ID of trip owner
            String? ownerFcmToken = await FirebaseFirestore.instance
                .collection('users')
                .doc(trip.userId)
                .get()
                .then((doc) => doc.data()?['fcmToken'] as String?);
            if (ownerFcmToken != null) {
              await sendFcmNotification(
                ownerFcmToken,
                'Trip Accessed',
                'Someone accessed your trip: ${trip.title}',
                {'tripId': tripId},
              );
            }

            // Get your own FCM token
            String? myFcmToken = await FirebaseMessaging.instance.getToken();
            if (myFcmToken != null) {
              await sendFcmNotification(
                myFcmToken,
                'Trip Accessed',
                'You accessed a shared trip: ${trip.title}',
                {'tripId': tripId},
              );
            }

            // Navigate to the ShareTripScreen and pass the tripId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShareTripScreen(tripId: tripId),
              ),
            );
            print("Trip called");
          } catch (error) {
            print('Failed to handle trip share URL: $error');
          }
        }
      }
    }, onError: (err) {
      print('Failed to receive URI: $err');
    });
  }

  Future<void> sendFcmNotification(
    String token,
    String title,
    String body,
    Map<String, dynamic> data, {
    http.Client? client,
  }) async {
    const String serverKey =
        'AAAAW19xJrk:APA91bGcgqY2CknUP2tqGTGhSsfHnHIfSs6j3lAhHMY5D00CKO4-HQyyZXiU0qjHEgf-Fa-D2vw5V_bE7s6hllpqx2pAi6OXjivFyTCs-l9QUM6PSKra4hkx6VWz78HJr58ho6vJdc-r';
    const String apiUrl = 'https://fcm.googleapis.com/fcm/send';
    final Map<String, dynamic> payload = {
      'to': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': data,
    };

    final http.Client httpClient = client ?? http.Client();

    try {
      final http.Response response = await httpClient.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('FCM notification sent successfully');
      } else {
        print(
            'Failed to send FCM notification. Status code: ${response.statusCode}');
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  void _addStop(Stop newStop) {
    print(newStop.name);
    setState(() {
      _stops.add(newStop);
      _updateMarkers();
    });
  }

  void _updateStops(List<Stop> newStops) {
    setState(() {
      _stops = newStops;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    _markers.clear();
    for (var stop in _stops) {
      _markers.add(
        Marker(
          markerId: MarkerId(stop.name),
          position: LatLng(stop.latitude, stop.longitude),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: stop.date != null
                ? DateFormat('yyyy-MM-dd HH:mm').format(stop.date!)
                : '',
          ),
        ),
      );
    }
  }

  void _updateDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _createTrip() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );

    logToFile(result);

    if (result != null) {
      String title = result['title'];
      String description = result['description'];
      DateTime currentDate = DateTime.now();

      Trip newTrip = Trip(
        id: currentDate.millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        userId: _user!.uid,
        sharedWithUserIds: [],
        stops: [],
        createdAt: currentDate,
      );

      await Trip.createTrip(newTrip);

      setState(() {
        _currentTrip = newTrip;
      });

      logToFile(_currentTrip);
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red, // Optional: to emphasize the error
      ),
    );
  }

// This widget builds the search bar at the top of the screen.
  Widget _buildSearchBar() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(
            hintText: 'Search here...',
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            if (value == "") {
              setState(() {
                _currentPredictions.clear();
              });
            }
            setState(() {
              _showPredictions = true;
            });
            _debouncer.run(() {
              fetchPredictions(value);
            });
          },
          onFieldSubmitted: (value) {
            _debouncer.run(() {
              fetchPredictions(value);
              if (_currentPredictions.isNotEmpty) {
                _handleSearch(_currentPredictions[0]);
              } else {
                _showError(
                    'No area found for $value. Please refine your search.');
              }
              _showPredictions = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchTips() {
    return Visibility(
      visible: !_isLoading && _currentPredictions.isEmpty,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
            "Tip: Use specific keywords or locations to find better results.",
            textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildPredictionsList() {
    // Good UX
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Good UX
    if (_currentPredictions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No results found. Try different keywords.",
            textAlign: TextAlign.center),
      );
    }

    return Visibility(
      visible: _showPredictions && _currentPredictions.isNotEmpty,
      child: SizedBox(
        height: 200, // Set a fixed height or make it dynamic based on content
        child: ListView.builder(
          itemCount: _currentPredictions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_currentPredictions[index].description ??
                  'No description available'),
              onTap: () {
                _selectPrediction(_currentPredictions[index]);
                // Hide the predictions list once a prediction is tapped
                setState(() {
                  _showPredictions = false;
                });
              },
            );
          },
        ),
      ),
    );
  }

  void _selectPrediction(Prediction prediction) async {
    // Example: Fetch details and update the map
    final placeDetails =
        await _searchService.fetchPlaceDetails(prediction.placeId!);
    final lat = placeDetails.result.geometry?.location.lat;
    final lng = placeDetails.result.geometry?.location.lng;

    if (lat != null && lng != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(placeDetails.result.placeId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: placeDetails.result.name,
              snippet: placeDetails.result.formattedAddress,
            ),
          ),
        );
        _selectedPrediction = prediction;
      });
      _mapController!.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    }
  }

// Handles dynamic search predictions as user types
  void fetchPredictions(String value) async {
    setState(() {
      _isLoading = true; // Start loading
    });
    if (value.isNotEmpty) {
      final predictions = await _searchService.fetchPlaces(value);
      logToFile(predictions[0]);
      setState(() {
        _currentPredictions = predictions;
        _isLoading = false;
      });
      print("Predictions: $predictions");
    } else {
      setState(() {
        _currentPredictions = []; // Clear predictions if search query is empty
        _isLoading = false;
      });
    }
  }

// Handles the selection of a prediction
  void _handleSearch(Prediction prediction) async {
    final placeDetails =
        await _searchService.fetchPlaceDetails(prediction.placeId!);
    final lat = placeDetails.result.geometry?.location.lat;
    final lng = placeDetails.result.geometry?.location.lng;

    if (lat != null && lng != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(placeDetails.result.placeId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: placeDetails.result.name,
              snippet: placeDetails.result.formattedAddress,
            ),
          ),
        );
      });
      _mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseService().signOut();
                // Navigate to the login screen or perform any other necessary actions
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              } catch (error) {
                // Handle the error appropriately
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out Error'),
                      content: const Text(
                          'An error occurred while signing out. Please try again.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(), // Add a drawer
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Destination(
        updateStopsCallback: _updateStops,
        updateDateCallback: _updateDate,
        stops: _stops,
        onStopTapped: (latLng) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
        },
        updateMarkers: _updateMarkers,
      ), // Assuming Destination takes a callback
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.712776, -74.005974), // Default location
            zoom: 11.0,
          ),
          markers: _markers,
          polylines: _createPolylines(),
        ),
        _buildOverlayUI(),
      ],
    );
  }

  Set<Polyline> _createPolylines() {
    Set<Polyline> polylines = {};

    for (int i = 0; i < _stops.length - 1; i++) {
      final startStop = _stops[i];
      final endStop = _stops[i + 1];

      final polyline = Polyline(
        polylineId: PolylineId('route_$i'),
        points: [
          LatLng(startStop.latitude, startStop.longitude),
          LatLng(endStop.latitude, endStop.longitude),
        ],
        color: Colors.blue,
        width: 5,
        endCap: Cap.customCapFromBitmap(
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
      );

      polylines.add(polyline);
    }

    return polylines;
  }

  Widget _buildOverlayUI() {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        color: Colors.white.withOpacity(0.9),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTripNameDisplay(),
                ElevatedButton(
                  onPressed: _currentTrip != null
                      ? () {
                          Trip.shareOnSocialMedia(_currentTrip!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentTrip != null ? Colors.blue : Colors.grey,
                  ),
                  child: Text(
                    'Share Trip',
                    style: TextStyle(
                      color: _currentTrip != null ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            _buildSearchBar(),
            _buildSearchTips(),
            Row(
              children: [
                Expanded(
                  child: _selectedPrediction != null
                      ? Text(
                          _selectedPrediction!.description ?? '',
                          style: const TextStyle(fontSize: 16),
                        )
                      : Container(),
                ),
                _buildTripAddStopButtons(),
              ],
            ),
            _buildPredictionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripNameDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        "Trip Name: ${_currentTrip?.title ?? 'No active trip'}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Column _buildTripAddStopButtons() {
    return Column(
      children: [
        if (_currentTrip == null)
          ElevatedButton(
            onPressed: () {
              _createTrip();
            },
            child: const Text('Create Trip'),
          ),
        if (_currentTrip != null)
          AddStopButton(
            selectedPrediction: _selectedPrediction,
            searchService: _searchService,
            addStopCallback: _addStop,
            stops: _stops,
          ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _listen,
      tooltip: 'Listen',
      child: const Icon(Icons.mic),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {
            final String recognizedWords = val.recognizedWords;
            if (recognizedWords.isNotEmpty) {
              // Process the recognized words
              _processSpeechResult(recognizedWords);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _processSpeechResult(String recognizedWords) async {
    try {
      final predictions = await _searchService.fetchPlaces(recognizedWords);
      if (predictions.isEmpty) {
        _showSnackBar("No results found for \"$recognizedWords\".");
        return;
      }

      final details =
          await _places.getDetailsByPlaceId(predictions[0].placeId!);
      final lat = details.result.geometry?.location.lat;
      final lng = details.result.geometry?.location.lng;
      if (lat != null && lng != null) {
        _placeMarker(lat, lng);
      } else {
        _showSnackBar("Could not retrieve location details.");
      }
    } catch (e) {
      _showSnackBar("Error fetching place details: $e");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _placeMarker(double lat, double lng) {
    final markerId = MarkerId("marker_${lat}_$lng");
    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(title: "Destination"),
    );

    setState(() {
      _markers.add(marker);

      // Optionally, move the camera to the new marker
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 14.0,
          ),
        ),
      );
    });
  }
}

void showNotification(String title, String body) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidInitialize = const AndroidInitializationSettings('notification_icon');
  var initializationSettings =
      InitializationSettings(android: androidInitialize);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidDetails = const AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    // 'channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );
  var notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}
