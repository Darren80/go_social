import 'main.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Trip {
  final String id;
  final String title;
  final String description;
  final String userId;
  final List<String> sharedWithUserIds;
  final List<Stop> stops;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.sharedWithUserIds,
    required this.stops,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      sharedWithUserIds: List<String>.from(json['sharedWithUserIds']),
      stops: List<Stop>.from(
        json['stops'].map((stopJson) => Stop.fromJson(stopJson)),
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'sharedWithUserIds': sharedWithUserIds,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a new Trip
  static Future<void> createTrip(Trip trip) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _tripsCollection = _firestore.collection('trips');
    await _tripsCollection.add(trip.toJson());
  }

  // Get Trips shared with a specific user
  // static Future<List<Trip>> getSharedTrips(String userId) async {
  //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //   final CollectionReference _tripsCollection = _firestore.collection('trips');
  //   QuerySnapshot snapshot = await _tripsCollection
  //       .where('sharedWithUserIds', arrayContains: userId)
  //       .get();
  //   List<Trip> trips = snapshot.docs.map((doc) {
  //     return Trip.fromJson(doc.data() as Map<String, dynamic>);
  //   }).toList();
  //   return trips;
  // }

// Fetch a Trip by its ID
  static Future<Trip> fetchTrip(String tripId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final DocumentReference _tripDoc =
        _firestore.collection('trips').doc(tripId);
    DocumentSnapshot snapshot = await _tripDoc.get();
    if (snapshot.exists) {
      return Trip.fromJson(snapshot.data() as Map<String, dynamic>);
    } else {
      throw Exception('Trip not found');
    }
  }

  // Share a Trip with another user
  static Future<void> shareTrip(String tripId, String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _tripsCollection = _firestore.collection('trips');
    await _tripsCollection.doc(tripId).update({
      'sharedWithUserIds': FieldValue.arrayUnion([userId]),
    });
  }

  // Share a Trip on social media
  static Future<void> shareOnSocialMedia(Trip trip) async {
    String deepLinkUrl = 'gosocial://trip/${trip.id}';

    String shareText =
        'Check out this amazing trip I created using the Go Social app!\n\n';
    shareText += 'Trip: ${trip.title}\n';
    shareText += 'Description: ${trip.description}\n\n';
    shareText += 'Stops:\n';
    for (var stop in trip.stops) {
      shareText += '- ${stop.name}\n';
    }

    String shareUrl = 'https://your-app-url.com/trip/${trip.id}';

    await Share.share(
      '$shareText\n$deepLinkUrl',
      subject: 'Check out this trip on Go Social!',
    );
  }
}


class Destination extends StatelessWidget {
  final List<Stop> stops;
  final Function(List<Stop>) updateStopsCallback;
  final Function(DateTime) updateDateCallback;
  final Function(LatLng) onStopTapped;
  final Function() updateMarkers;

  Destination({
    required this.updateStopsCallback,
    required this.updateDateCallback,
    required this.stops,
    required this.onStopTapped,
    required this.updateMarkers,
  });

  Widget _buildStopList() {
    return ReorderableListView.builder(
      itemCount: stops.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final Stop stop = stops.removeAt(oldIndex);
        stops.insert(newIndex, stop);
        updateStopsCallback(stops);
        updateMarkers(); // Add this line
      },
      itemBuilder: (context, index) {
        final stop = stops[index];
        return ListTile(
          key: ValueKey(stop),
          title: Text(stop.name),
          subtitle: Text(
            stop.date != null
                ? DateFormat('yyyy-MM-dd HH:mm').format(stop.date!)
                : '',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
            ),
          ),
          onTap: () {
            onStopTapped(LatLng(stop.latitude, stop.longitude));
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: stop.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    final TimeOfDay? newTime = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay.fromDateTime(stop.date ?? DateTime.now()),
                    );
                    if (newTime != null) {
                      final DateTime updatedDate = DateTime(
                        newDate.year,
                        newDate.month,
                        newDate.day,
                        newTime.hour,
                        newTime.minute,
                      );
                      final Stop updatedStop = stop.copyWith(date: updatedDate);
                      stops[index] = updatedStop;
                      updateStopsCallback(stops);
                      updateMarkers(); // Add this line
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  print("Removing...");
                  List<Stop> updatedStops = List.from(stops);
                  updatedStops.removeAt(index);
                  updateStopsCallback(updatedStops);
                  updateMarkers(); // Add this line
                },
              ),
              Icon(Icons.reorder),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
        ),
        Expanded(child: _buildStopList()),
      ],
    );
  }
}

