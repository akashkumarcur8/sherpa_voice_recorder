import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/complaint_model.dart';
import '../models/complaint_response.dart';
import '../services/complaint_service.dart';

enum ComplaintFilter { all, pending, resolved, closed, last7Days, last30Days }

class ComplaintController extends GetxController {
  final ComplaintService _service = ComplaintService();
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

  // Replace these with actual values from your auth/user management
  final int managerId = 4973;
  final int companyId = 42;

  final RxList<ComplaintModel> pendingComplaints = <ComplaintModel>[].obs;
  final RxList<ComplaintModel> resolvedComplaints = <ComplaintModel>[].obs;
  final RxList<ComplaintModel> displayedComplaints = <ComplaintModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt resolvedCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final Rx selectedFilter = ComplaintFilter.all.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchComplaintsData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future fetchComplaintsData() async {
    try {
      isLoading.value = true;

      // Determine API parameters based on current filter
      String? statusParam;
      String? dateRangeParam;

      switch (selectedFilter.value) {
        case ComplaintFilter.pending:
          statusParam = 'pending';
          break;
        case ComplaintFilter.resolved:
          statusParam = 'resolved';
          break;
        case ComplaintFilter.closed:
          statusParam = 'closed';
          break;
        case ComplaintFilter.last7Days:
          dateRangeParam = 'last7Days';
          break;
        case ComplaintFilter.last30Days:
          dateRangeParam = 'last30Days';
          break;
        case ComplaintFilter.all:
        default:
          // No filter params - get all
          break;
      }

      // If there's a search query, use search API
      if (searchQuery.value.isNotEmpty) {
        final searchResults = await _service.searchComplaints(
          managerId: managerId,
          companyId: companyId,
          query: searchQuery.value,
        );
        displayedComplaints.value = searchResults;
        
        // Update counts from search results
        pendingCount.value = searchResults.where((c) => c.status.toLowerCase() == 'pending').length;
        resolvedCount.value = searchResults.where((c) => c.status.toLowerCase() == 'resolved').length;
        totalCount.value = searchResults.length;
      } else {
        // Use main complaints API with filters
        final ComplaintResponse response = await _service.fetchComplaints(
          managerId: managerId,
          companyId: companyId,
          status: statusParam,
          dateRange: dateRangeParam,
        );

        if (response.status) {
          // Store complaints
          pendingComplaints.value = response.pendingComplaints as List<ComplaintModel>;
          resolvedComplaints.value = response.resolvedComplaints as List<ComplaintModel>;

          // Update statistics
          pendingCount.value = response.statistics.pending;
          resolvedCount.value = response.statistics.resolved;
          totalCount.value = response.statistics.total;

          // Display based on filter
          _updateDisplayedComplaints();
        } else {
          _logger.w('⚠️ ComplaintController: API returned status false: ${response.message}');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('❌ ComplaintController: Error fetching complaints: $e', error: e, stackTrace: stackTrace);
      // Don't show technical errors to users - just log them
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(ComplaintFilter filter) {
    selectedFilter.value = filter;
    // Clear search when changing filter
    searchQuery.value = '';
    searchController.clear();
    fetchComplaintsData();
  }

  void searchComplaints(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // If search is cleared, reload with current filter immediately
      fetchComplaintsData();
    } else {
      // Debounce search API calls - wait 500ms after user stops typing
      _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        fetchComplaintsData();
      });
    }
  }

  void _updateDisplayedComplaints() {
    switch (selectedFilter.value) {
      case ComplaintFilter.pending:
        displayedComplaints.value = List.from(pendingComplaints);
        break;
      case ComplaintFilter.resolved:
      case ComplaintFilter.closed:
        displayedComplaints.value = List.from(resolvedComplaints);
        break;
      case ComplaintFilter.last7Days:
      case ComplaintFilter.last30Days:
        // For date range filters, API already returns filtered results
        displayedComplaints.value = [
          ...pendingComplaints,
          ...resolvedComplaints,
        ];
        break;
      case ComplaintFilter.all:
        displayedComplaints.value = [
          ...pendingComplaints,
          ...resolvedComplaints,
        ];
        break;
    }
  }

  Future refreshComplaints() async {
    await fetchComplaintsData();
  }

  String get filterTitle {
    switch (selectedFilter.value) {
      case ComplaintFilter.pending:
        return 'Pending Complaints';
      case ComplaintFilter.resolved:
        return 'Resolved Complaints';
      case ComplaintFilter.closed:
        return 'Closed Complaints';
      case ComplaintFilter.last7Days:
        return 'Last 7 Days';
      case ComplaintFilter.last30Days:
        return 'Last 30 Days';
      case ComplaintFilter.all:
        return 'Recent Tickets';
      default:
        return 'Recent Tickets';
    }
  }

  String get emptyStateMessage {
    switch (selectedFilter.value) {
      case ComplaintFilter.pending:
        return 'No pending complaints found';
      case ComplaintFilter.resolved:
        return 'No resolved complaints found';
      case ComplaintFilter.closed:
        return 'No closed complaints found';
      case ComplaintFilter.last7Days:
        return 'No complaints found in last 7 days';
      case ComplaintFilter.last30Days:
        return 'No complaints found in last 30 days';
      case ComplaintFilter.all:
        return 'No complaints found';
      default:
        return 'No complaints found';
    }
  }
}