// cache.dart

import 'dart:convert';
import 'package:redis/redis.dart';
import 'trip_plan.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  RedisConnection? _redisConnection;
  Command? _redisCommand;

Future<void> connect(String host, int port) async {
  try {
    _redisConnection = RedisConnection();
    _redisCommand = await _redisConnection!.connect(host, port);
  } catch (e) {
    print('Error connecting to Redis: $e');
    rethrow;
  }
}
Future<void> disconnect() async {
  try {
    await _redisConnection?.close();
  } catch (e) {
    print('Error disconnecting from Redis: $e');
  }
}

Future<void> addStopToTripCache(String tripId, Stop newStop) async {
  try {
    await _redisCommand?.send_object(['RPUSH', 'trip:$tripId:stops', jsonEncode(newStop.toJson())]);
    await _redisCommand?.send_object(['RPUSH', 'writeAheadLog:addStop', jsonEncode({'tripId': tripId, 'stop': newStop.toJson()})]);
  } catch (e) {
    print('Error adding stop to trip cache: $e');
  }
}

Future<void> removeStopFromTripCache(String tripId, Stop stop) async {
  try {
    await _redisCommand?.send_object(['LREM', 'trip:$tripId:stops', 0, jsonEncode(stop.toJson())]);
    await _redisCommand?.send_object(['RPUSH', 'writeAheadLog:removeStop', jsonEncode({'tripId': tripId, 'stop': stop.toJson()})]);
  } catch (e) {
    print('Error removing stop from trip cache: $e');
  }
}

Future<List<Stop>> getStopsForTrip(String tripId) async {
  try {
    final stopsJson = await _redisCommand?.send_object(['LRANGE', 'trip:$tripId:stops', 0, -1]);
    if (stopsJson != null) {
      return stopsJson.map((stopJson) => Stop.fromJson(jsonDecode(stopJson))).toList();
    }
  } catch (e) {
    print('Error retrieving stops for trip from cache: $e');
  }
  return [];
}

Future<void> addTripToCache(Trip trip) async {
  try {
    await _redisCommand?.send_object(['SET', 'trip:${trip.id}', jsonEncode(trip.toJson())]);
    await _redisCommand?.send_object(['RPUSH', 'writeAheadLog:addTrip', jsonEncode(trip.toJson())]);
  } catch (e) {
    print('Error adding trip to cache: $e');
  }
}

  Future<void> updateTripInCache(Trip trip) async {
    await _redisCommand?.send_object(['SET', 'trip:${trip.id}', jsonEncode(trip.toJson())]);
    await _redisCommand?.send_object(['RPUSH', 'writeAheadLog:updateTrip', jsonEncode(trip.toJson())]);
  }

  Future<void> removeTripFromCache(String tripId) async {
    await _redisCommand?.send_object(['DEL', 'trip:$tripId']);
    await _redisCommand?.send_object(['RPUSH', 'writeAheadLog:removeTrip', tripId]);
  }

  Future<Trip?> getTripFromCache(String tripId) async {
    final tripJson = await _redisCommand?.get('trip:$tripId');
    if (tripJson != null) {
      return Trip.fromJson(jsonDecode(tripJson));
    }
    return null;
  }

  Future<void> processWriteAheadLog() async {
    // Process the write-ahead log and perform necessary actions
    // Example:
    final addStopLogs = await _redisCommand?.send_object(['LRANGE', 'writeAheadLog:addStop', 0, -1]);
    final removeStopLogs = await _redisCommand?.send_object(['LRANGE', 'writeAheadLog:removeStop', 0, -1]);
    final addTripLogs = await _redisCommand?.send_object(['LRANGE', 'writeAheadLog:addTrip', 0, -1]);
    final updateTripLogs = await _redisCommand?.send_object(['LRANGE', 'writeAheadLog:updateTrip', 0, -1]);
    final removeTripLogs = await _redisCommand?.send_object(['LRANGE', 'writeAheadLog:removeTrip', 0, -1]);

    // Process each log entry and perform corresponding actions
    // Example:
    for (final log in addStopLogs!) {
      final logData = jsonDecode(log);
      final tripId = logData['tripId'];
      final stop = Stop.fromJson(logData['stop']);
      // Perform the action to add the stop to the trip in Firestore
      // ...
    }

    // Similarly, process other log entries (removeStop, addTrip, updateTrip, removeTrip)
    // ...

    // Clear the write-ahead log after processing
    await _redisCommand?.send_object(['DEL', 'writeAheadLog:addStop']);
    await _redisCommand?.send_object(['DEL', 'writeAheadLog:removeStop']);
    await _redisCommand?.send_object(['DEL', 'writeAheadLog:addTrip']);
    await _redisCommand?.send_object(['DEL', 'writeAheadLog:updateTrip']);
    await _redisCommand?.send_object(['DEL', 'writeAheadLog:removeTrip']);
  }
}