import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class MiceBlinkingController extends GetxController with GetTickerProviderStateMixin {
  final isRecording = false.obs;
  late AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.3,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
  }

  void startAnimation() {
    isRecording.value = true;
    animationController.forward();
  }

  void stopAnimation() {
    isRecording.value = false;
    animationController.stop();
    animationController.value = 1.0; // reset scale
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
