// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

/// ShadCN-inspired button tokens
enum ButtonSize { xs, sm, md, lg }

class _ButtonTokens {
  static const double radius = 10.0;
  static const double elevation = 2.0;
  static const EdgeInsetsGeometry paddingMd = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 16,
  );
  static const EdgeInsetsGeometry paddingSm = EdgeInsets.symmetric(
    vertical: 10,
    horizontal: 14,
  );
  static const EdgeInsetsGeometry paddingLg = EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 20,
  );
}

TextStyle _defaultTextStyle(
  BuildContext context,
  ButtonSize size,
  Color foreground,
) {
  final baseSize = switch (size) {
    ButtonSize.xs => 12.0,
    ButtonSize.sm => 14.0,
    ButtonSize.md => 15.0,
    ButtonSize.lg => 17.0,
  };

  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: baseSize,
    color: foreground,
  );
}

/// Base button builder used by the exported button widgets
Widget _buildButton({
  required BuildContext context,
  required Widget child,
  required VoidCallback? onPressed,
  required bool isFullWidth,
  required double borderRadius,
  required WidgetStateProperty<Color?> backgroundColor,
  required WidgetStateProperty<Color?> foregroundColor,
  required WidgetStateProperty<BorderSide?>? side,
  required EdgeInsetsGeometry padding,
  double elevation = _ButtonTokens.elevation,
}) {
  final theme = Theme.of(context);

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius),
  );

  return SizedBox(
    width: isFullWidth ? double.infinity : null,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(elevation),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: WidgetStateProperty.all(padding),
        shape: WidgetStateProperty.all(shape),
        side: side,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed))
            return theme.colorScheme.primary.withOpacity(0.12);
          if (states.contains(WidgetState.hovered))
            return theme.colorScheme.primary.withOpacity(0.06);
          return null;
        }),
      ),
      child: child,
    ),
  );
}

/// ShadCN-like Elevated Button
class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double borderRadius;

  const CustomElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.size = ButtonSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = _ButtonTokens.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? theme.colorScheme.onPrimary;

    final padding = switch (size) {
      ButtonSize.xs => _ButtonTokens.paddingSm,
      ButtonSize.sm => _ButtonTokens.paddingSm,
      ButtonSize.md => _ButtonTokens.paddingMd,
      ButtonSize.lg => _ButtonTokens.paddingLg,
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: (size == ButtonSize.lg ? 20 : 18), color: fg),
        if (icon != null) const SizedBox(width: 10),
        Text(label, style: textStyle ?? _defaultTextStyle(context, size, fg)),
      ],
    );

    return _buildButton(
      context: context,
      child: child,
      onPressed: onPressed,
      isFullWidth: isFullWidth,
      borderRadius: borderRadius,
      backgroundColor: WidgetStateProperty.all(bg),
      foregroundColor: WidgetStateProperty.all(fg),
      side: null,
      padding: padding,
      elevation: 3,
    );
  }
}

/// ShadCN-like Outlined Button
class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final ButtonSize size;
  final Color? borderColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.size = ButtonSize.md,
    this.borderColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = _ButtonTokens.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bc = borderColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? theme.colorScheme.primary;

    final padding = switch (size) {
      ButtonSize.xs => _ButtonTokens.paddingSm,
      ButtonSize.sm => _ButtonTokens.paddingSm,
      ButtonSize.md => _ButtonTokens.paddingMd,
      ButtonSize.lg => _ButtonTokens.paddingLg,
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: (size == ButtonSize.lg ? 20 : 18), color: fg),
        if (icon != null) const SizedBox(width: 10),
        Text(label, style: textStyle ?? _defaultTextStyle(context, size, fg)),
      ],
    );

    return _buildButton(
      context: context,
      child: child,
      onPressed: onPressed,
      isFullWidth: isFullWidth,
      borderRadius: borderRadius,
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(fg),
      side: WidgetStateProperty.all(BorderSide(color: bc)),
      padding: padding,
      elevation: 0,
    );
  }
}

/// ShadCN-like Text Button (unstyled background, subtle press)
class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final ButtonSize size;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double borderRadius;

  const CustomTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.size = ButtonSize.sm,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = _ButtonTokens.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = foregroundColor ?? theme.colorScheme.primary;

    final padding = switch (size) {
      ButtonSize.xs => _ButtonTokens.paddingSm,
      ButtonSize.sm => EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      ButtonSize.md => _ButtonTokens.paddingSm,
      ButtonSize.lg => _ButtonTokens.paddingMd,
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: 16, color: fg),
        if (icon != null) const SizedBox(width: 8),
        Text(label, style: textStyle ?? _defaultTextStyle(context, size, fg)),
      ],
    );

    return _buildButton(
      context: context,
      child: child,
      onPressed: onPressed,
      isFullWidth: isFullWidth,
      borderRadius: borderRadius,
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.all(fg),
      side: null,
      padding: padding,
      elevation: 0,
    );
  }
}
