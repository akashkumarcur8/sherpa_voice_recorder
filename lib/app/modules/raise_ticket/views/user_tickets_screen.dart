import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/user_tickets_controller.dart';
import '../controllers/raise_ticket_controller.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/filter_bar.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/ticket_list_item.dart';
import '../../../widgets/complaint_header.dart';
import '../../../widgets/ticket_details_bottom_sheet.dart';
import 'widgets/raise_ticket_bottom_sheet.dart';
import '../bindings/raise_ticket_binding.dart';
import '../services/raise_ticket_service.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../core/constants/app_strings.dart';

class UserTicketsScreen extends StatelessWidget {
  const UserTicketsScreen({super.key});

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  Future<void> _showTicketDetails(BuildContext context, String ticketId) async {
    try {
      // Get user ID from shared preferences
      final userId = await SharedPrefHelper.getpref(AppStrings.username);
      if (userId.isEmpty) {
        _logger.e('❌ UserTicketsScreen: User ID not found');
        // Don't show error to user - just log it
        return;
      }

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Fetch ticket details
      final service = RaiseTicketService();
      final ticket = await service.fetchTicketDetails(
        ticketId: ticketId,
        userId: userId,
      );

      // Close loading dialog
      Get.back();

      // Use Get.context to avoid BuildContext across async gaps
      // Get.context is always available and safe to use after async operations
      TicketDetailsBottomSheet.show(
        Get.context!,
        ticketId: ticket.ticketId,
        dateTime: ticket.dateTime,
        issueRaised: ticket.issueRaised,
        description: ticket.description,
        status: ticket.status,
        agentId: ticket.agentId ?? 'N/A',
        // No agentName for user tickets
      );
    } catch (e, stackTrace) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _logger.e('❌ UserTicketsScreen: Error loading ticket details: $e',
          error: e, stackTrace: stackTrace);
      // Don't show technical errors to users - just log them
    }
  }

  List<FilterOption> _buildFilterOptions() {
    return [
      const FilterOption(
        label: 'All',
        value: TicketFilter.all,
      ),
      const FilterOption(
        label: 'Pending',
        iconPath: 'asset/icons/pending.svg',
        value: TicketFilter.pending,
      ),
      const FilterOption(
        label: 'Closed',
        iconPath: 'asset/icons/closed.svg',
        value: TicketFilter.closed,
      ),
      const FilterOption(
        label: 'Last 7 days',
        iconPath: 'asset/icons/calender.svg',
        value: TicketFilter.last7Days,
      ),
      const FilterOption(
        label: 'Last 30 days',
        iconPath: 'asset/icons/calender.svg',
        value: TicketFilter.last30Days,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // The binding should have already registered the controller
    final controller = Get.find<UserTicketsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppHeader(
            title: 'Complaint Center',
            useGradient: true,
            useSafeArea: true,
          ),
          Obx(() => FilterBar(
                filters: _buildFilterOptions(),
                selectedValue: controller.selectedFilter.value,
                onFilterChanged: (filter) {
                  controller.applyFilter(filter as TicketFilter);
                },
              )),
          AppSearchBar(
            controller: controller.searchController,
            hintText: 'Search Ticket ID/ Issue',
            onChanged: (query) {
              controller.searchTickets(query);
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
                onRefresh: controller.refreshTickets,
                color: const Color(0xFF5B6BC6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.filterTitle,
                        style: AppTextStyles.interSemiBold14.copyWith(
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (controller.displayedTickets.isEmpty)
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
                        ...controller.displayedTickets.map((ticket) {
                          return TicketListItem(
                            ticketId: ticket.ticketId,
                            dateTime: ticket.dateTime,
                            issueRaised: ticket.issueRaised,
                            status: ticket.status,
                            onTap: () async {
                              // Fetch ticket details and show bottom sheet
                              await _showTicketDetails(
                                  context, ticket.ticketId);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Initialize raise ticket controller
          if (!Get.isRegistered<RaiseTicketController>()) {
            RaiseTicketBinding().dependencies();
          }
          RaiseTicketBottomSheet.show(context);
        },
        backgroundColor: const Color(0xFF565ADD),
        icon: SvgPicture.asset(
          'asset/icons/ticket1.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        label: Text(
          'Raise Ticket',
          style: AppTextStyles.manropeSemibold16.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
