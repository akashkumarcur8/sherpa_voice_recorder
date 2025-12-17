
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/agent_detail_model.dart';
import '../services/delivery_tracker_service.dart';

class AgentDetailController extends GetxController {
  // Service instance
  final DeliveryTrackerService _service = DeliveryTrackerService();

  final Rx<AgentDetailModel?> agentDetail = Rx<AgentDetailModel?>(null);
  final RxBool isLoading = false.obs;
  final RxInt selectedImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments != null && arguments['agentId'] != null) {
      loadAgentDetails(arguments['agentId']);
    }
  }

  // Load agent details from API
  Future<void> loadAgentDetails(String agentId) async {
    try {
      isLoading.value = true;

      // Fetch agent details from API
      final data = await _service.fetchAgentDetail(agentId);

      // Convert to model
      agentDetail.value = AgentDetailModel.fromJson(data);

    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load agent details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Set null on error
      agentDetail.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Select image from gallery
  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  // Open location on map
  void openLocationOnMap() {
    if (agentDetail.value?.geotrackingLocation != null) {
      // TODO: Implement map opening functionality
      // You can use url_launcher package or google_maps_flutter

      Get.snackbar(
        'Location',
        'Opening location on map...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Example with url_launcher:
      // final location = agentDetail.value!.geotrackingLocation;
      // final url = 'https://www.google.com/maps/search/?api=1&query=$location';
      // launchUrl(Uri.parse(url));
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    if (agentDetail.value != null) {
      await loadAgentDetails(agentDetail.value!.agentId);
    }
  }

  // Retry loading (for error state)
  Future<void> retryLoading(String agentId) async {
    await loadAgentDetails(agentId);
  }
}

