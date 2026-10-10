import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Small icon + label + value block used in the country facts grid.
class InfoTile extends StatelessWidget {
  static const _valueStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);

  final IconData icon;
  final String label;
  final String value;

  /// Keeps values like "1,429,404,000" on one line by scaling them down
  /// instead of breaking them in the middle of the number.
  final bool singleLine;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                if (singleLine)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, maxLines: 1, style: _valueStyle),
                  )
                else
                  Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: _valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
