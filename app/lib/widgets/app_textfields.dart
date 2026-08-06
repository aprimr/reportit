import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AppTextfields {
  // LABEL
  static Widget label(
    String text, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0.3,
  }) {
    return Column(
      children: [
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? AppTheme.textPrimary,
            letterSpacing: letterSpacing,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // WITH LABEL
  static Widget withLabel({
    required TextEditingController controller,
    required String label,
    required String hint,
    List<List<dynamic>>? icon,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscure = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    double labelFontSize = 13,
    FontWeight labelFontWeight = FontWeight.w500,
    Color? labelColor,
    double labelLetterSpacing = 0.3,
    double iconSize = 22,
    Color? iconColor,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextfields.label(
          label,
          fontSize: labelFontSize,
          fontWeight: labelFontWeight,
          color: labelColor,
          letterSpacing: labelLetterSpacing,
        ),
        input(
          controller: controller,
          hint: hint,
          icon: icon,
          suffixIcon: suffixIcon,
          onSuffixTap: onSuffixTap,
          obscure: obscure,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          iconSize: iconSize,
          iconColor: iconColor,
          maxLines: maxLines,
        ),
      ],
    );
  }

  // INPUT
  static Widget input({
    required TextEditingController controller,
    required String hint,
    List<List<dynamic>>? icon,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscure = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    double iconSize = 22,
    Color? iconColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      enabled: !readOnly,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: HugeIcon(
                  icon: icon,
                  size: iconSize,
                  color: iconColor ?? AppTheme.textSecondary,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 46),
      ),
    );
  }

  // SEARCH
  static Widget search({
    required TextEditingController controller,
    String hint = 'Search...',
    List<List<dynamic>>? icon,
    VoidCallback? onSubmitted,
    VoidCallback? onClear,
  }) {
    return input(
      controller: controller,
      hint: hint,
      icon: icon ?? HugeIcons.strokeRoundedSearch01,
      suffixIcon: const Icon(
        Icons.clear,
        size: 20,
        color: AppTheme.textSecondary,
      ),
      onSuffixTap:
          onClear ??
          () {
            controller.clear();
          },
    );
  }

  // TEXT AREA
  static Widget textArea({
    required TextEditingController controller,
    required String hint,
    List<List<dynamic>>? icon,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
    String? label,
    double labelFontSize = 13,
    FontWeight labelFontWeight = FontWeight.w500,
    Color? labelColor,
    double labelLetterSpacing = 0.3,
    int maxLines = 4,
    String? Function(String?)? validator,
    bool readOnly = false,
    double iconSize = 22,
    Color? iconColor,
  }) {
    final area = input(
      controller: controller,
      hint: hint,
      icon: icon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      iconSize: iconSize,
      iconColor: iconColor,
    );

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextfields.label(
            label,
            fontSize: labelFontSize,
            fontWeight: labelFontWeight,
            color: labelColor,
            letterSpacing: labelLetterSpacing,
          ),
          area,
        ],
      );
    }
    return area;
  }
}
