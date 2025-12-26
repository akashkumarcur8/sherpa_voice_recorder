import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complaint_controller.dart';
import 'widgets/complaint_header.dart';
import 'widgets/complaint_stats_card.dart';
import 'widgets/complaint_list_item.dart';

class ComplaintCenterScreen extends StatelessWidget {
  const ComplaintCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const ComplaintHeader(),
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
                      Row(
                        children: [
                          Expanded(
                            child: ComplaintStatsCard(
                              count: controller.pendingCount.value.toString(),
                              label: 'Pending\nComplaints',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              isSelected: controller.selectedFilter.value ==
                                  ComplaintFilter.pending,
                              onTap: () => controller.applyFilter(
                                  ComplaintFilter.pending),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ComplaintStatsCard(
                              count: controller.resolvedCount.value.toString(),
                              label: 'Resolved\nComplaints',
                              backgroundColor:  Colors.white,
                              textColor: Colors.black,
                              isSelected: controller.selectedFilter.value ==
                                  ComplaintFilter.resolved,
                              onTap: () => controller.applyFilter(
                                  ComplaintFilter.resolved),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ComplaintStatsCard(
                              count: controller.totalCount.value.toString(),
                              label: 'Total\nComplaints',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              isSelected: controller.selectedFilter.value ==
                                  ComplaintFilter.all,
                              onTap: () => controller.applyFilter(
                                  ComplaintFilter.all),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.filterTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B6BC6),
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
                        }).toList(),
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