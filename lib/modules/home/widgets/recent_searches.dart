import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/country_model.dart';

/// Horizontal chips for the last 5 countries opened from search.
class RecentSearches extends StatelessWidget {
  final List<Country> countries;
  final ValueChanged<Country> onTap;
  final VoidCallback onClear;

  const RecentSearches({
    super.key,
    required this.countries,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Recent searches', style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: countries.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, index) {
              final country = countries[index];
              return ActionChip(
                avatar: Text(country.flagEmoji),
                label: Text(country.name, style: const TextStyle(color: AppColors.textPrimary)),
                onPressed: () => onTap(country),
              );
            },
          ),
        ),
      ],
    );
  }
}
