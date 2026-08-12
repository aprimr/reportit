import 'dart:io';

import 'package:app/core/services/location_service.dart';
import 'package:app/core/services/media_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/widgets/app_appbar.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_plus/liquid_glass_plus.dart';

class CreateComplaintScreen extends ConsumerStatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  ConsumerState<CreateComplaintScreen> createState() =>
      _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  final _location = LocationService();
  final _media = MediaService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _categoryError = "";
  String _imagesError = "";
  String _locationError = "";

  MapType _currentMapType = MapType.terrain;
  List<List<dynamic>> _currentMapIcon = HugeIcons.strokeRoundedMaping;

  GoogleMapController? _mapController;
  String? _selectedCategory;
  Position? _locationCoords;
  String? _locationName;
  bool _isPublic = true;
  final List<XFile?> _images = [];
  bool _isLoading = false;

  static const _categories = [
    {'label': 'Road', 'icon': HugeIcons.strokeRoundedRoad01},
    {'label': 'Waste', 'icon': HugeIcons.strokeRoundedGarbageTruck},
    {'label': 'Electricity', 'icon': HugeIcons.strokeRoundedBulbCharging},
    {'label': 'Drainage', 'icon': HugeIcons.strokeRoundedDroplet},
    {'label': 'Water', 'icon': HugeIcons.strokeRoundedWaterPump},
    {'label': 'Other', 'icon': HugeIcons.strokeRoundedMoreHorizontal},
  ];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final photo = await _media.captureImageFromCamera();
                  if (photo != null) {
                    setState(() => _images.add(photo));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final photo = await _media.pickImageFromGallery();
                  if (photo != null) {
                    setState(() => _images.add(photo));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPickerMap() async {
    LatLng? markedLocation;
    final currentCoords = await _location.getCurrentCoordinates();
    if (currentCoords == null) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Failed to open map. Please make sure your location is turned on.',
      );
      return;
    }
    LatLng mapPos = LatLng(currentCoords.latitude, currentCoords.longitude);

    Future<void> recenter() async {
      Position? currentCoords = await _location.getCurrentCoordinates();

      if (currentCoords == null) return;

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentCoords.latitude, currentCoords.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }

    Future<void> confirmLocation() async {
      String locationName = await _location.getAddressFromCoordinates(
        markedLocation!.latitude,
        markedLocation!.longitude,
      );
      setState(() {
        _locationName = locationName;
        _locationCoords = Position(
          latitude: markedLocation!.latitude,
          longitude: markedLocation!.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });

      Navigator.pop(context);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Stack(
              children: [
                // Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: mapPos,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapType: _currentMapType,
                  onCameraMove: (position) {
                    markedLocation = position.target;
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // Marker
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Image.asset(
                      "assets/icon/splash_ic.png",
                      height: 45,
                      width: 55,
                    ),
                  ),
                ),

                // Header
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      // Back Button
                      LiquidGlassLayer(
                        settings: const LiquidGlassSettings(
                          thickness: 40,
                          frostIntensity: 4,
                        ),
                        child: LiquidGlass(
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 30,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => Navigator.of(context).pop(),
                              child: SizedBox.square(
                                dimension: 48,
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                  color: AppTheme.textPrimary.withAlpha(200),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: LiquidGlassLayer(
                          settings: const LiquidGlassSettings(
                            thickness: 40,
                            frostIntensity: 4,
                          ),
                          child: LiquidGlass(
                            shape: const LiquidRoundedSuperellipse(
                              borderRadius: 20,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                'Point the pin to the location',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary.withAlpha(200),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Button
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppButtons.icon(
                        backgroundColor: AppTheme.onPrimary,
                        iconColor: AppTheme.primary,
                        elevation: 1,
                        icon: _currentMapIcon,
                        radius: 30,
                        onPressed: () {
                          setSheetState(() {
                            if (_currentMapType == MapType.terrain) {
                              _currentMapType = MapType.satellite;
                              _currentMapIcon =
                                  HugeIcons.strokeRoundedSatellite02;
                            } else if (_currentMapType == MapType.satellite) {
                              _currentMapType = MapType.hybrid;
                              _currentMapIcon = HugeIcons.strokeRoundedLayers01;
                            } else {
                              _currentMapType = MapType.terrain;
                              _currentMapIcon = HugeIcons.strokeRoundedMaping;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      AppButtons.icon(
                        backgroundColor: AppTheme.onPrimary,
                        iconColor: AppTheme.primary,
                        elevation: 1,
                        icon: HugeIcons.strokeRoundedGps01,
                        radius: 30,
                        onPressed: recenter,
                      ),
                      SizedBox(height: 16),
                      AppButtons.primary(
                        text: "Confirm Location",
                        borderRadius: 30,
                        onPressed: confirmLocation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() async {
    setState(() {
      _categoryError = _selectedCategory == null ? "Category is required" : "";
      _imagesError = _images.isEmpty ? "Image is required" : "";
      _locationError = _locationCoords == null ? "Location is required" : "";
    });

    if (!_formKey.currentState!.validate()) return;
    if (_categoryError.isNotEmpty ||
        _imagesError.isNotEmpty ||
        _locationError.isNotEmpty) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await ref
          .read(complaintNotifierProvider.notifier)
          .createComplaint(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory!,
            latitude: _locationCoords!.latitude,
            longitude: _locationCoords!.longitude,
            isPublic: _isPublic,
            images: _images,
          );

      setState(() {
        _titleController.text = "";
        _descriptionController.text = "";
        _selectedCategory = null;
        _images.clear();
        _locationCoords = null;
        _locationName = null;
        _isPublic = true;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppbar(title: "Create a complaint"),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  AppTextfields.withLabel(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter the complaint title',
                    maxChars: 60,
                    readOnly: _isLoading,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Please enter a title';
                      if (v.trim().length <= 15) {
                        return 'Title must be at least  15 characters.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Category
                  AppTextfields.label("Category"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final label = cat['label'] as String;
                      final icon = cat['icon'] as List<List<dynamic>>;
                      final isSelected = _selectedCategory == label;

                      return GestureDetector(
                        onTap: () => setState(
                          () => _isLoading ? null : _selectedCategory = label,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppTheme.inputBorder,
                                    width: 1,
                                  ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: icon,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_categoryError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 20),
                      child: Text(
                        _categoryError,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Description
                  AppTextfields.textArea(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the issue in detail...',
                    maxLines: 8,
                    maxChars: 2500,
                    readOnly: _isLoading,
                    validator: (v) {
                      if (v!.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      if (v.trim().length <= 200) {
                        return 'Description must be at least 200 characters.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Attach Images
                  AppTextfields.label("Attach Images"),
                  attachImages(),
                  if (_imagesError.isNotEmpty) ...{
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _imagesError,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  },
                  const SizedBox(height: 20),

                  // Location
                  AppTextfields.label("Location"),
                  if (_locationCoords == null) ...{
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: AppButtons.outlined(
                            text: "Pick on map",
                            fontSize: 13,
                            onPressed: _showLocationPickerMap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: AppButtons.primary(
                            text: "Use my location",
                            fontSize: 14,
                            icon: HugeIcons.strokeRoundedGps01,
                            foregroundColor: AppTheme.primary,
                            backgroundColor: AppTheme.primary.withAlpha(30),
                            onPressed: () async {
                              final position = await _location
                                  .getCurrentCoordinates();
                              final locationName = await _location
                                  .getAddressFromCoordinates(
                                    position!.latitude,
                                    position.longitude,
                                  );

                              if (!context.mounted) return;

                              setState(() {
                                _locationCoords = position;
                                _locationName = locationName;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  } else ...{
                    Container(
                      padding: const EdgeInsets.only(
                        left: 18,
                        top: 1.5,
                        bottom: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        border: Border.all(
                          width: 1.5,
                          color: AppTheme.inputFill,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              // TODO: remove this wrapper
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        "${_locationCoords!.latitude}, ${_locationCoords!.longitude}",
                                  ),
                                );
                              },
                              child: Text(
                                _locationName.toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _isLoading ? null : _locationCoords = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  },
                  if (_locationError.isNotEmpty) ...{
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _locationError,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  },

                  const SizedBox(height: 10),

                  // Post privately
                  AppButtons.toggle(
                    value: _isPublic,
                    label: "Post to feed",
                    readOnly: _isLoading,

                    onChanged: (newValue) {
                      setState(() {
                        _isPublic = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 22),

                  // Submit
                  _isLoading
                      ? AppButtons.loading(text: 'Creating. Please Wait...')
                      : AppButtons.primary(
                          onPressed: _submit,
                          text: 'Submit Complaint',
                          iconPos: IconPos.right,
                        ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget attachImages() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Select image
          if (_images.length < 4) ...{
            Row(
              children: [
                InkWell(
                  onTap: _isLoading ? null : _showImagePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 95,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 2,
                        color: AppTheme.inputBorder,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedImage02,
                          color: AppTheme.textSecondary,
                          size: 28,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Add Image",
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacer
                SizedBox(width: 8),
              ],
            ),
          },

          // Image display
          ..._images.where((image) => image != null).map((image) {
            final index = _images.indexOf(image);
            return Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(image!.path),
                        width: 95,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Remove Image Button
                    Positioned(
                      top: 3,
                      right: 3,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isLoading ? null : _images.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Image Size Overlay
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppTheme.textPrimary),
                        child: Center(
                          child: FutureBuilder<int>(
                            future: image.length(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                final kb = snapshot.data! / 1024;
                                final sizeText = kb > 1024
                                    ? '${(kb / 1024).toStringAsFixed(1)} MB'
                                    : '${kb.toStringAsFixed(1)} KB';

                                return Text(
                                  sizeText,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    color: AppTheme.scaffoldBg,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                              return Text(
                                'Calculating size...',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: AppTheme.scaffoldBg,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Spacer
                SizedBox(width: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}
