import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/feature/alerts/alert_model.dart';
import 'package:amayalert/feature/alerts/alert_repository.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AlertBannerWidget extends StatefulWidget {
  const AlertBannerWidget({super.key});

  @override
  State<AlertBannerWidget> createState() => _AlertBannerWidgetState();
}

class _AlertBannerWidgetState extends State<AlertBannerWidget> {
  @override
  void initState() {
    super.initState();
    // Load active alerts when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertRepository>().loadActiveAlerts();
      context.read<AlertRepository>().subscribeToRealTimeAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertRepository>(
      builder: (context, alertRepository, child) {
        if (alertRepository.activeAlerts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.triangle,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          text: 'Emergency Alerts',
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomText(
                            text: '${alertRepository.activeAlerts.length}',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Alert List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alertRepository.activeAlerts
                        .take(3)
                        .length, // Show max 3 alerts
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.red.shade200),
                    itemBuilder: (context, index) {
                      final alert = alertRepository.activeAlerts[index];
                      return AlertItem(alert: alert);
                    },
                  ),

                  // View All Button (if more than 3 alerts)
                  if (alertRepository.activeAlerts.length > 3)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to alerts screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alerts screen coming soon!'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                        ),
                        child: CustomText(
                          text:
                              'View All ${alertRepository.activeAlerts.length} Alerts',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AlertItem extends StatelessWidget {
  final Alert alert;

  const AlertItem({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Level Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getAlertLevelColor(alert.alertLevel).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAlertLevelIcon(alert.alertLevel),
              color: _getAlertLevelColor(alert.alertLevel),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Alert Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (alert.title != null && alert.title!.isNotEmpty) ...[
                  CustomText(
                    text: alert.title!,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.red.shade800,
                  ),
                  const SizedBox(height: 4),
                ],
                if (alert.content != null && alert.content!.isNotEmpty) ...[
                  CustomText(
                    text: alert.content!,
                    fontSize: 13,
                    color: Colors.red.shade700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    if (alert.alertLevel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getAlertLevelColor(alert.alertLevel),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomText(
                          text: alert.alertLevel!.displayName.toUpperCase(),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    CustomText(
                      text: timeago.format(alert.createdAt),
                      fontSize: 11,
                      color: Colors.red.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertLevelColor(AlertLevel? level) {
    switch (level) {
      case AlertLevel.low:
        return Colors.blue;
      case AlertLevel.medium:
        return Colors.orange;
      case AlertLevel.high:
        return Colors.red;
      case AlertLevel.critical:
        return Colors.purple;
      case null:
        return Colors.grey;
    }
  }

  IconData _getAlertLevelIcon(AlertLevel? level) {
    switch (level) {
      case AlertLevel.low:
        return LucideIcons.info;
      case AlertLevel.medium:
        return LucideIcons.circle;
      case AlertLevel.high:
        return LucideIcons.triangle;
      case AlertLevel.critical:
        return LucideIcons.siren;
      case null:
        return LucideIcons.bell;
    }
  }
}
