import 'package:amayalert/feature/rescue/rescue_model.dart';
import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Rescue rescue;
  final Function(RescueStatus) onUpdateStatus;

  const ActionButtonsWidget({
    super.key,
    required this.rescue,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (rescue.status == RescueStatus.completed ||
        rescue.status == RescueStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (rescue.status == RescueStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onUpdateStatus(RescueStatus.completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mark as Completed'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => onUpdateStatus(RescueStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Request'),
          ),
        ),
      ],
    );
  }
}
