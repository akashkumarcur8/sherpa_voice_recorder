import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/complaint_model.dart';
import '../models/complaint_response.dart';
import '../services/complaint_service.dart';

enum ComplaintFilter { all, pending, resolved, closed, last7Days, last30Days }

class ComplaintController extends GetxController {
  final ComplaintService _service = ComplaintService();

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

  @override
  void onInit() {
    super.onInit();
    fetchComplaintsData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future fetchComplaintsData() async {
    try {
      isLoading.value = true;

      final ComplaintResponse response = await _service.fetchComplaints(
        managerId: managerId,
        companyId: companyId,
      );

      if (response.status) {
        // Store complaints
        pendingComplaints.value = response.pendingComplaints as List<ComplaintModel>;
        resolvedComplaints.value = response.resolvedComplaints as List<ComplaintModel>;

        // Update statistics
        pendingCount.value = response.statistics.pending;
        resolvedCount.value = response.statistics.resolved;
        totalCount.value = response.statistics.total;

        // Apply current filter
        applyFilter(selectedFilter.value);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load complaints: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(ComplaintFilter filter) {
    selectedFilter.value = filter;
    _applyFilterAndSearch();
  }

  void searchComplaints(String query) {
    searchQuery.value = query;
    _applyFilterAndSearch();
  }

  void _applyFilterAndSearch() {
    List<ComplaintModel> filteredComplaints;

    switch (selectedFilter.value) {
      case ComplaintFilter.pending:
        filteredComplaints = List.from(pendingComplaints);
        break;
      case ComplaintFilter.resolved:
      case ComplaintFilter.closed:
        filteredComplaints = List.from(resolvedComplaints);
        break;
      case ComplaintFilter.last7Days:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        filteredComplaints = [
          ...pendingComplaints,
          ...resolvedComplaints,
        ].where((complaint) {
          return complaint.dateTime.isAfter(sevenDaysAgo);
        }).toList();
        break;
      case ComplaintFilter.last30Days:
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        filteredComplaints = [
          ...pendingComplaints,
          ...resolvedComplaints,
        ].where((complaint) {
          return complaint.dateTime.isAfter(thirtyDaysAgo);
        }).toList();
        break;
      case ComplaintFilter.all:
      default:
        filteredComplaints = [
          ...pendingComplaints,
          ...resolvedComplaints,
        ];
        break;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      displayedComplaints.value = filteredComplaints.where((complaint) {
        return complaint.complaintId.toLowerCase().contains(query) ||
            complaint.agentName.toLowerCase().contains(query) ||
            complaint.agentId.toLowerCase().contains(query);
      }).toList();
    } else {
      displayedComplaints.value = filteredComplaints;
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
      case ComplaintFilter.all:
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
      case ComplaintFilter.all:
      default:
        return 'No complaints found';
    }
  }
}