import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/helpers/time_helper.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:app/screens/skeleton/user/home_skeleton.dart';
import 'package:app/widgets/vote_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class MyComplaintsScreen extends ConsumerStatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  ConsumerState<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends ConsumerState<MyComplaintsScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? selectedStatus;
  String? selectedSort;

  final complaintStatus = [
    {'label': 'All', 'value': null},
    {'label': 'Open', 'value': 'open'},
    {'label': 'Verified', 'value': 'verified'},
    {'label': 'Rejected', 'value': 'rejected'},
    {'label': 'Resolved', 'value': 'resolved'},
  ];

  @override
  void initState() {
    super.initState();

    _fetchMyComplaints();
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

  void _fetchMyComplaints() {
    ref
        .read(complaintProvider.notifier)
        .fetchMyComplaints(
          search: searchController.text.isEmpty ? null : searchController.text,
          status: selectedStatus,
          sort: selectedSort,
        );
  }

  void onStatusFilterSelected(String? newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });
    _fetchMyComplaints();
  }

  void onSearchChanged(String query) {
    _fetchMyComplaints();
  }

  void onSortSelected(String sortStr) {
    setState(() {
      selectedSort = sortStr;
    });
    _fetchMyComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(complaintProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: pullTorefresh,
        child: SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: AppTheme.appBarBg,
                scrolledUnderElevation: 1,
                title: Row(
                  children: [
                    Image.asset("assets/images/logo.png", height: 28),
                    SizedBox(width: 4),
                    Text(
                      'My Complaints',
                      style: GoogleFonts.merriweather(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(98),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 40),
                          decoration: BoxDecoration(
                            color: AppTheme.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.inputBorder),
                          ),
                          child: TextField(
                            onChanged: onSearchChanged,
                            controller: searchController,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Search your complaints by title or description",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textHint,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 8,
                                ),
                                child: SizedBox(
                                  height: 18,
                                  width: 18,

                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedSearch01,
                                    strokeWidth: 1.8,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      color: Colors.grey.shade600,
                                      onPressed: () {
                                        searchController.clear();
                                        _fetchMyComplaints();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                6,
                                16,
                                6,
                              ),
                              prefixIconConstraints: BoxConstraints(
                                maxHeight: 40,
                                maxWidth: 40,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Satus chips
                      Row(
                        children: [
                          // Status
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: complaintStatus.map((s) {
                                    final isSelected =
                                        selectedStatus == s['value'];

                                    return Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(s['label'] as String),
                                        selectedColor: AppTheme.primary,
                                        backgroundColor: AppTheme.scaffoldBg,
                                        shape: StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        labelStyle: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          color: isSelected
                                              ? AppTheme.scaffoldBg
                                              : AppTheme.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                        showCheckmark: false,
                                        selected: isSelected,
                                        onSelected: (value) {
                                          if (value) {
                                            onStatusFilterSelected(s['value']);
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          // Sort
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  onSortSelected(value);
                                },
                                offset: const Offset(0, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 1,
                                color: AppTheme.scaffoldBg,
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'latest',
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedSorting19,
                                          size: 18,
                                          color: AppTheme.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Latest',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'oldest',
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedSorting91,
                                          size: 18,
                                          color: AppTheme.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Oldest',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.scaffoldBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      width: 2,
                                      color: AppTheme.inputBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedFilterVertical,
                                        size: 14,
                                        strokeWidth: 1.6,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        selectedSort == 'oldest'
                                            ? 'Oldest'
                                            : 'Latest',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        height: 3.5,
                        color: AppTheme.inputBorder.withAlpha(240),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              complaints.isEmpty
                  ? SliverToBoxAdapter(
                      child: searchController.text.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 60,
                                horizontal: 16,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No reported complaints found",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : HomeSkeletonScreen(),
                    )
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.feedComplaintDetail,
                                arguments: complaint,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 4,
                                    color: AppTheme.inputBorder.withAlpha(200),
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [],
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

                                  // Category and Status Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // User
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Category
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(6),
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
                                          ],
                                        ),
                                      ),

                                      // Status
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        margin: EdgeInsets.only(left: 16),
                                        decoration: BoxDecoration(
                                          color:
                                              ComplaintHelper.getStatusBgColor(
                                                complaint.status,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          ComplaintHelper.formatStatus(
                                            complaint.status,
                                          ),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                ComplaintHelper.getStatusColor(
                                                  complaint.status,
                                                ),
                                          ),
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
                                            icon: HugeIcons
                                                .strokeRoundedArrowUpBig,
                                            color: AppTheme.primary,
                                            onTap: () {},
                                            isActive: false,
                                          ),
                                          SizedBox(width: 16),

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

                                      // Reported at
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
