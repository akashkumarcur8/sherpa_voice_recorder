import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
 import 'package:mice_activeg/app/modules/home/controllers/statistics_data_controller.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../data/providers/ApiService.dart';
class ConversationController extends GetxController {
  // Observables
  final isFormValid = false.obs;
  final hasProduct = false.obs;
  final selectedProducts = <String>[].obs;
  final showSubmit = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  var isFormSubmitted = false.obs;

  // Text Controllers
  final productInputController = TextEditingController();
  final customerIdController = TextEditingController();
  final dateRangeController = TextEditingController();
  final statisticsDataController = Get.put(StatisticsDataController());
  final formKey = GlobalKey<FormState>();


  @override
  void onClose() {
    // Dispose the controllers to prevent memory leaks
    productInputController.dispose();
    customerIdController.dispose();
    dateRangeController.dispose();
    super.onClose();
  }

  /// Resets all fields and states
  void reset() {
    if (formKey.currentState != null) {
      formKey.currentState?.reset();
    }
    productInputController.clear();
    customerIdController.clear();
    dateRangeController.clear();
    selectedProducts.clear();
    startDate.value = null;
    endDate.value = null;
    showSubmit.value = false;
    isFormValid.value = false;
    isFormSubmitted.value = false;
    update();

  }

  /// Adds a product from the input field to the selected list
  void addProductFromInput() {
    final product = productInputController.text.trim();
    if (product.isNotEmpty && !selectedProducts.contains(product)) {
      selectedProducts.add(product);
      productInputController.clear();
      validateForm();
      update();
    }
  }

  /// Removes a product from the selected list
  void removeProduct(String product) {
    selectedProducts.remove(product);
    validateForm();
    update();
  }

  /// Picks a date range and sets the start and end date
  Future<void> pickDateRange(BuildContext context) async {
    final pickedDates = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(1600),
      startLastDate: DateTime.now().add(const Duration(days: 3652)),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(1600),
      endLastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (pickedDates != null && pickedDates.length == 2) {
      startDate.value = pickedDates[0];
      endDate.value = pickedDates[1];

      final DateFormat formatter = DateFormat('dd MMM yyyy hh:mm a');
      dateRangeController.text =
      '${formatter.format(startDate.value!)} - ${formatter.format(endDate.value!)}';

      showSubmit.value = true;
      validateForm();
      update();
    }
  }

  /// Validates the form based on selected products and date range
  void validateForm() {
    isFormValid.value = (selectedProducts.isNotEmpty ||
        productInputController.text.trim().isNotEmpty) &&
        dateRangeController.text.isNotEmpty;
  }

  Future<dynamic> submitForm() async {
    isFormSubmitted.value = true;
    var userId = await SharedPrefHelper.getpref("user_id");


    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Fluttertoast.showToast(
        msg: "Please connect to the internet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFFFD5D5),
        textColor: const Color(0xFF941717),
        fontSize: 16.0,
      );
      return;
    }
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, startDate.value!.hour, startDate.value!.minute);
    final end = DateTime(now.year, now.month, now.day, endDate.value!.hour, endDate.value!.minute);

    if (!start.isBefore(end)) {
      Fluttertoast.showToast(
        msg: "Start time must be before end time",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFFFD5D5),
        textColor: const Color(0xFF941717),
        fontSize: 16.0,
      );
      return;
    }


    final requestData = {
      "userId": userId,
      "productName": selectedProducts,
      "clientId": int.tryParse(customerIdController.text.trim()) ?? 0,
      "conversationStartTime": DateFormat("yyyy-MM-dd HH:mm:ss").format(startDate.value!),
      "conversationEndTime": DateFormat("yyyy-MM-dd HH:mm:ss").format(endDate.value!),
    };

    try {
      final response = await ApiService().postConversationSession(requestData);
      if (response?.statusCode == 200) {
        var responseData = response?.data;
        // Fetch the message
        String message = responseData['message'] ?? 'No message';




        var userId = await SharedPrefHelper.getpref("user_id");
        final DateTime selectedDate = DateTime.now();

        statisticsDataController.fetchUserAudioStats(
          userId: int.parse(userId),
          selectedDate: selectedDate,
        );



        Get.back(result: true); // Close the dialog/screen
        await Future.delayed(const Duration(milliseconds: 200)); // Small safe delay
        Get.delete<ConversationController>();

        // Now safely delete the controller
        return message;


      } else {
        // Fluttertoast.showToast(msg: "Failed to save conversation");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Something went wrong: ${e.toString()}");
    }
  }

}
