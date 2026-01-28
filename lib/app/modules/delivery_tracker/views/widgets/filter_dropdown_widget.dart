
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/delivery_tracker_controller.dart';
import '../../../../core/constants/app_colors.dart';

class FilterDropdownWidget extends StatelessWidget {
  const FilterDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryTrackerController>();

    return Obx(
          () => PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedFilter.value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.darkGrey,
                size: 20,
              ),
            ],
          ),
        ),
        onSelected: (value) {
          controller.filterAgents(value);
        },
        itemBuilder: (BuildContext context) => [
          _buildMenuItem('Select Option'),
          _buildMenuItem('Pending'),
          _buildMenuItem('Delivered'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }
}