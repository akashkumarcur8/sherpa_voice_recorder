import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agent_detail_controller.dart';
import '../controllers/image_viewer_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import 'image_viewer_screen.dart';

class AgentDetailScreen extends GetView<AgentDetailController> {
  const AgentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (controller.agentDetail.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildDetailItem(
                  'Agent ID',
                  controller.agentDetail.value!.agentId,
                ),
                const SizedBox(height: 24),
                _buildDetailItem(
                  'Agent Name',
                  controller.agentDetail.value!.agentName,
                ),
                const SizedBox(height: 24),
                _buildDetailItem(
                  'Date of Device Delivery',
                  controller.agentDetail.value!.dateOfDeviceDelivery,
                ),
                const SizedBox(height: 24),
                _buildDeviceImagesSection(),
                const SizedBox(height: 24),
                _buildLocationSection(),
                const SizedBox(height: 24),
                _buildAudioQualitySection(),
                const SizedBox(height: 24),
                _buildStatusSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Agent Delivery Details',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Device Image',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final images = controller.agentDetail.value?.deviceImages ?? [];

          if (images.isEmpty) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'No images available',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            );
          }

          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];

                return Obx(() {
                  final isSelected =
                      controller.selectedImageIndex.value == index;
                  return GestureDetector(
                    onTap: () {
                      controller.selectImage(index);
                      // Navigate to full screen image viewer
                      if (imageUrl.isNotEmpty) {
                        Get.put(
                          ImageViewerController(
                            imageUrls: images,
                            initialIndex: index,
                          ),
                        );
                        Get.to(() => const ImageViewerScreen());
                      }
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageWidget(imageUrl),
                      ),
                    ),
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderIcon();
    }

    return Image.network(
      imageUrl,
      width: 80,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          color: AppColors.darkGrey,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: AppColors.darkGrey,
      child: const Icon(
        Icons.devices,
        size: 40,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geotracking Verified Location',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                controller.agentDetail.value?.geotrackingLocation ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.openLocationOnMap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioQualitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Quality Tester',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              controller.agentDetail.value?.audioQualityTestPassed ?? false
                  ? 'Test Passed'
                  : 'Test Failed',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: controller.agentDetail.value?.audioQualityTestPassed ??
                        false
                    ? AppColors.success
                    : AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'STATUS :',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.agentDetail.value?.status ?? 'Delivered',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
