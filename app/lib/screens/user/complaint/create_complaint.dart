import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_appbar.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  bool _isPublic = true;
  bool _isLoading = false;
  // double? _latitude;
  // double? _longitude;

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
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
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
                  Text(
                    'Category',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final label = cat['label'] as String;
                      final icon = cat['icon'] as List<List<dynamic>>;
                      final isSelected = _selectedCategory == label;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = label),
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

                  const SizedBox(height: 20),

                  // Description
                  AppTextfields.textArea(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the issue in detail...',
                    maxLines: 8,
                    maxChars: 2500,
                    validator: (v) {
                      if (v!.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      if (v.trim().length <= 15) {
                        return 'Description must be at least 200 characters.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Location
                  Text(
                    'Location',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppButtons.outlined(
                          onPressed: () {},
                          text: "Pick location from map",
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButtons.icon(
                        onPressed: () {},
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        iconColor: AppTheme.primary,
                        icon: HugeIcons.strokeRoundedGps01,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Post privately
                  AppButtons.toggle(
                    value: _isPublic,
                    label: "Post to feed",
                    onChanged: (newValue) {
                      setState(() {
                        _isPublic = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 22),

                  // Submit
                  _isLoading
                      ? AppButtons.loading(text: 'Submitting...')
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
}
