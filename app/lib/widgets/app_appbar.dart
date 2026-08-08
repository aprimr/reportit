import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final double elevation;
  final double scrolledUnderElevation;
  final Widget? flexibleSpace;
  final bool showBackButton;

  const AppAppbar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.titleFontSize,
    this.titleFontWeight,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.flexibleSpace,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final effectiveTitleColor = titleColor ?? AppTheme.textPrimary;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      leading:
          leading ??
          (canPop && showBackButton
              ? IconButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                )
              : null),
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: GoogleFonts.montserrat(
                    fontSize: titleFontSize ?? 20,
                    fontWeight: titleFontWeight ?? FontWeight.w600,
                    color: effectiveTitleColor,
                  ),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
