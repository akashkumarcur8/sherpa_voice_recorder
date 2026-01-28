import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../controllers/raise_ticket_controller.dart';
import '../../models/ticket_query_model.dart';

class QueryDropdown extends GetView<RaiseTicketController> {
  const QueryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: AppStrings.selectYourQuery,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: AppStrings.requiredField,
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.queryError.value.isEmpty
                      ? AppColors.border
                      : AppColors.borderError,
                ),
                color: AppColors.cardBackground,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TicketQuery>(
                  value: controller.selectedQuery.value,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'asset/icons/query.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Select',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  dropdownColor: AppColors.cardBackground,
                  items: controller.queries.map((query) {
                    return DropdownMenuItem<TicketQuery>(
                      value: query,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          query.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.onQuerySelected(value);
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return controller.queries.map((query) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'asset/icons/query.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.textSecondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                query.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            )),
        Obx(() {
          if (controller.queryError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                controller.queryError.value,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
