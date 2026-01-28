import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'formController.dart';
class HelpForm extends StatelessWidget {
  final HelpFormController controller = Get.put(HelpFormController());

  // Tooltip anchor + overlay
  final LayerLink _infoLink = LayerLink();
  OverlayEntry? _infoTooltip;

  HelpForm({super.key});

  void _toggleInfoTooltip(BuildContext context) {
    if (_infoTooltip == null) {
      _showInfoTooltip(context);
    } else {
      _hideInfoTooltip();
    }
  }

  void _showInfoTooltip(BuildContext context) {
    final overlay = Overlay.of(context);
    _infoTooltip = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              // tap anywhere to dismiss
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideInfoTooltip,
              ),
              // bubble anchored to the info icon
              CompositedTransformFollower(
                link: _infoLink,
                showWhenUnlinked: false,
                offset: const Offset(-235, 38),
                child: const _InfoBubble(),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(_infoTooltip!);
  }

  void _hideInfoTooltip() {
    _infoTooltip?.remove();
    _infoTooltip = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ADD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Sherpa Help Centre',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          CompositedTransformTarget(
            link: _infoLink,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 25),
              onPressed: () => _toggleInfoTooltip(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Agent ID*',
              controller: controller.agentIdController,
              hintText: 'Enter Your Agent ID',
              errorText: controller.agentIdError,


            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Agent Name*',
              controller: controller.agentNameController,
              hintText: 'Enter Your Name',
              errorText: controller.agentNameError,
            ),
            const SizedBox(height: 20),
            _buildDateField(),
            const SizedBox(height: 20),
            _buildUploadSection(),
            const SizedBox(height: 20),
            _buildAudioSection(),
            const SizedBox(height: 20),
            _buildStatusSection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required RxString errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF565ADD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText.value.isNotEmpty ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Obx(() => errorText.value.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorText.value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Device Delivery*',
          style: TextStyle(
            color: Color(0xFF565ADD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.dateError.value.isNotEmpty ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: controller.dateController,
            readOnly: true,
            decoration: const InputDecoration(
              hintText: 'dd-mm-yyyy',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF565ADD),
                size: 20,
              ),
            ),
            onTap: () => controller.selectDate(Get.context!),
          ),
        )),
        Obx(() => controller.dateError.value.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            controller.dateError.value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Device Image*',
          style: TextStyle(
            color: Color(0xFF565ADD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.imageError.value.isNotEmpty ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              if (controller.uploadedImages.isEmpty)
                InkWell(
                  onTap: controller.captureImage,
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'click to capture',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.uploadedImages.asMap().entries.map((entry) {
                          int index = entry.key;
                          File imageFile = entry.value;
                          return GestureDetector(
                            onTap: () => controller.showImagePreview(imageFile, index),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(imageFile),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => controller.removeImage(index),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (controller.uploadedImages.length < 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: InkWell(
                            onTap: controller.captureImage,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.grey[600],
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        )),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '*Instructions : 3 Device Images',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
            Text(
              'Exterior of the case, 2 microphones, 1 connector. (max 2 MB)',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
            Obx(() => controller.imageError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                controller.imageError.value,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
              ),
            )
                : const SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Quality Tester*',
          style: TextStyle(
            color: Color(0xFF565ADD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: InkWell(
            onTap: controller.startAudioQualityTest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isRecording.value ? Icons.stop : Icons.mic_outlined,
                  color: controller.isRecording.value ? Colors.red : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.isRecording.value ? 'recording...' :
                  controller.audioRecordingPath.value.isNotEmpty ? 'Recording completed' : 'click to start recording',
                  style: TextStyle(
                    color: controller.isRecording.value ? Colors.red :
                    controller.audioRecordingPath.value.isNotEmpty ? Colors.green : Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 4),
        Text(
          '*max size of 2 MB',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return  Obx(() =>  Row(
      children: [
        const Text(
          'STATUS :',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(width: 12),
        controller.audioRecordingPath.value.isNotEmpty ?
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Audio Quality Check Pass',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ): Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: Colors.grey[600],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Pending',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      // Use the reactive _isFormValid variable
      final isFormValid = controller.isFormValid;
      final isSubmitting = controller.isSubmitting.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSubmitting
              ? null
              : isFormValid
              ? controller.submitForm
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid
                ? const Color(0xFF565ADD)  // AppBar color when enabled
                : Colors.grey[400],        // Grey when disabled
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

// ===== Tooltip bubble + pointer =====

class _InfoBubble extends StatelessWidget {
  const _InfoBubble();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BubblePointer(),
          Material(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Complete Your Delivery Submission',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),

                  Text(
                    '• Enter Delivery Details :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Input your Agent ID, full name, and the delivery date.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '• Add Device Photos (3 images total) :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Shot 1 - Exterior of the case.\nShot 2 - 2 microphones.\nShot 3 - 1 connector.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '• Upload Test Recording :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Record a 10-second clip repeating the on-screen phrase.\nSubmit the file and confirm the quality check (Pass/Fail).',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '• Review & Submit :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Verify every field is complete.\nClick Submit to automatically tag the job as Delivered.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '• Confirmation :',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'A success message appears once the delivery is logged.',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubblePointer extends StatelessWidget {
  const _BubblePointer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: SizedBox(
        width: 24,
        height: 15,
        child: CustomPaint(
          painter: _TrianglePainter(color: Colors.black.withOpacity(0.9)),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== Image Preview Dialog =====

class ImagePreviewDialog extends StatelessWidget {
  final File imageFile;
  final int index;
  final VoidCallback onDelete;

  const ImagePreviewDialog({
    super.key,
    required this.imageFile,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Black background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Top bar with close and delete buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Image counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Image ${index + 1}/3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Delete Image'),
                        content: const Text('Are you sure you want to delete this image?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: onDelete,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instructions at bottom
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getImageInstruction(index),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pinch to zoom • Drag to pan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getImageInstruction(int index) {
    switch (index) {
      case 0:
        return 'Image 1: Device Image';
      case 1:
        return 'Image 2: Device Image';
      case 2:
        return 'Image 3: Device Image';
      default:
        return 'Device Image';
    }
  }
}