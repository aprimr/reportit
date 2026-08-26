import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/app_snackbar.dart';
import 'package:app/helpers/complaint_helper.dart';
import 'package:app/providers/complaint_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _selectedDuration = 'today';

  final _durations = [
    {'label': 'Today', 'value': 'today'},
    {'label': 'Yesterday', 'value': 'yesterday'},
    {'label': 'Week', 'value': 'week'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Year', 'value': 'year'},
    {'label': 'All', 'value': 'all'},
  ];

  final _categories = [
    {'label': 'Road', 'icon': HugeIcons.strokeRoundedRoad01},
    {'label': 'Waste', 'icon': HugeIcons.strokeRoundedGarbageTruck},
    {'label': 'Electricity', 'icon': HugeIcons.strokeRoundedBulbCharging},
    {'label': 'Infrastructure', 'icon': HugeIcons.strokeRoundedCity01},
    {'label': 'Drainage', 'icon': HugeIcons.strokeRoundedDroplet},
    {'label': 'Pollution', 'icon': HugeIcons.strokeRoundedFactory01},
    {'label': 'Water', 'icon': HugeIcons.strokeRoundedWaterPump},
    {'label': 'Other', 'icon': HugeIcons.strokeRoundedMoreHorizontal},
  ];

  Future<void> _fetchDashboardData() async {
    try {
      await ref
          .read(adminDashboardProvider.notifier)
          .fetchDashboardStats(duration: _selectedDuration);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString());
    }
  }

  void _onDurationChanged(String? newValue) {
    if (newValue != null && newValue != _selectedDuration) {
      setState(() {
        _selectedDuration = newValue;
      });
      _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminDashboardProvider);
    final isLoading = ref.watch(isFetchingDashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: AppTheme.primary,
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Appbar
              SliverAppBar(
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: AppTheme.appBarBg,
                scrolledUnderElevation: 1,
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDuration,
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          items: _durations.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['value'],
                              child: Text(
                                d['label']!,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _onDurationChanged,
                          dropdownColor: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Loading State
              if (isLoading && stats == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (stats == null)
                const SliverFillRemaining(
                  child: Center(child: Text('No data available')),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalCard(stats.total),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildStatusCard(
                              'Open',
                              'open',
                              stats.statusCounts['open'] ?? 0,
                            ),
                            _buildStatusCard(
                              'Verified',
                              'verified',
                              stats.statusCounts['verified'] ?? 0,
                            ),
                            _buildStatusCard(
                              'Resolved',
                              'resolved',
                              stats.statusCounts['resolved'] ?? 0,
                            ),
                            _buildStatusCard(
                              'Rejected',
                              'rejected',
                              stats.statusCounts['rejected'] ?? 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Categories',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 105,
                              ),
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final catName = cat['label'] as String;
                            final catIcon = cat['icon'] as List<List<dynamic>>;
                            final catCount = stats.categoryCounts[catName] ?? 0;

                            return _buildCategoryCard(
                              catName,
                              catCount,
                              catIcon,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(70),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL COMPLAINTS',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.appBarBg,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: GoogleFonts.inter(
              fontSize: 42,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, int count) {
    final statusColor = ComplaintHelper.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: ComplaintHelper.getStatusBgColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: statusColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, int count, List<List<dynamic>> icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              HugeIcon(icon: icon, size: 22, color: AppTheme.primary),

              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 4),
              Container(
                height: 24,
                width: 3,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(width: 10),

              Text(
                1030.toString(),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
