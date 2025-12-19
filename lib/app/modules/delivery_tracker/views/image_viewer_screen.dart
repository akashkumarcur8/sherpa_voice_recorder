import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/image_viewer_controller.dart';

class ImageViewerScreen extends GetView<ImageViewerController> {
  const ImageViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () {
            Get.delete<ImageViewerController>();
            Get.back();
          },
        ),
        title: Obx(
          () => Text(
            '${controller.currentIndex.value + 1} / ${controller.imageUrls.length}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(controller.imageUrls[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(
              tag: controller.imageUrls[index],
            ),
          );
        },
        itemCount: controller.imageUrls.length,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            color: AppColors.primary,
          ),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: controller.pageController,
        onPageChanged: controller.onPageChanged,
      ),
    );
  }
}
