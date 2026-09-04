import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StarRatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double starSize;
  final bool isInteractive;
  final String? label;
  final Color activeColor;

  const StarRatingSelector({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.starSize = 24,
    this.isInteractive = false,
    this.label,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = rating >= starIndex;
            final isHalf = !isFilled && rating >= (starIndex - 0.5);

            IconData iconData;
            Color color;

            if (isFilled) {
              iconData = Icons.star_rounded;
              color = activeColor;
            } else if (isHalf) {
              iconData = Icons.star_half_rounded;
              color = activeColor;
            } else {
              iconData = Icons.star_outline_rounded;
              color = isDark ? AppColors.borderDark : AppColors.borderLight;
            }

            final iconWidget = Icon(
              iconData,
              size: starSize,
              color: color,
            );

            if (isInteractive && onRatingChanged != null) {
              return GestureDetector(
                onTap: () => onRatingChanged!(starIndex.toDouble()),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: iconWidget,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: iconWidget,
            );
          }),
        ),
      ],
    );
  }
}
