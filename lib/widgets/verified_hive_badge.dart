import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class VerifiedHiveBadge extends StatelessWidget {
  final bool isCompact;

  const VerifiedHiveBadge({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.verifiedBadgeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.verifiedBadge.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 14,
            color: AppColors.verifiedBadge,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified Hive',
            style: TextStyle(
              color: AppColors.verifiedBadge,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
