import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker {
  static Marker newMarker({
    required String id,
    required double latitude,
    required double longitude,
    required String status,
    required String title,
    bool showInfoWindow = false,
  }) {
    String assetPath = 'assets/icon/splash_ic.png';

    switch (status.toLowerCase()) {
      case 'verified':
        assetPath = 'assets/icon/verified_pin_ic.png';
        break;
      case 'resolved':
        assetPath = 'assets/icon/resolved_pin_ic.png';
        break;
      case 'rejected':
        assetPath = 'assets/icon/rejected_pin_ic.png';
        break;
      case 'open':
        assetPath = 'assets/icon/open_pin_ic.png';
        break;
    }

    final BitmapDescriptor customIcon = AssetMapBitmap(
      assetPath,
      height: 30,
      width: 30,
    );

    return Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      icon: customIcon,
      infoWindow: showInfoWindow
          ? InfoWindow(title: title, snippet: 'Status: ${status.toUpperCase()}')
          : InfoWindow.noText,
    );
  }
}
