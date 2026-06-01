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
            right: -5,
            top: -5,
            child: Container(
              height: badgeSize ?? 16,
              constraints: BoxConstraints(minWidth: badgeSize ?? 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius:
                    BorderRadius.circular((badgeSize ?? 16) / 2),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: count > 99 ? 7 : 9,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                textAlign: TextAlign.center,
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
