import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

enum IconPos { left, right }

class AppButtons {
  // Primary Button
  static Widget primary({
    required VoidCallback onPressed,
    required String text,
    List<List<dynamic>>? icon,
    IconPos iconPos = IconPos.left,
    double iconSize = 22,
    bool isLoading = false,
    double width = double.infinity,
    double height = 52,
    double fontSize = 18,
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && iconPos == IconPos.left) ...[
                    HugeIcon(
                      icon: icon,
                      size: iconSize,
                      color: foregroundColor,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null && iconPos == IconPos.right) ...[
                    const SizedBox(width: 10),
                    HugeIcon(
                      icon: icon,
                      size: iconSize,
                      color: foregroundColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  // Secondary Button
  static Widget secondary({
    required VoidCallback onPressed,
    required String text,
    List<List<dynamic>>? icon,
    IconPos iconPos = IconPos.left,
    double iconSize = 22,
    bool isLoading = false,
    double width = double.infinity,
    double height = 52,
    double fontSize = 18,
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.inputFill,
          foregroundColor: foregroundColor ?? AppTheme.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && iconPos == IconPos.left) ...[
                    HugeIcon(
                      icon: icon,
                      size: iconSize,
                      color: foregroundColor,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null && iconPos == IconPos.right) ...[
                    const SizedBox(width: 10),
                    HugeIcon(
                      icon: icon,
                      size: iconSize,
                      color: foregroundColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  // Outlined Button
  static Widget outlined({
    required VoidCallback onPressed,
    required String text,
    List<List<dynamic>>? icon,
    IconPos iconPos = IconPos.left,
    double iconSize = 22,
    bool isLoading = false,
    double width = double.infinity,
    double height = 52,
    double fontSize = 18,
    Color? textColor,
    Color? borderColor,
    double borderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Colors.white,
          side: BorderSide(
            color: borderColor ?? Colors.white.withAlpha(77),
            width: 1.5,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: textColor ?? Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && iconPos == IconPos.left) ...[
                    HugeIcon(icon: icon, size: iconSize, color: textColor),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null && iconPos == IconPos.right) ...[
                    const SizedBox(width: 10),
                    HugeIcon(icon: icon, size: iconSize, color: textColor),
                  ],
                ],
              ),
      ),
    );
  }

  // Text Button
  static Widget text({
    required VoidCallback onPressed,
    required String text,
    List<List<dynamic>>? icon,
    IconPos iconPos = IconPos.left,
    double iconSize = 20,
    bool isLoading = false,
    double fontSize = 16,
    Color? textColor,
    double? letterSpacing,
    FontWeight fontWeight = FontWeight.w600,
    bool underline = false,
    double? underlineThickness,
    Color? underlineColor,
    bool isDisabled = false,
  }) {
    final color = textColor ?? AppTheme.primary;
    final disabledColor = color.withAlpha(102);
    final effectiveColor = isDisabled ? disabledColor : color;

    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onPressed,
      child: Opacity(
        opacity: isLoading ? 0.7 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && iconPos == IconPos.left) ...[
              HugeIcon(icon: icon, size: iconSize, color: effectiveColor),
              const SizedBox(width: 8),
            ],
            if (isLoading)
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: effectiveColor,
                ),
              )
            else
              Text(
                text,
                style: GoogleFonts.montserrat(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  letterSpacing: letterSpacing ?? 0.2,
                  color: effectiveColor,
                  decoration: underline
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: underlineColor ?? color,
                  decorationThickness: underlineThickness ?? 1.5,
                ),
              ),
            if (icon != null && iconPos == IconPos.right) ...[
              const SizedBox(width: 8),
              HugeIcon(icon: icon, size: iconSize, color: effectiveColor),
            ],
          ],
        ),
      ),
    );
  }

  // Social Button
  static Widget social({
    required VoidCallback onPressed,
    required String text,
    required List<List<dynamic>> icon,
    IconPos iconPos = IconPos.left,
    double iconSize = 24,
    bool isLoading = false,
    double width = double.infinity,
    double height = 52,
    double fontSize = 18,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Colors.white,
          backgroundColor: backgroundColor ?? Colors.transparent,
          side: BorderSide(color: Colors.white.withAlpha(51), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: textColor ?? Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconPos == IconPos.left) ...[
                    HugeIcon(icon: icon, size: iconSize, color: textColor),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.montserrat(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (iconPos == IconPos.right) ...[
                    const SizedBox(width: 12),
                    HugeIcon(icon: icon, size: iconSize, color: textColor),
                  ],
                ],
              ),
      ),
    );
  }

  // Icon Button
  static Widget icon({
    required VoidCallback onPressed,
    required List<List<dynamic>> icon,
    double size = 52,
    Color? backgroundColor,
    Color? iconColor,
    double iconSize = 24,
    double elevation = 0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary,
          foregroundColor: iconColor ?? Colors.white,
          elevation: elevation,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
        ),
        child: HugeIcon(icon: icon, size: iconSize, color: iconColor),
      ),
    );
  }

  // Loading Button
  static Widget loading({
    required String text,
    double width = double.infinity,
    double height = 52,
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 14,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
