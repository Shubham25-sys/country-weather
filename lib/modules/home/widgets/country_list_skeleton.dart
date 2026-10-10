import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Placeholder cards shown while countries are loading.
class CountryListSkeleton extends StatelessWidget {
  const CountryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _block(width: 64, height: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _block(width: 140, height: 14),
                  const SizedBox(height: 8),
                  _block(width: 90, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _block({required double width, required double height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8)),
  );
}
