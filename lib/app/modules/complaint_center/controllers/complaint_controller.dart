import 'package:get/get.dart';
import '../models/complaint_model.dart';
import '../models/complaint_response.dart';
import '../services/complaint_service.dart';

enum ComplaintFilter { all, pending, resolved }

class ComplaintController extends GetxController {
  final ComplaintService _service = ComplaintService();

  // Replace these with actual values from your auth/user management
  final int managerId = 4973;
  final int companyId = 42;

  final RxList pendingComplaints = [].obs;
  final RxList resolvedComplaints = [].obs;
  final RxList displayedComplaints = [].obs;

  final RxBool isLoading = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt resolvedCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final Rx selectedFilter = ComplaintFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplaintsData();
  }

  Future fetchComplaintsData() async {
    try {
      isLoading.value = true;

      final response = await _service.fetchComplaints(
        managerId: managerId,
        companyId: companyId,
      );

      if (response.status) {
        // Store complaints
        pendingComplaints.value = response.pendingComplaints;
        resolvedComplaints.value = response.resolvedComplaints;

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

    switch (filter) {
      case ComplaintFilter.pending:
        displayedComplaints.value = pendingComplaints;
        break;
      case ComplaintFilter.resolved:
        displayedComplaints.value = resolvedComplaints;
        break;
      case ComplaintFilter.all:
      default:
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
      case ComplaintFilter.all:
      default:
        return 'Total Complaints';
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