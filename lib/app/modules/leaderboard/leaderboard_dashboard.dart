//  Leaderboard Screenwith filter icon
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'LeaderboardController.dart';
import '../../widgets/filter_bottom_sheet_widget.dart';

// Updated Leaderboard Screen with filter icon
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      LeaderboardController(
        startDate: DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 7))),
        endDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF565ADD), Color(0xFF2E3077)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        const Expanded(
                          child: Text(
                            "Leaderboard",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_list,
                              color: Colors.white),
                          onPressed: () {
                            FilterBottomSheetWidget.show(
                              context: context,
                              startDateController: controller.startDateCtrl,
                              endDateController: controller.endDateCtrl,
                              initialSort: controller.selectedSort.value,
                              onApply: (start, end, sortOption) {
                                controller.selectedSort.value = sortOption;
                                controller.applyFilter(
                                  start: start,
                                  end: end,
                                );
                              },
                              onReset: () {
                                controller.resetAllFilters();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Achievement Message
                    Obx(() {
                      final rank = controller.currentUserRank.value;
                      if (rank != null) {
                        return Column(
                          children: [
                            Text(
                              "#$rank",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rank <= 3
                                  ? "Congratulations! You're in the top 3!"
                                  : "You are doing Great! Keep pushing forward!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF565ADD)),
                  ),
                );
              }

              if (controller.error.value != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Failed to load leaderboard",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please try again",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchLeaderboardData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF565ADD),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              if (controller.leaderboardData.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No leaderboard data available",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Check back later for updates",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Podium Section
                  if (controller.topThree.isNotEmpty)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF565ADD), Color(0xFF2E3077)],
                          // begin: Alignment.topCenter,
                          // end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Position 2
                            if (controller.topThree.length > 1)
                              _buildPodiumItem(
                                  controller, controller.topThree[1], 1, 100),

                            const SizedBox(width: 16),

                            // Position 1
                            if (controller.topThree.isNotEmpty)
                              _buildPodiumItem(
                                  controller, controller.topThree[0], 0, 120),

                            const SizedBox(width: 16),

                            // Position 3
                            if (controller.topThree.length > 2)
                              _buildPodiumItem(
                                  controller, controller.topThree[2], 2, 80),
                          ],
                        ),
                      ),
                    ),

                  // Other Rankings
                  if (controller.otherRanks.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.otherRanks.length,
                        itemBuilder: (context, index) {
                          final participant = controller.otherRanks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFEBEBEB)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      "${participant['companyrank']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9D9D9D),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          controller.getAvatarColor(index + 3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        controller
                                            .getInitials(participant['name']),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          participant['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        Text(
                                          "${participant['score']} points",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9D9D9D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardController controller,
      Map<String, dynamic> participant, int colorIndex, double height) {
    final position = participant['companyrank'];
    final isFirst = position == 1;

    return Column(
      children: [
        if (isFirst)
          const Icon(Icons.emoji_events, color: Color(0xFFFFC93D), size: 35),
        if (isFirst) const SizedBox(height: 4),
        Container(
          width: isFirst ? 80 : 64,
          height: isFirst ? 80 : 64,
          decoration: BoxDecoration(
            color: controller.getAvatarColor(colorIndex),
            shape: BoxShape.circle,
            border: isFirst
                ? Border.all(color: const Color(0xFFFFC93D), width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              controller.getInitials(participant['name']),
              style: TextStyle(
                fontSize: isFirst ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          participant['name'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          "${participant['score']} pts",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              "$position",
              style: TextStyle(
                fontSize: isFirst ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
