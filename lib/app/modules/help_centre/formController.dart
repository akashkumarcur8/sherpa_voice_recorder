import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../routes/app_routes.dart';
import '../home/home.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import 'audio_quality_test_screen.dart';
import 'formWidget.dart';

// Controller for managing form state
class HelpFormController extends GetxController   {
  final TextEditingController agentIdController = TextEditingController();
  final TextEditingController agentNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Reactive variables
  var isRecording = false.obs;
  var isSubmitting = false.obs;
  var uploadedImages = <File>[].obs;

  var selectedDate = Rxn<DateTime>();
  var audioRecordingPath = ''.obs;
  final RxBool audioTestPassed = false.obs;

  // ADD THESE REACTIVE VARIABLES FOR FORM VALIDATION
  var agentIdValue = ''.obs;
  var agentNameValue = ''.obs;

  final ImagePicker _picker = ImagePicker();

  // Form validation
  var agentIdError = ''.obs;
  var agentNameError = ''.obs;
  var dateError = ''.obs;
  var imageError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to text field changes and update reactive variables
    agentIdController.addListener(() {
      agentIdValue.value = agentIdController.text.trim();
      _validateAgentId();
    });

    agentNameController.addListener(() {
      agentNameValue.value = agentNameController.text.trim();
      _validateAgentName();
    });
  }

  @override
  void onClose() {
    agentIdController.dispose();
    agentNameController.dispose();
    dateController.dispose();
    super.onClose();
  }

  Future<void> startAudioQualityTest() async {
    final result = await Get.to(() => const AudioQualityTestScreen(), arguments: {'audioTest': true});
    if (result is Map && result['status'] == 'passed') {
      audioTestPassed.value = true;
      audioRecordingPath.value = (result['path'] as String?) ?? 'audio_test_passed.wav';
    } else if (result is Map && result['status'] == 'failed') {
      audioTestPassed.value = false;
      audioRecordingPath.value = '';
    }
  }

  void _validateAgentId() {
    if (agentIdValue.value.isEmpty) {
      agentIdError.value = 'Agent ID is required';
    } else {
      agentIdError.value = '';
    }
  }

  void _validateAgentName() {
    if (agentNameValue.value.isEmpty) {
      agentNameError.value = 'Agent Name is required';
    } else {
      agentNameError.value = '';
    }
  }

  void validateDate() {
    if (selectedDate.value == null) {
      dateError.value = 'Date is required';
    } else {
      dateError.value = '';
    }
  }

  void validateImages() {
    if (uploadedImages.length < 3) {
      imageError.value = 'Please upload 3 device images';
    } else {
      imageError.value = '';
    }
  }

  // FIXED: Now uses reactive variables instead of TextEditingController.text
  bool get isFormValid {
    return agentIdValue.value.isNotEmpty &&
        agentNameValue.value.isNotEmpty &&
        selectedDate.value != null &&
        uploadedImages.length == 3 &&
        audioRecordingPath.value.isNotEmpty;
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      validateDate();
    }
  }

  void addImage(String imagePath) {
    if (uploadedImages.length < 3) {
      uploadedImages.add(File(imagePath));
      validateImages();
    }
  }

  Future<void> captureImage() async {
    if (uploadedImages.length >= 3) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload 3 images maximum',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      // Show dialog to choose camera or gallery
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Check file size (2MB limit)
        final bytes = await imageFile.length();
        if (bytes > 2 * 1024 * 1024) {
          Get.snackbar(
            'File Too Large',
            'Image size must be less than 2MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        uploadedImages.add(imageFile);
        validateImages();

        // Get.snackbar(
        //   'Success',
        //   'Image ${uploadedImages.length}/3 added successfully',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        // );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void showImagePreview(File imageFile, int index) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ImagePreviewDialog(
          imageFile: imageFile,
          index: index,
          onDelete: () {
            removeImage(index);
            Get.back();
          },
        ),
      ),
      barrierDismissible: true,
    );
  }

  void removeImage(int index) {
    if (index < uploadedImages.length) {
      uploadedImages.removeAt(index);
      validateImages();
    }
  }

  void toggleRecording() {
    isRecording.value = !isRecording.value;
    // TODO: Implement actual recording logic
    if (!isRecording.value) {
      // Simulate recording completion
      audioRecordingPath.value = 'recorded_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
    }
  }

  Future<void> submitForm() async {
    if (!isFormValid) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      // Get user ID and validate
      var userId = await SharedPrefHelper.getpref("user_id");
      var managerId = await SharedPrefHelper.getpref("manager_id");
      var companyId = await SharedPrefHelper.getpref("company_id");

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found. Please login again.');
      }

      // Validate fields again
      _validateAgentId();
      _validateAgentName();
      validateDate();
      validateImages();

      // Check if there are any validation errors
      if (agentIdError.value.isNotEmpty ||
          agentNameError.value.isNotEmpty ||
          dateError.value.isNotEmpty ||
          imageError.value.isNotEmpty) {
        throw Exception('Please fix validation errors');
      }

      var uri = Uri.parse('http://35.154.144.116:8000/api/delivery');

      var request = https.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });
      String serverDateFormat = "${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}";

      // Add form fields - Use reactive values
      request.fields['manager_id'] = managerId.toString();
      request.fields['company_id'] = companyId.toString();
      request.fields['user_id'] = userId.toString();
      request.fields['agent_id'] = agentIdValue.value;
      request.fields['agent_name'] = agentNameValue.value;
      request.fields['delivery_date'] = serverDateFormat;
      request.fields['status'] = 'delivered';
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['audio_test_status'] = audioTestPassed.value ? 'passed' : 'completed';

      // Add images with validation
      if (uploadedImages.isEmpty) {
        throw Exception('No images selected');
      }

      for (int i = 0; i < uploadedImages.length; i++) {
        var file = uploadedImages[i];

        // Check if file exists
        if (!await file.exists()) {
          throw Exception('Image file ${i + 1} not found');
        }

        // Check file size again
        final bytes = await file.length();
        if (bytes > 2 * 1024 * 1024) {
          throw Exception('Image ${i + 1} is too large (${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB)');
        }

        var multipartFile = await https.MultipartFile.fromPath(
          'images', // Use consistent field name
          file.path,
          filename: 'image_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        request.files.add(multipartFile);
      }

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      // Get response
      var response = await https.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "", // Title
          "", // Message
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFFFFFFFF),
          duration: Duration(seconds: 3),
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
          borderRadius: 12,
          borderColor: Color(0xFF6B7071),
          borderWidth: 1,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              Icons.check_circle,
              color: Color(0xFF00E244),
              size: 30,
            ),
          ),
          shouldIconPulse: false,
          titleText: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  "Congratulations🎉",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFF005409),
                  ),
                ),
              ),
              SizedBox(height: 0), // Adjust spacing as needed
              Text(
                "Sherpa device added. You can now start using it",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          messageText: SizedBox(), // Prevents default spacing
        );
        _resetForm();
        Get.toNamed(Routes.home);

        // Navigate back or to success page


      } else {
        // Handle different error status codes
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Bad request. Please check your input data.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 403:
            errorMessage = 'Access forbidden. You don\'t have permission.';
            break;
          case 404:
            errorMessage = 'Server endpoint not found.';
            break;
          case 413:
            errorMessage = 'Files too large. Please reduce image sizes.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'Failed to submit form (${response.statusCode}). Please try again.';
        }

        // Try to get error message from response body
        try {
          var errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use default error message
        }

        throw Exception(errorMessage);
      }

    } on SocketException {
      Get.snackbar(
        'Network Error',
        'No internet connection. Please check your network and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } on TimeoutException {
      Get.snackbar(
        'Timeout Error',
        'Request timed out. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    agentIdController.clear();
    agentNameController.clear();
    dateController.clear();
    uploadedImages.clear();
    audioRecordingPath.value = '';
    selectedDate.value = null;
    isRecording.value = false;
    audioTestPassed.value = false;

    // Clear reactive values
    agentIdValue.value = '';
    agentNameValue.value = '';

    // Clear errors
    agentIdError.value = '';
    agentNameError.value = '';
    dateError.value = '';
    imageError.value = '';
  }
}