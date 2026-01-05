import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../models/ticket_query_model.dart';
import '../models/ticket_model.dart';
import '../services/raise_ticket_service.dart';
import 'user_tickets_controller.dart';
import '../views/widgets/success_dialog.dart';

class RaiseTicketController extends GetxController {
  // Text editing controllers
  final agentIdController = TextEditingController();
  final descriptionController = TextEditingController();
  final RaiseTicketService _raiseTicketService = RaiseTicketService();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  // Observable variables
  final RxList<TicketQuery> queries = <TicketQuery>[].obs;
  final Rx<TicketQuery?> selectedQuery = Rx<TicketQuery?>(null);
  final RxBool isLoading = false.obs;
  final RxBool showOthersDescription = false.obs;
  final RxString agentIdError = ''.obs;
  final RxString queryError = ''.obs;
  final RxString descriptionError = ''.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadQueries();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to agent ID changes
    agentIdController.addListener(() {
      if (agentIdError.value.isNotEmpty) {
        agentIdError.value = '';
      }
    });

    // Listen to description changes
    descriptionController.addListener(() {
      if (descriptionError.value.isNotEmpty) {
        descriptionError.value = '';
      }
    });
  }

  void _loadQueries() {
    // Load dummy data
    queries.value = TicketQueryData.getDummyQueries();
  }

  void onQuerySelected(TicketQuery? query) {
    selectedQuery.value = query;
    queryError.value = '';

    // Show/hide description field based on query
    showOthersDescription.value = query?.title.toLowerCase() == 'others';

    // If not "Others", set a default description
    if (query != null && query.title.toLowerCase() != 'others') {
      descriptionController.text = 'Issue related to: ${query.title}';
    } else {
      descriptionController.clear();
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate Agent ID
    if (agentIdController.text.trim().isEmpty) {
      agentIdError.value = 'Please enter Agent ID';
      isValid = false;
    } else if (agentIdController.text.trim().length < 3) {
      agentIdError.value = 'Agent ID must be at least 3 characters';
      isValid = false;
    }

    // Validate Query Selection
    if (selectedQuery.value == null) {
      queryError.value = 'Please select a query';
      isValid = false;
    }

    // Validate Description (if Others is selected)
    if (showOthersDescription.value &&
        descriptionController.text.trim().isEmpty) {
      descriptionError.value = 'Please enter description';
      isValid = false;
    } else if (showOthersDescription.value &&
        descriptionController.text.trim().length < 10) {
      descriptionError.value = 'Description must be at least 10 characters';
      isValid = false;
    }

    return isValid;
  }

  Future<void> submitTicket() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      var managerId = await SharedPrefHelper.getpref("manager_id");
      var companyId = await SharedPrefHelper.getpref("company_id");
      var userName = await SharedPrefHelper.getpref("username");

      // Create ticket model
      final ticket = TicketModel(
        agentId: agentIdController.text.trim(),
        queryId: selectedQuery.value!.id,
        queryTitle: selectedQuery.value!.title,
        description: descriptionController.text.trim(),
        managerId: managerId,
        companyId: companyId,
        userId: userName,
        createdAt: DateTime.now(),
      );

      // Call API to create ticket
      final response = await _raiseTicketService.createTicket(ticket);

      // Show success dialog
      if (response != null && response['status'] == true) {
        // Close bottom sheet - use Get.back() which doesn't require context
        // This is safer after async operations as it doesn't depend on BuildContext
        Get.back();

        // Reset form
        _resetForm();

        // Small delay to ensure bottom sheet is closed before showing dialog
        await Future.delayed(const Duration(milliseconds: 300));

        // Show success dialog
        SuccessDialog.show(
          title: 'Successful',
          message: 'Your ticket has been raised successfully.',
        );

        // Refresh tickets list after dialog closes (2 seconds)
        Future.delayed(const Duration(seconds: 2), () {
          // Refresh tickets list if UserTicketsController is registered
          if (Get.isRegistered<UserTicketsController>()) {
            Get.find<UserTicketsController>().refreshTickets();
          }
        });
      } else {
        throw Exception('Failed to raise ticket');
      }
    } catch (e, stackTrace) {
      _logger.e('❌ RaiseTicketController: Error submitting ticket: $e',
          error: e, stackTrace: stackTrace);
      // Don't show technical errors to users - just log them
    } finally {
      isLoading.value = false;
    }
  }


  void _resetForm() {
    agentIdController.clear();
    descriptionController.clear();
    selectedQuery.value = null;
    showOthersDescription.value = false;
    agentIdError.value = '';
    queryError.value = '';
    descriptionError.value = '';
  }

  @override
  void onClose() {
    agentIdController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
