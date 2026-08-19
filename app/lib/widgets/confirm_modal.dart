import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  final Future<void> Function() onConfirm;

  final Color? confirmBackgroundColor;
  final Color? confirmForegroundColor;

  final bool barrierDismissible;
  final bool closeOnSuccess;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmBackgroundColor,
    this.confirmForegroundColor,
    this.barrierDismissible = false,
    this.closeOnSuccess = true,
  });

  /// Shows the dialog and returns true when the action succeeds.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmBackgroundColor,
    Color? confirmForegroundColor,
    bool barrierDismissible = false,
    bool closeOnSuccess = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        confirmBackgroundColor: confirmBackgroundColor,
        confirmForegroundColor: confirmForegroundColor,
        barrierDismissible: barrierDismissible,
        closeOnSuccess: closeOnSuccess,
      ),
    );
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm();

      if (!mounted) return;

      if (widget.closeOnSuccess) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // You can replace this with your global error handling.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      content: Text(
        widget.message,
        style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButtons.secondary(
              text: widget.confirmText,
              fontSize: 14,
              foregroundColor:
                  widget.confirmForegroundColor ?? AppTheme.onPrimary,
              backgroundColor:
                  widget.confirmBackgroundColor ?? AppTheme.primary,
              isLoading: _isLoading,
              onPressed: _handleConfirm,
            ),

            const SizedBox(height: 20),

            Center(
              child: AppButtons.text(
                onPressed: _isLoading
                    ? () {}
                    : () => Navigator.of(context).pop(false),
                text: widget.cancelText,
                fontSize: 14,
                textColor: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}
