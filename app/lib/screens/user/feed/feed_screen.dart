import 'package:app/core/theme/app_theme.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/screens/skeleton/user/home_skeleton.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:app/widgets/vote_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? selectedStatus;
  String? selectedSort;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(feedComplaintProvider.notifier);

      if (notifier.hasMore) {
        notifier.fetchMoreFeedComplaints(
          search: searchController.text.isEmpty ? null : searchController.text,
          status: selectedStatus,
          sort: selectedSort,
        );
      }
    }
  }

  Future<void> pullTorefresh() async {
    await ref
        .read(feedComplaintProvider.notifier)
        .fetchAllComplaints(
          search: searchController.text.isEmpty ? null : searchController.text,
          status: selectedStatus,
          sort: selectedSort,
        );
  }

  void onSearchChanged(String query) {
    ref
        .read(feedComplaintProvider.notifier)
        .fetchAllComplaints(
          search: query.isEmpty ? null : query,
          status: selectedStatus,
          sort: selectedSort,
        );
  }

  void onStatusFilterSelected(String? newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(feedComplaintProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: pullTorefresh,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                elevation: 0,
                floating: true,
                backgroundColor: AppTheme.appBarBg,
                scrolledUnderElevation: 0,
                title: Row(
                  children: [
                    Image.asset("assets/images/logo.png", height: 28),
                    SizedBox(width: 4),
                    Text(
                      'ReportIt',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(
                      right: 20,
                      top: 6,
                      bottom: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: HugeIcon(
                        size: 24,
                        strokeWidth: 1.8,
                        icon: HugeIcons.strokeRoundedSearch01,
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: AppTextfields.search(
                      controller: searchController,
                      hint: "Search title or description",
                    ),
                  ),
                ),
              ),

              // Body
              complaints.isEmpty
                  ? SliverToBoxAdapter(child: HomeSkeletonScreen())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Loading more indicator
                          if (index == complaints.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.8,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Loading complaints...",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final complaint = complaints[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              border: Border.all(
                                width: 1.8,
                                color: AppTheme.inputBorder.withAlpha(200),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Category
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.08,
                                        ),
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
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ComplaintHelper.getStatusBgColor(
                                          complaint.status,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ComplaintHelper.formatStatus(
                                          complaint.status,
                                        ),
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
                                const SizedBox(height: 10),

                                // Title
                                Text(
                                  complaint.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Description
                                Text(
                                  complaint.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // User
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
                                    Text(
                                      complaint.fullname,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),

                                // Divider
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppTheme.divider,
                                  ),
                                ),

                                // Bottom row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // UpVote or Downvote row
                                    Row(
                                      children: [
                                        // Upvote
                                        VoteButton(
                                          count: 2656,
                                          icon:
                                              HugeIcons.strokeRoundedArrowUpBig,
                                          color: AppTheme.primary,
                                          onTap: () {},
                                          isActive: false,
                                        ),
                                        SizedBox(width: 10),

                                        // Downvote
                                        VoteButton(
                                          count: 196,
                                          icon: HugeIcons
                                              .strokeRoundedArrowDownBig,
                                          color: AppTheme.error,
                                          onTap: () {},
                                          isActive: false,
                                        ),
                                      ],
                                    ),

                                    // Reported date
                                    Text(
                                      TimeHelper.timeAgo(complaint.createdAt),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount:
                            complaints.length +
                            (ref.watch(isFetchingMoreProvider) ? 1 : 0),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
