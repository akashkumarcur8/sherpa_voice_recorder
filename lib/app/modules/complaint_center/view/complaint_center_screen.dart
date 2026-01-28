import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complaint_controller.dart';
import 'widgets/complaint_header.dart';
import '../../../core/constants/app_text_styles.dart';
import 'widgets/complaint_list_item.dart';
import 'widgets/complaint_filter_bar.dart';
import 'widgets/complaint_search_bar.dart';

class ComplaintCenterScreen extends StatelessWidget {
  const ComplaintCenterScreen({super.key});

  FilterType _mapFilterType(ComplaintFilter filter) {
    switch (filter) {
      case ComplaintFilter.all:
        return FilterType.all;
      case ComplaintFilter.pending:
        return FilterType.pending;
      case ComplaintFilter.closed:
        return FilterType.closed;
      case ComplaintFilter.last7Days:
        return FilterType.last7Days;
      case ComplaintFilter.last30Days:
        return FilterType.last30Days;
      case ComplaintFilter.resolved:
        return FilterType.closed; // Map resolved to closed
    }
  }

  ComplaintFilter _mapComplaintFilter(FilterType filterType) {
    switch (filterType) {
      case FilterType.all:
        return ComplaintFilter.all;
      case FilterType.pending:
        return ComplaintFilter.pending;
      case FilterType.closed:
        return ComplaintFilter.closed;
      case FilterType.last7Days:
        return ComplaintFilter.last7Days;
      case FilterType.last30Days:
        return ComplaintFilter.last30Days;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ComplaintHeader(),
          Obx(() => ComplaintFilterBar(
                selectedFilter: _mapFilterType(controller.selectedFilter.value),
                onFilterChanged: (filterType) {
                  controller.applyFilter(_mapComplaintFilter(filterType));
                },
              )),
          ComplaintSearchBar(
            controller: controller.searchController,
            onChanged: (query) {
              controller.searchComplaints(query);
            },
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5B6BC6),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshComplaints,
                color: const Color(0xFF5B6BC6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Complaints',
                                    style:
                                        AppTextStyles.interRegular10.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.totalCount.value.toString(),
                                    style:
                                        AppTextStyles.interSemiBold20.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resolved Complaints',
                                    style:
                                        AppTextStyles.interRegular10.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.resolvedCount.value.toString(),
                                    style:
                                        AppTextStyles.interSemiBold20.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Complaints',
                                    style:
                                        AppTextStyles.interRegular10.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.pendingCount.value.toString(),
                                    style:
                                        AppTextStyles.interSemiBold20.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.filterTitle,
                        style: AppTextStyles.interSemiBold14.copyWith(
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (controller.displayedComplaints.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  controller.emptyStateMessage,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...controller.displayedComplaints.map((complaint) {
                          return ComplaintListItem(complaint: complaint);
                        }),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
