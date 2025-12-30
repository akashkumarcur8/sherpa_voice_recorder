import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complaint_controller.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/filter_bar.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/ticket_list_item.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/ticket_details_bottom_sheet.dart';

class ComplaintCenterScreen extends StatelessWidget {
  const ComplaintCenterScreen({super.key});

  List<FilterOption> _buildFilterOptions() {
    return [
      const FilterOption(
        label: 'All',
        value: ComplaintFilter.all,
      ),
      const FilterOption(
        label: 'Pending',
        iconPath: 'asset/icons/pending.svg',
        value: ComplaintFilter.pending,
      ),
      const FilterOption(
        label: 'Closed',
        iconPath: 'asset/icons/closed.svg',
        value: ComplaintFilter.closed,
      ),
      const FilterOption(
        label: 'Last 7 days',
        iconPath: 'asset/icons/calender.svg',
        value: ComplaintFilter.last7Days,
      ),
      const FilterOption(
        label: 'Last 30 days',
        iconPath: 'asset/icons/calender.svg',
        value: ComplaintFilter.last30Days,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppHeader(
            title: 'Complaint Center',
          ),
          Obx(() => FilterBar(
                filters: _buildFilterOptions(),
                selectedValue: controller.selectedFilter.value,
                onFilterChanged: (filter) {
                  controller.applyFilter(filter as ComplaintFilter);
                },
              )),
          AppSearchBar(
            controller: controller.searchController,
            hintText: 'Search Ticket ID/Agent Name',
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
                          return TicketListItem(
                            ticketId: complaint.complaintId,
                            dateTime: complaint.dateTime,
                            issueRaised: complaint.issueRaised,
                            status: complaint.status,
                            agentName: complaint.agentName,
                            complaintId: complaint.complaintId,
                            onTap: () {
                              TicketDetailsBottomSheet.show(
                                context,
                                ticketId: complaint.complaintId,
                                dateTime: complaint.dateTime,
                                issueRaised: complaint.issueRaised,
                                description: complaint.description,
                                status: complaint.status,
                                agentId: complaint.agentId,
                                agentName: complaint.agentName,
                              );
                            },
                          );
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