class AddStopButton extends StatelessWidget {
  final Prediction? selectedPrediction;
  final SearchService searchService;
  final Function(Stop) addStopCallback;
  final List<Stop> stops;

  AddStopButton({
    required this.selectedPrediction,
    required this.searchService,
    required this.addStopCallback,
    required this.stops,
  });

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () async {
            if (selectedPrediction == true) {
              try {
                // Fetch the details of the first prediction
                final placeDetails = await searchService
                    .fetchPlaceDetails(selectedPrediction!.placeId ?? '');
                // Extract the relevant details from the PlacesDetailsResponse
                final name = placeDetails.result.name;
                final latitude = placeDetails.result.geometry!.location.lat;
                final longitude = placeDetails.result.geometry!.location.lng;

                // Show a custom modal dialog
                final selectedDate = await showDialog<DateTime>(
                  context: context,
                  builder: (context) {
                    DateTime? pickedDate;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Add Stop'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stop Name: $name'),
                              SizedBox(height: 8),
                              Text(
                                stops.isNotEmpty
                                    ? 'Previous Stop: ${stops.last.name} (${_formatDateTime(stops.last.date)})'
                                    : 'Previous Stop: N/A',
                              ),
                              SizedBox(height: 16),
                              Text('Select Date:'),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final DateTime? pickedDateTime =
                                      await _selectDate(context);

                                  if (pickedDateTime != null) {
                                    final TimeOfDay? pickedTime =
                                        await _selectTime(context);

                                    if (pickedTime != null) {
                                      pickedDate = DateTime(
                                        pickedDateTime.year,
                                        pickedDateTime.month,
                                        pickedDateTime.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                      setState(() {});

                                      if (!_isValidDate(pickedDate!)) {
                                        await _showInvalidDateDialog(context);
                                        pickedDate =
                                            null; // Reset the picked date
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  pickedDate != null
                                      ? DateFormat('yyyy-MM-dd HH:mm')
                                          .format(pickedDate!)
                                      : 'Tap to select date and time',
                                  style: TextStyle(
                                    color: pickedDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: pickedDate != null
                                  ? () {
                                      Navigator.of(context).pop(pickedDate);
                                    }
                                  : null,
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                if (selectedDate != null) {
                  // Create a new Stop object with the extracted details and selected date
                  final newStop = Stop(
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    date: selectedDate,
                  );

                  // Add the new stop to the list of stops
                  addStopCallback(newStop);
                }
              } catch (error) {
                // Show an error dialog if an exception occurs
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text(
                          'An error occurred while fetching place details.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          child: Text('Add Stop'),
        ),
      ),
    );
  }

// Helper methods

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  bool _isValidDate(DateTime pickedDate) {
    return stops.isEmpty || pickedDate.isAfter(stops[stops.length - 1].date!);
  }

  Future<void> _showInvalidDateDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Date'),
          content: Text(
              'The selected date must be after the previous stop\'s date.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class Stop {
  String name;
  double latitude;
  double longitude;
  DateTime? date;
  Prediction? predictionDetails;

  Stop(
      {required this.name,
      required this.latitude,
      required this.longitude,
      this.date,
      this.predictionDetails});

  String getPreviousStopName(List<Stop> stops) {
    final currentIndex = stops.indexWhere((stop) => stop.name == name);
    final previousStopIndex = currentIndex - 1;
    return previousStopIndex >= 0 ? stops[previousStopIndex].name : 'N/A';
  }

  String getNextStopName(List<Stop> stops) {
    final currentIndex = stops.indexWhere((stop) => stop.name == name);
    final nextStopIndex = currentIndex + 1;
    return nextStopIndex < stops.length ? stops[nextStopIndex].name : 'N/A';
  }

  // Create Stop object from JSON
  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      predictionDetails: json['predictionDetails'] != null
          ? Prediction.fromJson(json['predictionDetails'])
          : null,
    );
  }

  // Convert Stop object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'date': date?.toIso8601String(),
      'predictionDetails': predictionDetails?.toJson(),
    };
  }

  Stop copyWith({
    String? name,
    double? latitude,
    double? longitude,
    DateTime? date,
  }) {
    return Stop(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
    );
  }
}
