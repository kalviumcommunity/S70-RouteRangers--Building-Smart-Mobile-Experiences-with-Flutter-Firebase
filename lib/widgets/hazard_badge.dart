import 'package:flutter/material.dart';
import '../models/hazard_model.dart';

class HazardBadge extends StatelessWidget {
  final HazardModel hazard;
  final bool isCompact;

  const HazardBadge({
    super.key,
    required this.hazard,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = hazard.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hazard.icon,
            size: isCompact ? 13 : 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            hazard.typeLabel,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
