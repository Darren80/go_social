import 'main.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';

class Destination extends StatelessWidget {
  final List<Stop> stops;
  final Function(List<Stop>) updateStopsCallback;
  final Function(DateTime) updateDateCallback;
  final Function(LatLng) onStopTapped;

  Destination({
    required this.updateStopsCallback,
    required this.updateDateCallback,
    required this.stops,
    required this.onStopTapped,
  });

  // Existing methods remain as they are...

  Widget _buildStopList() {
    return ListView.builder(
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        return ListTile(
          title: Text(stop.name),
          subtitle: Text(
            stop.date != null ? DateFormat('yyyy-MM-dd HH:mm').format(stop.date!) : '',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
            ),
          ),
          onTap: () {
            onStopTapped(LatLng(stop.latitude, stop.longitude));
          },
          trailing: IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              // Remove the stop from the list
              print("Removing...");
              List<Stop> updatedStops = List.from(stops);
              updatedStops.removeAt(index);
              updateStopsCallback(updatedStops);
            },
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

  final List<Prediction> currentPredictions;
  final SearchService searchService;
  final Function(Stop) addStopCallback;
  final List<Stop> stops;

  AddStopButton({
    required this.currentPredictions,
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
          if (currentPredictions.isNotEmpty) {
            final firstPrediction = currentPredictions.first;

            try {
              // Fetch the details of the first prediction
              final placeDetails = await searchService.fetchPlaceDetails(firstPrediction.placeId ?? '');

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
                                  ? 'Previous Stop: ${stops[stops.length - 1].name} (${_formatDateTime(stops[stops.length - 1].date)})'
                                  : 'Previous Stop: N/A',
                            ),
                            SizedBox(height: 16),
                            Text('Select Date:'),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDateTime = await _selectDate(context);

                                if (pickedDateTime != null) {
                                  final TimeOfDay? pickedTime = await _selectTime(context);

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
                                      pickedDate = null; // Reset the picked date
                                    }
                                  }
                                }
                              },
                              child: Text(
                                pickedDate != null
                                    ? DateFormat('yyyy-MM-dd HH:mm').format(pickedDate!)
                                    : 'Tap to select date and time',
                                style: TextStyle(
                                  color: pickedDate != null ? Colors.black : Colors.grey,
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

                // Add the new stop
                addStopCallback(newStop);
              }

            } catch (error) {
              // Show an error dialog if an exception occurs
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('An error occurred while fetching place details.'),
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
        content: Text('The selected date must be after the previous stop\'s date.'),
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

  Stop({required this.name, required this.latitude, required this.longitude, this.date, this.predictionDetails});

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
}