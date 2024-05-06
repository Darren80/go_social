import 'package:flutter/material.dart';
import 'package:go_social/trip_plan.dart';

class CreateTripScreen extends StatefulWidget {
  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tripTitle = '';
  String _tripDescription = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context)
          .pop({'title': _tripTitle, 'description': _tripDescription});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Trip'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Trip Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _tripTitle = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Trip Description'),
                onSaved: (value) {
                  _tripDescription = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShareTripScreen extends StatefulWidget {
  final String tripId;

  ShareTripScreen({required this.tripId});

  @override
  _ShareTripScreenState createState() => _ShareTripScreenState();
}

class _ShareTripScreenState extends State<ShareTripScreen> {
  late Future<Trip> _tripFuture;

  @override
  void initState() {
    super.initState();
    _tripFuture = Trip.fetchTrip(widget.tripId);
  }

  void _loadTrip(Trip trip) async {
    try {
      // Update the trip's sharedWithUserIds field to include the current user
      // await Trip.shareTrip(trip.id, widget.requesteeUserId);

      // Show a success message or perform any other desired action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip loaded successfully')),
      );

      // Navigate back to the previous screen or to the trip details screen
      Navigator.pop(context);
      // or
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => TripDetailsScreen(tripId: trip.id),
      //   ),
      // );
    } catch (error) {
      // Handle any errors that occurred during the trip loading process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trip')),
      );
    }
  }

  void _doNotLoadTrip() {
    // Navigate back to the previous screen
    Navigator.pop(context);

    // Show a message or perform any other desired action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip not loaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: FutureBuilder<Trip>(
        future: _tripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Trip trip = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display trip details
                  Text(
                    'Trip: ${trip.title}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Description: ${trip.description}'),
                  SizedBox(height: 16),
                  // Display "Load" and "Do not load" buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _loadTrip(trip),
                        child: Text('Load'),
                      ),
                      ElevatedButton(
                        onPressed: _doNotLoadTrip,
                        child: Text('Do not load'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
