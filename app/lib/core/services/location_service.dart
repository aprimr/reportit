import 'package:geocoding/geocoding.dart';
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

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        final String road = place.thoroughfare?.isNotEmpty == true
            ? place.thoroughfare!
            : (place.street ?? '');

        final String landmark =
            (place.name != null && place.name != road && place.name!.isNotEmpty)
            ? place.name!
            : '';

        final String city = place.locality ?? '';
        final String district = place.subAdministrativeArea ?? '';

        List<String> addressParts = [];

        if (road.isNotEmpty) addressParts.add(road);
        if (landmark.isNotEmpty) addressParts.add(landmark);

        if (addressParts.isEmpty &&
            place.name != null &&
            place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }

        if (city.isNotEmpty && city != landmark) addressParts.add(city);
        if (district.isNotEmpty && district != city) addressParts.add(district);

        String fullAddress = addressParts.join(', ');

        return fullAddress.isNotEmpty ? fullAddress : "Location picked";
      }
    } catch (_) {}
    return "Location picked";
  }
}
