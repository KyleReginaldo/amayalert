import 'package:flutter/material.dart';

/// Custom badge widget for displaying notification counts
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: BoxConstraints(
                minWidth: badgeSize ?? 16,
                minHeight: badgeSize ?? 16,
              ),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular((badgeSize ?? 16) / 2),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: count > 99 ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension to add badge functionality to any widget
extension WidgetBadgeExtension on Widget {
  Widget withBadge({
    required int count,
    Color? badgeColor,
    Color? textColor,
    double? badgeSize,
  }) {
    return NotificationBadge(
      count: count,
      badgeColor: badgeColor,
      textColor: textColor,
      badgeSize: badgeSize,
      child: this,
    );
  }
}
