import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';

import 'trip_plan.dart';

Future<void> logToFile(dynamic thing) async {
  final directory = await Directory.systemTemp.createTemp('debug_logs_');
  final file = File('${directory.path}/debug_log.txt');

  // Convert 'thing' to a string and write/append it to the file.
  await file.writeAsString('${DateTime.now()}: $thing\n',
      mode: FileMode.append);
  print("Log file saved to: ${file.path}");
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // Optionally, you can add code here to log the errors to an external service or storage
  };

  runApp(MyApp());
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
      home: const MyHomePage(title: 'Flutter Voice Home Page'),
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
  Set<Marker> _markers = {};
  DateTime _selectedDate = DateTime.now();
  bool _showPredictions = true;
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433); // Initial location
  List<Prediction> _currentPredictions = [];
  bool _isLoading = false;
  final _places = GoogleMapsPlaces(apiKey: "AIzaSyACUp2e0eMW5lbJIGx3CxmncPEv7ub99EM");
  final _searchService = SearchService(
    GoogleMapsPlaces(apiKey: "AIzaSyACUp2e0eMW5lbJIGx3CxmncPEv7ub99EM"),
  );
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  final _debouncer = Debouncer(milliseconds: 500); // Adjust the delay as needed

  @override
  void initState() {
    super.initState();
  }

  void _addStop(Stop newStop) {
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
            snippet: stop.date != null ? DateFormat('yyyy-MM-dd HH:mm').format(stop.date!) : '',
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
        duration: Duration(seconds: 3),
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
          decoration: InputDecoration(
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
      return Center(child: CircularProgressIndicator());
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
      child: Container(
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
        Prediction _selectedPrediction = _currentPredictions.first;
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
      ), // Assuming Destination takes a callback
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
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
      endCap: Cap.customCapFromBitmap(BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
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
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchBar(),
            _buildSearchTips(),
            AddStopButton(
              currentPredictions: _currentPredictions,
              searchService: _searchService,
              addStopCallback: (Stop stop) {
                _addStop(stop);
              },
              stops: _stops,
            ), // Positioned correctly with good UX
            _buildPredictionsList(),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _listen,
      tooltip: 'Listen',
      child: Icon(Icons.mic),
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

      final details = await _places.getDetailsByPlaceId(predictions[0].placeId!);
      final lat = details.result.geometry?.location?.lat;
      final lng = details.result.geometry?.location?.lng;
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
      infoWindow: InfoWindow(title: "Destination"),
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