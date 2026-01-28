import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../models/delivery_stats_model.dart';
import '../models/agent_model.dart';
import '../services/delivery_tracker_service.dart';

class DeliveryTrackerController extends GetxController {
  final DeliveryTrackerService _service = DeliveryTrackerService();
  var selectedCardIndex = Rxn<int>();

  // Observable variables
  final Rx<DeliveryStatsModel> stats = DeliveryStatsModel(
    pending: 0,
    delivered: 0,
    totalAgents: 0,
  ).obs;

  // Store all three lists separately
  final RxList<AgentModel> pendingAgents = <AgentModel>[].obs;
  final RxList<AgentModel> deliveredAgents = <AgentModel>[].obs;
  final RxList<AgentModel> allAgents = <AgentModel>[].obs;

  // Currently displayed agents (based on filter)
  final RxList<AgentModel> filteredAgents = <AgentModel>[].obs;
  final RxString selectedFilter = 'Select Option'.obs;
  final RxBool isLoading = false.obs;

  // User data from SharedPreferences
  final RxString empName = ''.obs;
  final RxString email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadData();
  }


  void selectCard(int index, String filter) {
    selectedCardIndex.value = index;
    filterAgents(filter);
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    try {
      var fetchEmail = await SharedPrefHelper.getpref("email");
      var fetchEmpName = await SharedPrefHelper.getpref("emp_name");

      email.value = fetchEmail ?? 'No Email';
      empName.value = fetchEmpName ?? 'No Name';
    } catch (e) {
      email.value = 'No Email';
      empName.value = 'No Name';
    }
  }

  // Load data from API (single API call)
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      var managerId = await SharedPrefHelper.getpref("manager_id");
      var companyId = await SharedPrefHelper.getpref("company_id");

      // Fetch all data from single API
      final data = await _service.fetchDeliveryData(managerId, companyId);

      // Update stats
      stats.value = data['stats'];

      // Update all agent lists
      pendingAgents.value = data['pendingAgents'];
      deliveredAgents.value = data['deliveredAgents'];
      allAgents.value = data['allAgents'];


      // Set filtered agents to all by default
      filteredAgents.value = allAgents;

    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Set default empty values on error
      stats.value = DeliveryStatsModel(
        pending: 0,
        delivered: 0,
        totalAgents: 0,
      );
      pendingAgents.value = [];
      deliveredAgents.value = [];
      allAgents.value = [];
      filteredAgents.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Filter agents based on selection
  void filterAgents(String filter) {
    selectedFilter.value = filter;

    if (filter == 'Pending') {
      filteredAgents.value = pendingAgents;
    } else if (filter == 'Delivered') {
      filteredAgents.value = deliveredAgents;
    } else {
      // 'Select Option' or 'All' - show all agents
      filteredAgents.value = allAgents;
    }

  }

  // Send reminder to pending agents
  Future<void> sendReminder() async {
    try {
      // Get all pending agent IDs
      final pendingAgentIds = pendingAgents
          .map((agent) => agent.userId)
          .toList();

      if (pendingAgentIds.isEmpty) {
        Get.snackbar(
          'Info',
          'No pending agents to send reminder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Call API to send reminder
      final success = await _service.sendReminder(pendingAgentIds);

      if (success) {
        // Show success dialog
        Get.dialog(
          _buildSuccessDialog(),
          barrierDismissible: false,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reminder: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSuccessDialog() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reminder Sent\nSuccessfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}