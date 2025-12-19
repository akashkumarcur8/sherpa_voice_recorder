import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ImageViewerController extends GetxController {
  final List<String> imageUrls;
  final RxInt currentIndex = 0.obs;
  late PageController pageController;

  ImageViewerController({
    required this.imageUrls,
    int initialIndex = 0,
  }) {
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

