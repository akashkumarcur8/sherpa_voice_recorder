import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../leaderboard/leaderboard_dashboard.dart';
import 'analytics_controller.dart';
import '../../widgets/custom_bottom_navigation.dart';
import '../home/controllers/home_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/recording_helper.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  AnalyticsDashboardState createState() => AnalyticsDashboardState();
}

class AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String currentDateRange = 'Last 7 Days';

  // Current data that changes based on filter
  int todayCallCount = 12;
  int todayAvgScore = 54;
  int agentCallCount = 32;
  int agentAvgScore = 75;
  int agentScore = 38;
  int avgProductScore = 23;
  int avgBehaviorScore = 15;

  List<String> chartLabels = [
    'Sun',
    'Mon',
    'Tues',
    'Wed',
    'Thurs',
    'Fri',
    'Sat'
  ];

  final AnalyticsController c = Get.put(AnalyticsController());

  void _showFilterBottomSheet() {
    String selectedRange = currentDateRange;
    final ranges = [
      'Last 7 Days',
      'Last 14 Days',
      'Last 30 Days',
      'Last 3 Months',
      'Last 6 Months',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollCtr) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: EdgeInsets.only(
                    top: 12,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7D7D7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Analytics',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Color(0xFF9D9D9D)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Date range options
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtr,
                          itemCount: ranges.length,
                          itemBuilder: (_, i) {
                            final range = ranges[i];
                            final isSelected = range == selectedRange;
                            return GestureDetector(
                              onTap: () =>
                                  setModalState(() => selectedRange = range),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF565ADD)
                                          .withValues(alpha: 0.1)
                                      : const Color(0xFFF8F9FC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF565ADD)
                                        : const Color(0xFFEBEBEB),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: isSelected
                                          ? const Color(0xFF565ADD)
                                          : const Color(0xFF9D9D9D),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      range,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF565ADD)
                                            : const Color(0xFF1A1A1A),
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF565ADD), size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilter(selectedRange);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF565ADD),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply Filter',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
// ────────────────────────────────────────────────────────────────────────────────

  List<Widget> _buildDateRangeOptions(
      String selectedRange, StateSetter setModalState) {
    final ranges = [
      'Last 7 Days',
      'Last 14 Days',
      'Last 30 Days',
      'Last 3 Months',
      'Last 6 Months',
      'This Year',
    ];

    return ranges.map((range) {
      final isSelected = selectedRange == range;
      return GestureDetector(
        onTap: () {
          setModalState(() {
            selectedRange = range;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF565ADD).withValues(alpha: 0.1)
                : const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF565ADD)
                  : const Color(0xFFEBEBEB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isSelected
                    ? const Color(0xFF565ADD)
                    : const Color(0xFF9D9D9D),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                range,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF565ADD)
                      : const Color(0xFF1A1A1A),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF565ADD),
                  size: 20,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // List<Widget> _buildSmartSuggestions() {
  //   return [
  //     _buildSuggestionCard(
  //       'Peak Performance Period',
  //       'Your scores are above average. Check last 30 days for trends.',
  //       Icons.trending_up,
  //       Color(0xFF0EC16E),
  //     ),
  //     _buildSuggestionCard(
  //       'Low Call Volume',
  //       'Today\'s calls are below average. Compare with last week.',
  //       Icons.trending_down,
  //       Color(0xFFF34E4E),
  //     ),
  //     _buildSuggestionCard(
  //       'Improving Trend',
  //       'Your performance is trending upward. View longer period.',
  //       Icons.show_chart,
  //       Color(0xFF565ADD),
  //     ),
  //   ];
  // }

  Widget _buildSuggestionCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9D9D9D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter(String dateRange) {
    setState(() {
      currentDateRange = dateRange;
    });

    int days;
    switch (dateRange) {
      case 'Last 14 Days':
        days = 14;
        break;
      case 'Last 30 Days':
        days = 30;
        break;
      case 'Last 3 Months':
        days = 90;
        break;
      case 'Last 6 Months':
        days = 180;
        break;
      // case 'This Year':
      //   final now = DateTime.now();
      //   days = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      //   break;
      default:
        days = 7;
    }

    c.fetchFilterAnalytics(days: days);
  }

  // void _applyFilter(String dateRange) {
  //   setState(() {
  //     currentDateRange = dateRange;
  //
  //     // Update data based on selected range
  //     switch (dateRange) {
  //       case 'Last 7 Days':
  //         todayCallCount = 12;
  //         todayAvgScore = 54;
  //         agentCallCount = 32;
  //         agentAvgScore = 75;
  //         agentScore = 38;
  //         avgProductScore = 23;
  //         avgBehaviorScore = 15;
  //         chartSpots = [
  //           FlSpot(0, 10),
  //           FlSpot(1, 8),
  //           FlSpot(2, 18),
  //           FlSpot(3, 12),
  //           FlSpot(4, 16),
  //           FlSpot(5, 16),
  //           FlSpot(6, 8),
  //         ];
  //         chartLabels = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'];
  //         chartDetailData = [
  //           {'day': 'Sun', 'score': 10, 'calls': 5, 'avgTime': '2.5 min', 'satisfaction': '85%'},
  //           {'day': 'Mon', 'score': 8, 'calls': 3, 'avgTime': '3.2 min', 'satisfaction': '78%'},
  //           {'day': 'Tues', 'score': 18, 'calls': 8, 'avgTime': '2.1 min', 'satisfaction': '92%'},
  //           {'day': 'Wed', 'score': 12, 'calls': 6, 'avgTime': '2.8 min', 'satisfaction': '88%'},
  //           {'day': 'Thurs', 'score': 16, 'calls': 7, 'avgTime': '2.3 min', 'satisfaction': '90%'},
  //           {'day': 'Fri', 'score': 16, 'calls': 7, 'avgTime': '2.3 min', 'satisfaction': '90%'},
  //           {'day': 'Sat', 'score': 8, 'calls': 3, 'avgTime': '3.2 min', 'satisfaction': '78%'},
  //         ];
  //         break;
  //       case 'Last 14 Days':
  //         todayCallCount = 18;
  //         todayAvgScore = 62;
  //         agentCallCount = 68;
  //         agentAvgScore = 78;
  //         agentScore = 42;
  //         avgProductScore = 28;
  //         avgBehaviorScore = 19;
  //         chartSpots = [
  //           FlSpot(0, 15),
  //           FlSpot(1, 22),
  //         ];
  //         chartLabels = ['Week 1', 'Week 2'];
  //         chartDetailData = [
  //           {'day': 'Week 1', 'score': 15, 'calls': 25, 'avgTime': '2.8 min', 'satisfaction': '87%'},
  //           {'day': 'Week 2', 'score': 22, 'calls': 35, 'avgTime': '2.4 min', 'satisfaction': '91%'},
  //         ];
  //         break;
  //       case 'Last 30 Days':
  //         todayCallCount = 25;
  //         todayAvgScore = 68;
  //         agentCallCount = 145;
  //         agentAvgScore = 82;
  //         agentScore = 48;
  //         avgProductScore = 35;
  //         avgBehaviorScore = 25;
  //         chartSpots = [
  //           FlSpot(0, 12),
  //           FlSpot(1, 18),
  //           FlSpot(2, 25),
  //           FlSpot(3, 22),
  //         ];
  //         chartLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
  //         chartDetailData = [
  //           {'day': 'Week 1', 'score': 12, 'calls': 28, 'avgTime': '3.1 min', 'satisfaction': '83%'},
  //           {'day': 'Week 2', 'score': 18, 'calls': 42, 'avgTime': '2.7 min', 'satisfaction': '89%'},
  //           {'day': 'Week 3', 'score': 25, 'calls': 38, 'avgTime': '2.2 min', 'satisfaction': '94%'},
  //           {'day': 'Week 4', 'score': 22, 'calls': 37, 'avgTime': '2.5 min', 'satisfaction': '91%'},
  //         ];
  //         break;
  //       case 'Last 3 Months':
  //         todayCallCount = 35;
  //         todayAvgScore = 72;
  //         agentCallCount = 420;
  //         agentAvgScore = 85;
  //         agentScore = 52;
  //         avgProductScore = 42;
  //         avgBehaviorScore = 38;
  //         chartSpots = [
  //           FlSpot(0, 20),
  //           FlSpot(1, 25),
  //           FlSpot(2, 28),
  //         ];
  //         chartLabels = ['Month 1', 'Month 2', 'Month 3'];
  //         chartDetailData = [
  //           {'day': 'Month 1', 'score': 20, 'calls': 125, 'avgTime': '2.9 min', 'satisfaction': '86%'},
  //           {'day': 'Month 2', 'score': 25, 'calls': 148, 'avgTime': '2.6 min', 'satisfaction': '90%'},
  //           {'day': 'Month 3', 'score': 28, 'calls': 147, 'avgTime': '2.4 min', 'satisfaction': '93%'},
  //         ];
  //         break;
  //       default:
  //       // Keep current values
  //         break;
  //     }
  //   });
  // }

  void _showTooltip(BuildContext context, int index, Offset position) {
    if (index >= c.chartSpots.length || index >= c.chartLabels.length) return;

    final score = c.chartSpots[index].y.toInt();
    final day = c.chartLabels[index];
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        bottom: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF565ADD),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Score: $score',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: const Color(0xFF565ADD),
  //       iconTheme: const IconThemeData(color: Colors.white),
  //       // title: const Text(
  //       //   'Conversation Centre',
  //       //   style: TextStyle(color: Colors.white),
  //       // ),
  //     ),
  //
  //     backgroundColor: Color(0xFFF8F9FC),
  //     body: SafeArea(
  //       child: Column(
  //         children: [
  //           Expanded(
  //             child: SingleChildScrollView(
  //               padding: EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   _buildHeaderCard(),
  //                   SizedBox(height: 24),
  //                   _buildTodaysAnalytics(),
  //                   SizedBox(height: 24),
  //                   _buildAgentAnalytics(),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     // bottomNavigationBar: _buildBottomNavigation(),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ADD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildTodaysAnalytics(),
                const SizedBox(height: 24),
                _buildAgentAnalytics(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() => CustomBottomNavigation(
            isRecording: Get.isRegistered<HomeController>()
                ? Get.find<HomeController>().isRecording.value
                : false,
            onMicPressed: () {
              // Check current recording state before navigation
              final isCurrentlyRecording = Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>().isRecording.value
                  : false;

              developer.log(
                  'Analytics: Mic button pressed - isRecording: $isCurrentlyRecording',
                  name: 'AnalyticsDashboard');

              // Schedule recording toggle (start or stop) based on current state
              // If recording, we'll stop. If not recording, we'll start.
              scheduleRecordingToggleAfterNavigation(
                  'Analytics', !isCurrentlyRecording);

              // Redirect to home screen
              Get.offAllNamed(Routes.home);
            },
            isMicEnabled: false,
          )),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF565ADD), Color(0xFFD4B2FB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Welcome!',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 18,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                const SizedBox(height: 8),
                const Text(
                  'Leaderboard Live',
                  style: TextStyle(
                    color: Color(0xFFFFD51A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'See Your Score Now.',
                  style: TextStyle(
                    color: Color(0xFFFFD51A),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(const LeaderboardScreen());
                    // Add this delay if needed
                  },
                  icon: const Text('📊', style: TextStyle(fontSize: 14)),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Color(0xFF565ADD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF565ADD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildTrophyIcon(),
        ],
      ),
    );
  }

  Widget _buildTrophyIcon() {
    return Stack(
      children: [
        SvgPicture.asset(
          'asset/icons/stars.svg',
          fit: BoxFit.cover,
        ),
        Image.asset(
          'asset/images/trophy.png',
          fit: BoxFit.contain,
          semanticLabel: 'Trophy icon',
          // optional: you can tint the SVG:
          // color: Colors.amber,
          // semanticsLabel: 'Trophy icon',
        ),
        // child: CustomPaint(
        //   painter: TrophyPainter(),
        // ),
        // Positioned(
        //   top: -8,
        //   right: -8,
        //   child: Text('✦', style: TextStyle(color: Color(0xFFFFD51A), fontSize: 12)),
        // ),
        // Positioned(
        //   top: 16,
        //   left: -16,
        //   child: Text('✦', style: TextStyle(color: Color(0xFFFFD51A), fontSize: 12)),
        // ),
        // Positioned(
        //   bottom: -8,
        //   right: 16,
        //   child: Text('✦', style: TextStyle(color: Color(0xFFFFD51A), fontSize: 12)),
        // ),
      ],
    );
  }

  // Widget _buildTodaysAnalytics() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Today\'s Analytics',
  //         style: TextStyle(
  //           color: Color(0xFF565ADD),
  //           fontSize: 20,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       SizedBox(height: 16),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildMetricCard(
  //               'Today\'s Call Count',
  //               todayCallCount.toString(),
  //               Icons.phone,
  //             ),
  //           ),
  //           SizedBox(width: 16),
  //           Expanded(
  //             child: _buildMetricCard(
  //               'Today\'s Avg Score',
  //               todayAvgScore.toString(),
  //               Icons.track_changes,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTodaysAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Analytics',
          style: TextStyle(
            color: Color(0xFF565ADD),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Today\'s Call Count',
                c.todayCallCount.value.toString(),
                Icons.phone,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Today\'s Avg Score',
                c.todayAvgScore.value.toString(),
                Icons.track_changes,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent Analytics',
                  style: TextStyle(
                    color: Color(0xFF565ADD),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '($currentDateRange)',
                  style: TextStyle(
                    color: Color(0xFF9D9D9D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // Filter Button
            InkWell(
              onTap: () {
                _showFilterBottomSheet();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF565ADD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: Color(0xFF565ADD),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Call Count',
                c.agentCallCount.toString(),
                Icons.phone,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Avg Score',
                c.agentAvgScore.toString(),
                Icons.track_changes,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildChartCard(),
        SizedBox(height: 16),
        _buildScoreCards(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF9D9D9D),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                color: Color(0xFF565ADD),
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFF565ADD),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'AGENT\'S SCORE',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'Tap points for details',
                style: TextStyle(
                  color: Color(0xFF9D9D9D),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Color(0xFF9D9D9D),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      // getTitlesWidget: (value, meta) {
                      //   if (value.toInt() < chartLabels.length) {
                      //     return Text(
                      //       chartLabels[value.toInt()],
                      //       style: TextStyle(
                      //         color: Color(0xFF9D9D9D),
                      //         fontSize: 10,
                      //       ),
                      //     );
                      //   }
                      //   return Text('');
                      // },
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        return i < c.chartLabels.length
                            ? Text(c.chartLabels[i],
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF9D9D9D)))
                            : Text('');
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: c.chartSpots,
                    isCurved: true,
                    color: Color(0xFF565ADD),
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB1BFFF).withValues(alpha: 0.8),
                          Color(0xFFB1BFFF).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Color(0xFF565ADD),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (event is FlTapUpEvent &&
                        touchResponse != null &&
                        touchResponse.lineBarSpots != null) {
                      final spot = touchResponse.lineBarSpots!.first;
                      final index = spot.spotIndex;

                      // Get the position of the touch
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final position =
                          renderBox.globalToLocal(event.localPosition);

                      _showTooltip(context, index, position);
                    }
                  },
                  // touchTooltipData: LineTouchTooltipData(
                  //   // tooltipBgColor: Colors.transparent,
                  //   getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  //     return []; // Return empty to hide default tooltip
                  //   },
                  // ),
                ),
                minY: 0,
                //maxY: 30,
                maxY: c.chartSpots
                        .map((s) => s.y)
                        .fold(0.0, (a, b) => b > a ? b : a) +
                    5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildScoreCards() {
  //   return Column(
  //     children: [
  //       _buildScoreCard('Agent\'s Score', agentScore.toString()),
  //       SizedBox(height: 12),
  //       _buildScoreCard('Avg Product Score', avgProductScore.toString()),
  //       SizedBox(height: 12),
  //       _buildScoreCard('Avg Behavior Score', avgBehaviorScore.toString()),
  //     ],
  //   );
  // }

  Widget _buildScoreCards() => Column(
        children: [
          _buildScoreCard('Agent\'s Score', c.agentScore.value.toString()),
          SizedBox(height: 12),
          _buildScoreCard(
              'Avg Product Score', c.avgProductScore.value.toString()),
          SizedBox(height: 12),
          _buildScoreCard(
              'Avg Behavior Score', c.avgBehaviorScore.value.toString()),
        ],
      );

  Widget _buildScoreCard(String title, String score) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomNavigation() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       border: Border(
  //         top: BorderSide(color: Color(0xFFEBEBEB), width: 1),
  //       ),
  //     ),
  //     child: SafeArea(
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(vertical: 12),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             _buildNavItem(Icons.home, 'Home', false),
  //             _buildNavItem(Icons.bar_chart, 'Analytics', true),
  //             _buildMicButton(),
  //             _buildNavItem(Icons.history, 'History', false),
  //             _buildNavItem(Icons.person, 'Profile', false),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNavItem(IconData icon, String label, bool isActive) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(
  //         icon,
  //         color: isActive ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
  //         size: 24,
  //       ),
  //       SizedBox(height: 4),
  //       InkWell(
  //         onTap: () {
  //           if (label == 'Profile') {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(builder: (_) => ProfileScreen()),
  //             );
  //           }
  //           if (label == 'Home') {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(builder: (_) => Home()),
  //             );
  //           }
  //         },
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             color: isActive ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
  //             fontSize: 12,
  //             fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  // Widget _buildMicButton() {
  //   return Container(
  //     width: 56,
  //     height: 56,
  //     decoration: BoxDecoration(
  //       color: Color(0xFF565ADD),
  //       shape: BoxShape.circle,
  //     ),
  //     child: Icon(
  //       Icons.mic,
  //       color: Colors.white,
  //       size: 24,
  //     ),
  //   );
  // }
}
//
// class TrophyPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Color(0xFFFFA31A)
//       ..style = PaintingStyle.fill;
//
//     // Trophy cup
//     final cupRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.5);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(cupRect, Radius.circular(size.width * 0.3)),
//       paint,
//     );
//
//     // Trophy handles
//     final leftHandle = Rect.fromLTWH(size.width * 0.05, size.height * 0.15, size.width * 0.15, size.height * 0.4);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(leftHandle, Radius.circular(size.width * 0.075)),
//       paint,
//     );
//
//     final rightHandle = Rect.fromLTWH(size.width * 0.8, size.height * 0.15, size.width * 0.15, size.height * 0.4);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(rightHandle, Radius.circular(size.width * 0.075)),
//       paint,
//     );
//
//     // Trophy base
//     final baseRect = Rect.fromLTWH(size.width * 0.3, size.height * 0.6, size.width * 0.4, size.height * 0.25);
//     canvas.drawRect(baseRect, paint);
//
//     // Star
//     final starPaint = Paint()
//       ..color = Color(0xFFFFD51A)
//       ..style = PaintingStyle.fill;
//
//     final starCenter = Offset(size.width * 0.5, size.height * 0.35);
//     final starRadius = size.width * 0.08;
//
//     final starPath = Path();
//     for (int i = 0; i < 5; i++) {
//       final angle = (i * 2 * math.pi) / 5 - math.pi / 2;
//       final x = starCenter.dx + starRadius * 0.6 * (i % 2 == 0 ? 1 : 0.4) * math.cos(angle);
//       final y = starCenter.dy + starRadius * 0.6 * (i % 2 == 0 ? 1 : 0.4) * math.sin(angle);
//       if (i == 0) {
//         starPath.moveTo(x, y);
//       } else {
//         starPath.lineTo(x, y);
//       }
//     }
//     starPath.close();
//     canvas.drawPath(starPath, starPaint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
