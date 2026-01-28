import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../faq_guide/faq_guide.dart';
import '../geo_tracking/LocationController.dart';
import '../live_nudges/widget_page.dart';
import 'controllers/home_controller.dart';
import 'controllers/mark_conversation_controller.dart';
import 'widgets/recording_header.dart';
import '../../routes/app_routes.dart';
import '../setting/setting_screen_view.dart';
import '../../core/services/storage/sharedPrefHelper.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final LocationController locationController = Get.put(LocationController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          drawer: _buildDrawer(context),
          body: Column(
            children: [
              // Recording Header
              Obx(() => RecordingHeader(
                    isRecording: controller.isRecording.value,
                    seconds: controller.recordingSeconds.value,
                    empName: controller.empName.value,
                    onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
                    onConversationPressed: () =>
                        _showConversationDialog(context),
                    conversationCount:
                        controller.statsController.conversationCount.value,
                  )),

              const SizedBox(height: 20),

              //Live Nudge Section (if applicable)
              Obx(() => LiveNudgeSection(isRecording: controller.isRecording.value)),
              const SizedBox(height: 20),

              // Statistics Header
              _buildStatisticsHeader(context),
              const SizedBox(height: 8),

              // Statistics Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Obx(() => StatisticsGrid(
                        recordingHours: controller
                            .statsController.totalRecordingHours.value,
                        qualityAudioHours: controller
                            .statsController.totalRecordingHours.value,
                        disconnects: controller
                            .statsController.numberOfDisconnects.value,
                      )),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Obx(() => CustomBottomNavigation(
                isRecording: controller.isRecording.value,
                onMicPressed: () => _toggleRecording(),
              )),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Obx(() {
            return DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF565ADD)),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF565ADD)),
                accountName: Text(
                  controller.empName.value,
                  style: const TextStyle(fontSize: 18),
                ),
                accountEmail: Text(controller.email.value),
                currentAccountPictureSize: const Size.square(50),
              ),
            );
          }),

          // ListTile(
          //   leading: SvgPicture.asset(
          //     'asset/icons/history.svg',
          //     width: 22,
          //     height: 22,
          //   ),
          //   title: const Text('Conversation Centre'),
          //   onTap: () => Get.to(() => const ConversationView()),
          // ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/faq_guide.svg',
              height: 22,
            ),
            title: const Text('FAQ Guide'),
            onTap: () => Get.to(() => const FAQScreen()),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/ticket.svg',
              height: 19,
            ),
            title: const Text('Raise Ticket'),
            onTap: () => Get.toNamed(Routes.raiseTicket),
          ),

          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/setting.svg',
              height: 22,
            ),
            title: const Text('Settings'),
            onTap: () => Get.to(() => const SettingsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.logout,weight: 22,),
            title: const Text('Sign Out'),
            onTap: () async {
              await SharedPrefHelper.setIsloginValue(false);
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Recording Statistics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            icon: const Icon(Icons.filter_list_sharp, size: 30),
            onPressed: () => _showDatePicker(context),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
    );

    DateTime finalDate = pickedDate ?? DateTime.now();
    var userId = await SharedPrefHelper.getpref("user_id");

    await controller.statsController.fetchUserAudioStats(
      userId: int.parse(userId),
      selectedDate: finalDate,
    );
    }

  void _showConversationDialog(BuildContext context) async {
    final conversationController = Get.put(ConversationController());
    conversationController.reset();

    // Show dialog and wait for result
    final result = await Get.dialog<bool>(
      barrierDismissible: true,
      Builder(
        builder: (dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Mark a Conversation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
                  maxWidth: MediaQuery.of(dialogContext).size.width * 0.9,
                  minWidth: MediaQuery.of(dialogContext).size.width * 0.9,
                ),
                child: GetBuilder<ConversationController>(
                  builder: (controller) {
                    return Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product input
                          TextFormField(
                            controller: controller.productInputController,
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'Enter Product Name',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              suffixIcon: controller.productInputController.text
                                      .trim()
                                      .isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: const Color(0xFFD6D9FF),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: Color(0xFF565ADD),
                                        ),
                                        onPressed: () {
                                          controller.addProductFromInput();
                                        },
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              controller.update();
                            },
                            validator: (value) {
                              if ((controller.selectedProducts.isEmpty &&
                                  (value == null || value.trim().isEmpty))) {
                                return "Product Name is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Chips of selected Products
                          Obx(() => Wrap(
                                spacing: 8,
                                children: controller.selectedProducts
                                    .map((product) => Chip(
                                          label: Text(product,
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          backgroundColor:
                                              const Color(0xFF565ADD),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            side: const BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          deleteIcon: const Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                          ),
                                          onDeleted: () =>
                                              controller.removeProduct(product),
                                          labelPadding: const EdgeInsets.only(
                                              left: 8, right: 2),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 0),
                                        ))
                                    .toList(),
                              )),
                          const SizedBox(height: 16),

                          // Customer ID input (optional)
                          TextFormField(
                            controller: controller.customerIdController,
                            decoration: const InputDecoration(
                              labelText: "Customer ID",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Date range picker
                          TextFormField(
                            controller: controller.dateRangeController,
                            readOnly: true,
                            style: const TextStyle(color: Color(0xFF6B7071)),
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'Start Time & End Time',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16),
                                  children: const [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.date_range_rounded,
                                  color: Color(0xFF565ADD),
                                  size: 30,
                                ),
                                onPressed: () {
                                  controller.pickDateRange(dialogContext);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Start Time & End Time is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Obx(() {
                  return InkWell(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      await Future.delayed(const Duration(milliseconds: 100));

                      if (!conversationController.formKey.currentState!
                          .validate()) {
                        _showValidationToast(context);
                        return;
                      }

                      var message = await conversationController.submitForm();

                      if (message != null &&
                          message ==
                              "Conversation session saved successfully") {
                        // Refresh statistics
                        await controller.statsController.fetchUserAudioStats(
                          userId: int.parse(
                              await SharedPrefHelper.getpref("user_id") ?? "0"),
                          selectedDate: DateTime.now(),
                        );

                        // Close dialog with success flag TRUE
                        //Get.back(result: true);

                        // Show success message
                        Get.snackbar(
                          "",
                          "",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFFFFFFF),
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 30),
                          borderRadius: 12,
                          borderColor: const Color(0xFF6B7071),
                          borderWidth: 1,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          icon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xFF00E244),
                              size: 30,
                            ),
                          ),
                          shouldIconPulse: false,
                          titleText: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 2),
                                child: Text(
                                  "Congratulations🎉",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF005409),
                                  ),
                                ),
                              ),
                              Text(
                                "You have successfully added the conversation",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          messageText: const SizedBox(),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: conversationController.isFormValid.value
                            ? const Color(0xFF565ADD)
                            : const Color(0xFFE0E0E0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 8),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: conversationController.isFormValid.value
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );

    if (result == false || result == null) {
      // Small delay to avoid showing message if submit was successful
      await Future.delayed(const Duration(milliseconds: 100));

      // Double check we're not in success state
      if (result != true) {
        Get.snackbar(
          "",
          "",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
          borderRadius: 12,
          borderColor: const Color(0xFF6B7071),
          borderWidth: 1,
          icon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.message,
              color: Color(0xFFFF2222),
              size: 25,
            ),
          ),
          shouldIconPulse: false,
          titleText: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Oops!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFBD0000),
                  ),
                ),
                Text(
                  "You missed adding the conversation",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          messageText: const SizedBox(),
        );
      }
    }
  }

// Validation toast helper method
  void _showValidationToast(BuildContext context) {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: screenWidth * 0.1,
        right: screenWidth * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD5D5),
              border: Border.all(color: const Color(0xFF941717)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFACC39),
                  size: 20,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Please Fill the Necessary Details",
                    style: TextStyle(
                      color: Color(0xFF941717),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _toggleRecording() {
    if (controller.isRecording.value) {
      controller.stopRecordingManually();
    } else {
      controller.startRecordingManually();
    }
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: const Icon(Icons.exit_to_app,
                          color: Colors.red, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you Sure?',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Do you want to exit the application',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton(
                            onPressed: () => exit(0),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF565ADD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Yes',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        )) ??
        false;
  }
}
