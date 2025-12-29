import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

enum FilterType {
  all,
  pending,
  closed,
  last7Days,
  last30Days,
}

class ComplaintFilterBar extends StatelessWidget {
  final FilterType selectedFilter;
  final Function(FilterType) onFilterChanged;

  const ComplaintFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: selectedFilter == FilterType.all,
              onTap: () => onFilterChanged(FilterType.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pending',
              iconPath: 'asset/icons/pending.svg',
              isSelected: selectedFilter == FilterType.pending,
              onTap: () => onFilterChanged(FilterType.pending),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Closed',
              iconPath: 'asset/icons/closed.svg',
              isSelected: selectedFilter == FilterType.closed,
              onTap: () => onFilterChanged(FilterType.closed),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Last 7 days',
              iconPath: 'asset/icons/calender.svg',
              isSelected: selectedFilter == FilterType.last7Days,
              onTap: () => onFilterChanged(FilterType.last7Days),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Last 30 days',
              iconPath: 'asset/icons/calender.svg',
              isSelected: selectedFilter == FilterType.last30Days,
              onTap: () => onFilterChanged(FilterType.last30Days),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null) ...[
              SvgPicture.asset(
                iconPath!,
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.interRegular12.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

