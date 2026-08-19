import 'package:app/core/model/complaint_model.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/authority_response_card.dart';
import 'package:app/widgets/complaint_tracking.dart';
import 'package:app/widgets/confirm_modal.dart';
import 'package:app/widgets/map_marker.dart';
import 'package:app/widgets/vote_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_plus/liquid_glass_plus.dart';

class MyComplaintDetailScreen extends ConsumerStatefulWidget {
  const MyComplaintDetailScreen({super.key, required this.complaint});

  final ComplaintModel complaint;

  @override
  ConsumerState<MyComplaintDetailScreen> createState() =>
      _ComplaintDetailState();
}

class _ComplaintDetailState extends ConsumerState<MyComplaintDetailScreen> {
  String? _mapStyle;
  bool isDeleting = false;

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

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final complaints = ref.read(complaintProvider.notifier);

    void delete() async {
      AppConfirmDialog.show(
        context: context,
        title: "Delete Complaint?",
        message:
            "This will permanently delete the complaint. This action cannot be undone.",
        confirmText: 'Yes, Delete',
        cancelText: 'Cancel',
        confirmBackgroundColor: AppTheme.error,
        onConfirm: () async {
          try {
            setState(() {
              isDeleting = true;
            });

            // Call delete
            await complaints.deleteComplaint(complaint.id);

            if (!context.mounted) return;
            Navigator.pop(context);
          } catch (e) {
            if (!context.mounted) return;
            AppSnackBar.error(context, e.toString());
          } finally {
            setState(() {
              isDeleting = false;
            });
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Map
                  SizedBox(
                    height: screenHeight * 0.36,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(complaint.latitude, complaint.longitude),
                        zoom: 15,
                      ),
                      style: _mapStyle,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      cameraTargetBounds: CameraTargetBounds(
                        LatLngBounds(
                          southwest: LatLng(
                            complaint.latitude - 0.01,
                            complaint.longitude - 0.01,
                          ),
                          northeast: LatLng(
                            complaint.latitude + 0.01,
                            complaint.longitude + 0.01,
                          ),
                        ),
                      ),
                      minMaxZoomPreference: MinMaxZoomPreference(13, 18),
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
                          // showInfoWindow: true,
                        ),
                      },
                    ),
                  ),

                  // Body
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and Category Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Complaint
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

                            // Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ComplaintHelper.getStatusBgColor(
                                  complaint.status,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ComplaintHelper.formatStatus(complaint.status),
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ComplaintHelper.getStatusColor(
                                    complaint.status,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Title
                        Text(
                          complaint.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: complaint.imageUrls.map((img) {
                              return Row(
                                children: [
                                  Image.network(
                                    img,
                                    width: complaint.imageUrls.length == 1
                                        ? screenWidth * 0.885
                                        : screenWidth * 0.75,
                                  ),
                                  complaint.imageUrls.length == 1
                                      ? SizedBox.shrink()
                                      : SizedBox(width: 10),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 18),

                        // Reported At and Vote Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Reported at
                            Text(
                              "On ${TimeHelper.formatDateTime(complaint.createdAt)}",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10),

                            // UpVote or Downvote
                            Row(
                              children: [
                                // Upvote
                                VoteButton(
                                  count: 2656,
                                  icon: HugeIcons.strokeRoundedArrowUpBig,
                                  color: AppTheme.primary,
                                  onTap: () {},
                                  isActive: false,
                                ),
                                SizedBox(width: 16),

                                // Downvote
                                VoteButton(
                                  count: 0,
                                  icon: HugeIcons.strokeRoundedArrowDownBig,
                                  color: AppTheme.error,
                                  onTap: () {},
                                  isActive: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tracking
                        ComplaintTracking(
                          key: widget.key,
                          id: complaint.id,
                          createdAt: complaint.createdAt,
                          verifiedAt: complaint.verifiedAt,
                          resolvedAt: complaint.resolvedAt,
                          rejectedAt: complaint.rejectedAt,
                        ),
                        SizedBox(height: 18),

                        // Authority Response
                        AuthorityResponseCard(
                          status: complaint.status,
                          adminRemarks: complaint.adminRemarks,
                          rejectedAt: complaint.rejectedAt,
                          resolvedAt: complaint.resolvedAt,
                        ),

                        // Toggle public visibility
                        AppButtons.toggle(
                          label: "Show in feed",
                          value: true,
                          onChanged: (val) {},
                        ),
                        SizedBox(height: 12),

                        // Show Delete Button if status is open
                        if (complaint.status == "open") ...[
                          Column(
                            children: [
                              AppButtons.primary(
                                onPressed: delete,
                                isLoading: isDeleting,
                                text: "Delete Complaint",
                                backgroundColor: AppTheme.error,
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: LiquidGlassLayer(
                settings: const LiquidGlassSettings(
                  frostIntensity: 3,
                  thickness: 20,
                ),
                child: LiquidGlass(
                  shape: const LiquidRoundedSuperellipse(borderRadius: 30),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 44,
                      width: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
