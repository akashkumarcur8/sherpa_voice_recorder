import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// A reusable filter bar widget that displays horizontal filter chips
///
/// This widget can be used with any filter type by providing a list of
/// FilterOption objects and handling the selection via callbacks.
class FilterBar extends StatelessWidget {
  /// List of filter options to display
  final List<FilterOption> filters;

  /// Currently selected filter value (must match one of the filter values)
  final dynamic selectedValue;

  /// Callback when a filter is tapped
  final Function(dynamic) onFilterChanged;

  const FilterBar({
    super.key,
    required this.filters,
    required this.selectedValue,
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
            for (int i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _FilterChip(
                label: filters[i].label,
                iconPath: filters[i].iconPath,
                isSelected: _isSelected(filters[i].value),
                onTap: () => onFilterChanged(filters[i].value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSelected(dynamic value) {
    return selectedValue == value;
  }
}

/// Represents a single filter option in the FilterBar
class FilterOption {
  /// Display label for the filter
  final String label;

  /// Optional icon path (SVG asset)
  final String? iconPath;

  /// Value associated with this filter (can be enum, string, etc.)
  final dynamic value;

  const FilterOption({
    required this.label,
    this.iconPath,
    required this.value,
  });
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
