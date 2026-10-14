import 'package:app/core/model/complaint_model.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/complaint_tracking.dart';
import 'package:app/widgets/confirm_modal.dart';
import 'package:app/widgets/map_marker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminComplaintsDetailScreen extends ConsumerStatefulWidget {
  const AdminComplaintsDetailScreen({super.key, required this.complaint});

  final AdminComplaintModel complaint;

  @override
  ConsumerState<AdminComplaintsDetailScreen> createState() =>
      _AdminComplaintsDetailScreenState();
}

class _AdminComplaintsDetailScreenState
    extends ConsumerState<AdminComplaintsDetailScreen> {
  String? _mapStyle;

  bool isDeleting = false;
  bool isVerifyLoading = false;
  bool isRejectLoading = false;
  bool isResolveLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString('assets/map_style.json');
      if (mounted) setState(() => _mapStyle = style);
    } catch (e) {
      debugPrint('Failed to load map style: $e');
    }
  }

  Future<String?> _showCustomRemarksDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isRequired,
  }) async {
    final remarksController = TextEditingController();
    bool isError = false;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppTheme.scaffoldBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: remarksController,
                      maxLines: 3,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: isRequired
                            ? 'Enter reason...'
                            : 'Enter remarks (optional)...',
                        filled: true,
                        fillColor: AppTheme.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isError
                                ? AppTheme.error
                                : AppTheme.inputBorder,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (isError) {
                          setDialogState(() => isError = false);
                        }
                      },
                    ),
                    if (isError) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Please enter a reason.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: AppButtons.primary(
                        onPressed: () {
                          final remarks = remarksController.text.trim();

                          if (isRequired && remarks.isEmpty) {
                            setDialogState(() => isError = true);
                            return;
                          }

                          Navigator.of(dialogContext).pop(remarks);
                        },
                        text: confirmText,
                        fontSize: 16,
                        backgroundColor: isRequired
                            ? AppTheme.error
                            : AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return result;
  }

  void _verifyComplaint() async {
    AppConfirmDialog.show(
      context: context,
      title: "Verify Complaint?",
      message: "Are you sure you want to verify this complaint?",
      confirmText: 'Yes, Verify',
      cancelText: 'Cancel',
      confirmBackgroundColor: AppTheme.success,
      onConfirm: () async {
        setState(() => isVerifyLoading = true);
        try {
          await ref
              .read(adminComplaintProvider.notifier)
              .verifyComplaint(widget.complaint.id);

          if (!mounted) return;
          AppSnackBar.success(context, "Complaint Verified Successfully");
          Navigator.pop(context, true); // Close dialog
        } catch (e) {
          if (!mounted) return;
          AppSnackBar.error(context, e.toString());
        } finally {
          if (mounted) setState(() => isVerifyLoading = false);
        }
      },
    );
  }

  Future<void> _rejectComplaint() async {
    debugPrint('[REJECT] Button callback entered');

    try {
      debugPrint('[REJECT] Opening remarks dialog');

      final reason = await _showCustomRemarksDialog(
        title: 'Reject Complaint?',
        message: 'Please provide a reason for rejecting this complaint.',
        confirmText: 'Reject',
        isRequired: true,
      );

      debugPrint('[REJECT] Dialog returned: $reason');

      if (!mounted || reason == null) return;

      setState(() => isRejectLoading = true);

      debugPrint('[REJECT] Calling provider');

      await ref
          .read(adminComplaintProvider.notifier)
          .rejectComplaint(widget.complaint.id, reason);

      debugPrint('[REJECT] Provider completed');

      if (!mounted) return;

      AppSnackBar.success(context, 'Complaint Rejected');
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('[REJECT] ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      AppSnackBar.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => isRejectLoading = false);
      }
    }
  }

  Future<void> _resolveComplaint() async {
    debugPrint('[RESOLVE] Button callback entered');

    try {
      debugPrint('[RESOLVE] Opening remarks dialog');

      final remarks = await _showCustomRemarksDialog(
        title: 'Resolve Complaint?',
        message: 'Add any resolution details below (optional).',
        confirmText: 'Resolve',
        isRequired: false,
      );

      debugPrint('[RESOLVE] Dialog returned: $remarks');

      if (!mounted || remarks == null) return;

      setState(() => isResolveLoading = true);

      debugPrint('[RESOLVE] Calling provider');

      await ref
          .read(adminComplaintProvider.notifier)
          .resolveComplaint(widget.complaint.id, remarks);

      debugPrint('[RESOLVE] Provider completed');

      if (!mounted) return;

      AppSnackBar.success(context, 'Complaint Resolved Successfully');
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('[RESOLVE] ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      AppSnackBar.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => isResolveLoading = false);
      }
    }
  }

  void _deleteComplaint() async {
    AppConfirmDialog.show(
      context: context,
      title: "Delete Complaint?",
      message:
          "This will permanently delete the complaint. This action cannot be undone.",
      confirmText: 'Yes, Delete',
      cancelText: 'Cancel',
      confirmBackgroundColor: AppTheme.error,
      onConfirm: () async {
        setState(() => isDeleting = true);
        try {
          await ref
              .read(adminComplaintProvider.notifier)
              .deleteAdminComplaint(widget.complaint.id);

          if (!mounted) return;

          Navigator.pop(context);
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.error(context, e.toString());
        } finally {
          if (mounted) setState(() => isDeleting = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Review Complaint',
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      complaint.category,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    complaint.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    complaint.description,
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Images
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: complaint.imageUrls.map((img) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        _FullScreenImageViewer(imageUrl: img),
                                  ),
                                );
                              },
                              child: Image.network(
                                img,
                                width: complaint.imageUrls.length == 1
                                    ? screenWidth * 0.90
                                    : screenWidth * 0.75,
                                fit: BoxFit.cover,
                              ),
                            ),
                            complaint.imageUrls.length == 1
                                ? const SizedBox.shrink()
                                : const SizedBox(width: 10),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Map
                  SizedBox(
                    height: 280,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(complaint.latitude, complaint.longitude),
                        zoom: 15,
                      ),
                      style: _mapStyle,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      gestureRecognizers: const {
                        Factory<PanGestureRecognizer>(PanGestureRecognizer.new),
                      },
                      markers: {
                        MapMarker.newMarker(
                          id: complaint.id,
                          longitude: complaint.longitude,
                          latitude: complaint.latitude,
                          title: complaint.title,
                          status: complaint.status,
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: 34),

                  // User details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.secondary,
                                  AppTheme.success,
                                  AppTheme.warning,
                                  AppTheme.error,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              complaint.fullname,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Email and phone
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    complaint.email ?? 'No email provided',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    complaint.phone ?? 'No phone provided',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tracking & Response
                  ComplaintTracking(
                    id: complaint.id,
                    createdAt: complaint.createdAt,
                    verifiedAt: complaint.verifiedAt,
                    resolvedAt: complaint.resolvedAt,
                    rejectedAt: complaint.rejectedAt,
                  ),
                ],
              ),
            ),
          ),

          _buildBottomActionBar(complaint.status),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(String status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.appBarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == "open") ...[
              Row(
                children: [
                  Expanded(
                    child: AppButtons.primary(
                      onPressed: _verifyComplaint,
                      isLoading: isVerifyLoading,
                      text: "Verify",
                      fontSize: 18,
                      backgroundColor: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButtons.primary(
                      onPressed: _rejectComplaint,
                      isLoading: isRejectLoading,
                      text: "Reject",
                      fontSize: 18,
                      backgroundColor: AppTheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            if (status == "verified") ...[
              AppButtons.primary(
                onPressed: _resolveComplaint,
                isLoading: isResolveLoading,
                text: "Resolve Complaint",
                fontSize: 18,
                backgroundColor: AppTheme.success,
              ),
              const SizedBox(height: 12),
            ],

            AppButtons.secondary(
              onPressed: _deleteComplaint,
              isLoading: isDeleting,
              text: "Delete Complaint",
              fontSize: 16,
              icon: HugeIcons.strokeRoundedDelete01,
            ),
          ],
        ),
      ),
    );
  }
}

// Image fullscreen preview
class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  bool _panEnabled = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.row0.x;

    final isZoomed = scale > 1.0;
    if (_panEnabled != isZoomed) {
      setState(() {
        _panEnabled = isZoomed;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              panEnabled: _panEnabled,
              child: Image.network(widget.imageUrl),
            ),
          ),

          // Close Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
