import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationException implements Exception {
  LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  /// Requests OS/browser permission when needed, then returns a high-accuracy fix.
  Future<Position> getCurrentLocation() async {
    if (!kIsWeb) {
      final handled = await Permission.locationWhenInUse.request();
      if (!handled.isGranted) {
        if (handled.isPermanentlyDenied) {
          await openAppSettings();
          throw LocationException(
            'Location is turned off for this app. Enable it in system Settings to continue.',
          );
        }
        throw LocationException('Location permission was denied.');
      }
    }

    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Please turn on device location services (GPS).');
      }
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (!kIsWeb) await openAppSettings();
      throw LocationException(
        'Location permission is blocked. Enable it in Settings to show your position on the map.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw LocationException('Location permission was denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 30),
      ),
    );
  }
}
