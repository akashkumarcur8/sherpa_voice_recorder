import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/user_ticket_model.dart';
import '../services/raise_ticket_service.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../core/constants/app_strings.dart';

enum TicketFilter { all, pending, resolved, closed, last7Days, last30Days }

class UserTicketsController extends GetxController {
  final RaiseTicketService _service = RaiseTicketService();
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

  String userId = '';
  final RxList<UserTicketModel> displayedTickets = <UserTicketModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt resolvedCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final Rx<TicketFilter> selectedFilter = TicketFilter.all.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    _logger.d('🚀 UserTicketsController: onInit() called');
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    userId = await SharedPrefHelper.getpref(AppStrings.username);
    _logger.d(
        '📱 UserTicketsController: Loaded user_id from SharedPref: "$userId"');
    if (userId.isNotEmpty) {
      _logger.d(
          '✅ UserTicketsController: user_id found, calling fetchTicketsData()');
      fetchTicketsData();
    } else {
      _logger.w('⚠️ UserTicketsController: user_id is empty!');
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchTicketsData() async {
    _logger.d(
        '🔄 UserTicketsController: fetchTicketsData() called, current userId: "$userId"');

    if (userId.isEmpty) {
      _logger.w(
          '⚠️ UserTicketsController: userId is empty, loading from SharedPref...');
      await _loadUserId();
      if (userId.isEmpty) {
        _logger.e('❌ UserTicketsController: userId still empty after loading!');
        // Don't show error to user - just log it
        return;
      }
    }

    try {
      isLoading.value = true;
      _logger.d('⏳ UserTicketsController: Starting API call...');

      // Determine API parameters based on current filter
      String? statusParam;
      String? dateRangeParam;

      switch (selectedFilter.value) {
        case TicketFilter.pending:
          statusParam = 'pending';
          break;
        case TicketFilter.resolved:
          statusParam = 'resolved';
          break;
        case TicketFilter.closed:
          statusParam = 'closed';
          break;
        case TicketFilter.last7Days:
          dateRangeParam = 'last_7_days';
          break;
        case TicketFilter.last30Days:
          dateRangeParam = 'last_30_days';
          break;
        case TicketFilter.all:
          // No filter params - get all
          break;
      }

      // If there's a search query, use search API
      if (searchQuery.value.isNotEmpty) {
        _logger.d(
            '🔍 UserTicketsController: Searching tickets with user_id: "$userId", query: "${searchQuery.value}"');
        final searchResults = await _service.searchUserTickets(
          userId: userId,
          query: searchQuery.value,
        );
        displayedTickets.value = searchResults;

        // Update counts from search results
        pendingCount.value = searchResults
            .where((t) => t.status.toLowerCase() == 'pending')
            .length;
        resolvedCount.value = searchResults
            .where((t) => t.status.toLowerCase() == 'resolved')
            .length;
        totalCount.value = searchResults.length;
      } else {
        // Use main tickets API with filters
        _logger.d(
            '📥 UserTicketsController: Fetching tickets with user_id: "$userId", status: $statusParam, dateRange: $dateRangeParam');
        final List<UserTicketModel> tickets = await _service.fetchUserTickets(
          userId: userId,
          status: statusParam,
          dateRange: dateRangeParam,
        );
        _logger
            .d('✅ UserTicketsController: Received ${tickets.length} tickets');

        displayedTickets.value = tickets;

        // Update statistics
        pendingCount.value =
            tickets.where((t) => t.status.toLowerCase() == 'pending').length;
        resolvedCount.value =
            tickets.where((t) => t.status.toLowerCase() == 'resolved').length;
        totalCount.value = tickets.length;
      }
    } catch (e, stackTrace) {
      _logger.e('❌ UserTicketsController: Error fetching tickets: $e',
          error: e, stackTrace: stackTrace);
      // Don't show technical errors to users - just log them
    } finally {
      isLoading.value = false;
      _logger.d('✅ UserTicketsController: fetchTicketsData() completed');
    }
  }

  void applyFilter(TicketFilter filter) {
    selectedFilter.value = filter;
    // Clear search when changing filter
    searchQuery.value = '';
    searchController.clear();
    fetchTicketsData();
  }

  void searchTickets(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    searchQuery.value = query;

    if (query.isEmpty) {
      // If search is cleared, reload with current filter immediately
      fetchTicketsData();
    } else {
      // Debounce search API calls - wait 500ms after user stops typing
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        fetchTicketsData();
      });
    }
  }

  Future<void> refreshTickets() async {
    await fetchTicketsData();
  }

  String get filterTitle {
    switch (selectedFilter.value) {
      case TicketFilter.pending:
        return 'Pending Tickets';
      case TicketFilter.resolved:
        return 'Resolved Tickets';
      case TicketFilter.closed:
        return 'Closed Tickets';
      case TicketFilter.last7Days:
        return 'Last 7 Days';
      case TicketFilter.last30Days:
        return 'Last 30 Days';
      case TicketFilter.all:
        return 'Recent Tickets';
    }
  }

  String get emptyStateMessage {
    switch (selectedFilter.value) {
      case TicketFilter.pending:
        return 'No pending tickets found';
      case TicketFilter.resolved:
        return 'No resolved tickets found';
      case TicketFilter.closed:
        return 'No closed tickets found';
      case TicketFilter.last7Days:
      case TicketFilter.last30Days:
      case TicketFilter.all:
        return 'No tickets found';
    }
  }
}
