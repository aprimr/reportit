import 'package:app/core/model/complaint_model.dart';
import 'package:app/core/services/location_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  String? _mapStyle;
  bool _mapReady = false;

  MapType _currentMapType = MapType.terrain;
  List<List<dynamic>> _currentMapIcon = HugeIcons.strokeRoundedMaping;
  LatLng _currentCoords = const LatLng(28.0508594, 82.4062224);

  List<FeedComplaintModel> complaints = [];
  final Set<Marker> _markers = {};
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    _loadMapStyle();
    _fetchLocation();

    // Fetch complaints
    fetchComplaints();
  }

  @override
  void dispose() {
    // dispose hide status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  void _fetchLocation() async {
    Position? position = await _locationService.getCurrentCoordinates();

    if (!mounted) return;
    if (position != null) {
      LatLng userCoords = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentCoords = userCoords;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userCoords, zoom: 14),
        ),
      );
    } else {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        "Permission denied or location service disabled.",
      );
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString('assets/map_style.json');
      if (mounted) setState(() => _mapStyle = style);
    } catch (e) {
      debugPrint('Failed to load map style: $e');
    }
  }

  void _updateMarkers(List<FeedComplaintModel> complaints) {
    final Set<Marker> markers = {};

    for (final c in complaints) {
      final latitude = c.latitude;
      final longitude = c.longitude;

      markers.add(
        MapMarker.newMarker(
          id: c.id,
          latitude: latitude,
          longitude: longitude,
          status: c.status,
          title: c.title,
          showInfoWindow: true,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
    });
  }

  Future<void> _recenter() async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentCoords, zoom: 14.0),
      ),
    );
  }

  void _changeMap() {
    setState(() {
      if (_currentMapType == MapType.terrain) {
        _currentMapType = MapType.satellite;
        _currentMapIcon = HugeIcons.strokeRoundedSatellite02;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
        _currentMapIcon = HugeIcons.strokeRoundedLayers01;
      } else {
        _currentMapType = MapType.terrain;
        _currentMapIcon = HugeIcons.strokeRoundedMaping;
      }
    });
  }

  Future<void> fetchComplaints() async {
    try {
      final feedComplaintsRef = ref.read(feedComplaintProvider.notifier);
      await feedComplaintsRef.fetchAllComplaints(limit: 5);

      if (!mounted) return;
      var allComplaints = ref.read(feedComplaintProvider);
      _updateMarkers(allComplaints);

      // Keep fetching  rest complaints
      while (feedComplaintsRef.hasMore) {
        await feedComplaintsRef.fetchMoreFeedComplaints(limit: 1);

        if (!mounted) return;
        allComplaints = ref.read(feedComplaintProvider);

        // Update map markers
        _updateMarkers(allComplaints);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _mapReady ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentCoords,
                zoom: 14.0,
              ),
              mapType: _currentMapType,
              style: _mapStyle,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              padding: EdgeInsets.only(
                top: topPadding + 72,
                bottom: bottomPadding + 24,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() => _mapReady = true);
              },
            ),
          ),

          if (!_mapReady)
            Container(
              color: AppTheme.scaffoldBg,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3.4,
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Loading map",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating action btn for change map type
          if (_mapReady)
            Positioned(
              right: 16,
              bottom: bottomPadding + 24 + 72,
              child: AppButtons.icon(
                onPressed: _changeMap,
                icon: _currentMapIcon,
                backgroundColor: AppTheme.onPrimary,
                iconColor: AppTheme.primary,
                elevation: 2,
                radius: 30,
              ),
            ),

          // Floating action button
          if (_mapReady)
            Positioned(
              right: 16,
              bottom: bottomPadding + 24,
              child: AppButtons.icon(
                onPressed: _recenter,
                icon: HugeIcons.strokeRoundedGps01,
                elevation: 2,
                radius: 30,
              ),
            ),
        ],
      ),
    );
  }
}
