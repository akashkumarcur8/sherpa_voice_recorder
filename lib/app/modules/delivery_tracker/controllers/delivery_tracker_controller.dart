import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../models/delivery_stats_model.dart';
import '../models/agent_model.dart';
import '../services/delivery_tracker_service.dart';
import '../../raise_ticket/views/widgets/success_dialog.dart';

class DeliveryTrackerController extends GetxController {
  final DeliveryTrackerService _service = DeliveryTrackerService();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );
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

  // Currently displayed agents (based on filter and search)
  final RxList<AgentModel> filteredAgents = <AgentModel>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Sort functionality
  final RxString selectedSort = 'Recent'.obs; // 'Recent', 'Oldest', 'Sort By'

  // Track which category was last selected (sort or status)
  // Default to 'status' so "All" shows as active initially
  final RxString lastSelectedCategory = 'status'.obs; // 'sort' or 'status'

  // Selection management for pending agents
  final RxSet<String> selectedAgentIds = <String>{}.obs;
  final RxBool isSelectAllChecked = false.obs;

  // User data from SharedPreferences
  final RxString empName = ''.obs;
  final RxString email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _applyFiltersAndSearch();
  }

  void selectCard(int index, String filter) {
    selectedCardIndex.value = index;
    // Update filter and apply
    selectedFilter.value = filter;
    // If "All" is selected, reset sort to default
    if (filter == 'All') {
      selectedSort.value = 'Recent';
    }
    _applyFiltersAndSearch();
    // Clear selection when filter changes
    clearSelection();
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    try {
      var fetchEmail = await SharedPrefHelper.getpref("email");
      var fetchEmpName = await SharedPrefHelper.getpref("emp_name");

      email.value = fetchEmail.isNotEmpty ? fetchEmail : 'No Email';
      empName.value = fetchEmpName.isNotEmpty ? fetchEmpName : 'No Name';
    } catch (e) {
      _logger.e('❌ DeliveryTrackerController: Error loading user data: $e');
      email.value = 'No Email';
      empName.value = 'No Name';
    }
  }

  // Load data from API (single API call)
  Future<void> loadData() async {
    _logger.d('📊 DeliveryTrackerController: Loading data...');
    try {
      isLoading.value = true;
      var managerId = await SharedPrefHelper.getpref("manager_id");
      var companyId = await SharedPrefHelper.getpref("company_id");

      // Fetch all data from single API
      final data = await _service.fetchDeliveryData(managerId, companyId);

      // Update stats
      stats.value = data['stats'];
      _logger
          .d('📊 DeliveryTrackerController: Fetched stats: ${data['stats']}');

      // Update all agent lists
      pendingAgents.value = data['pendingAgents'];
      deliveredAgents.value = data['deliveredAgents'];
      allAgents.value = data['allAgents'];

      _logger.d(
          '📊 DeliveryTrackerController: Pending: ${pendingAgents.length}, Delivered: ${deliveredAgents.length}, Total: ${allAgents.length}');

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

  // Handle sort selection from sort filter bar
  // Sort options (Recent, Oldest) are independent of status filters (All, Pending, Delivered)
  void handleSortSelection(String sortValue) {
    // If "Sort By" is selected, reset to default
    if (sortValue == 'Sort By') {
      selectedSort.value = 'Recent';
    } else {
      selectedSort.value = sortValue;
    }
    // Track that sort was last selected
    lastSelectedCategory.value = 'sort';
    // Sort selection does NOT affect status filter - they work independently
    _applyFiltersAndSearch();
  }

  // Handle status selection from status filter bar
  // When selecting Pending/Delivered, "All" is automatically disabled
  void handleStatusSelection(String statusValue) {
    selectedFilter.value =
        statusValue; // This replaces "All" with the new status
    // If "All" is selected, reset sort to default
    if (statusValue == 'All') {
      selectedSort.value = 'Recent';
    }
    // Track that status was last selected
    lastSelectedCategory.value = 'status';
    _applyFiltersAndSearch();
    // Clear selection when status filter changes
    clearSelection();
  }

  // Handle filter/sort selection from filter bar (kept for backward compatibility)
  void handleFilterSelection(String filterValue) {
    // Check if it's a status filter
    if (filterValue == 'Pending' || filterValue == 'Delivered') {
      handleStatusSelection(filterValue);
    }
    // Check if it's a sort option
    else if (filterValue == 'Oldest' ||
        filterValue == 'Recent' ||
        filterValue == 'Sort By') {
      handleSortSelection(filterValue);
    }
  }

  // Search agents
  void searchAgents(String query) {
    searchQuery.value = query;
    _applyFiltersAndSearch();
  }

  // Apply filters, search, and sort
  void _applyFiltersAndSearch() {
    List<AgentModel> baseList;

    // Apply status filter
    if (selectedFilter.value == 'Pending') {
      baseList = List.from(pendingAgents);
    } else if (selectedFilter.value == 'Delivered') {
      baseList = List.from(deliveredAgents);
    } else {
      // 'All' or 'Select Option' - show all agents
      baseList = List.from(allAgents);
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      baseList = baseList.where((agent) {
        return agent.agentName.toLowerCase().contains(query) ||
            agent.agentId.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort
    if (selectedSort.value == 'Oldest') {
      // Sort by oldest first (assuming we have a date field, for now just reverse)
      baseList = baseList.reversed.toList();
    } else if (selectedSort.value == 'Recent') {
      // Sort by recent first (default order)
      // Already in correct order
    }

    filteredAgents.value = baseList;
    _logger.d(
        '🔍 DeliveryTrackerController: Filter: ${selectedFilter.value}, Sort: ${selectedSort.value}, Search: ${searchQuery.value}, Showing ${filteredAgents.length} agents');
  }

  // Toggle selection for a single agent
  void toggleAgentSelection(String agentId) {
    if (selectedAgentIds.contains(agentId)) {
      selectedAgentIds.remove(agentId);
    } else {
      selectedAgentIds.add(agentId);
    }
    updateSelectAllState();
  }

  // Toggle select all
  void toggleSelectAll() {
    if (isSelectAllChecked.value) {
      // Deselect all
      selectedAgentIds.clear();
      isSelectAllChecked.value = false;
    } else {
      // Select all pending agents (using agentId for unique identification)
      selectedAgentIds.clear();
      selectedAgentIds.addAll(pendingAgents.map((agent) => agent.agentId));
      isSelectAllChecked.value = true;
    }
  }

  // Update select all checkbox state based on current selection
  void updateSelectAllState() {
    if (selectedFilter.value != 'Pending') {
      isSelectAllChecked.value = false;
      return;
    }
    isSelectAllChecked.value =
        selectedAgentIds.length == pendingAgents.length &&
            pendingAgents.isNotEmpty;
  }

  // Clear all selections
  void clearSelection() {
    selectedAgentIds.clear();
    isSelectAllChecked.value = false;
  }

  // Check if an agent is selected
  bool isAgentSelected(String agentId) {
    return selectedAgentIds.contains(agentId);
  }

  // Send reminder to selected agents
  Future<void> sendReminder() async {
    try {
      // Get selected agents
      final selectedAgents = pendingAgents
          .where((agent) => selectedAgentIds.contains(agent.agentId))
          .toList();

      if (selectedAgents.isEmpty) {
        Get.snackbar(
          'Info',
          'Please select at least one agent to send reminder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Get user IDs for API call
      final agentIdsToNotify =
          selectedAgents.map((agent) => agent.userId).toList();

      // Call API to send reminder
      final success = await _service.sendReminder(agentIdsToNotify);

      if (success) {
        // Get recipient name(s) for success dialog
        String recipientName;
        final totalCount = selectedAgents.length;

        if (totalCount == 1) {
          recipientName = selectedAgents.first.agentName;
        } else if (totalCount <= 3) {
          // Show all names if 3 or fewer
          recipientName = selectedAgents.map((a) => a.agentName).join(', ');
        } else {
          // Show first 3 names and count of others
          final firstThree =
              selectedAgents.take(3).map((a) => a.agentName).join(', ');
          final othersCount = totalCount - 3;
          recipientName =
              '$firstThree and $othersCount other${othersCount == 1 ? '' : 's'}';
        }

        // Clear selection after successful send
        clearSelection();

        // Show success dialog with recipient name
        SuccessDialog.show(
          title: 'Successful',
          message: 'Your reminder has been sent to',
          recipientName: recipientName,
        );
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

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }
}
