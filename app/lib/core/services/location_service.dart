import 'package:geolocator/geolocator.dart';

class LocationService {
  late bool isServiceEnabled;
  late LocationPermission permission;

  // Check and request location permission
  Future<bool> _handlePermission() async {
    // Check if location services are enabled
    isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return false;
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    return true;
  }

  // Get current coordinates
  Future<Position?> getCurrentCoordinates() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return null;

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }
}
