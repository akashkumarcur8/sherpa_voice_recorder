import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../faq_guide/faq_guide.dart';
import '../../geo_tracking/map_widget.dart';
import '../controllers/delivery_tracker_controller.dart';
import 'widgets/stats_card_widget.dart';
import 'widgets/filter_dropdown_widget.dart';
import 'widgets/agent_list_item_widget.dart';
import 'widgets/send_reminder_dialog_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';

class DeliveryTrackerScreen extends GetView<DeliveryTrackerController> {
  const DeliveryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitPopup(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(),
        body: Obx(
              () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(context),
                  const SizedBox(height: 24),
                  _buildActivityHeader(),
                  const SizedBox(height: 16),
                  _buildAgentsList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildSendReminderButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.white),
      title: const Text(
        'Delivery Tracker',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF565ADD),
            ),
            child: Obx(() => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF565ADD)),
              accountName: Text(
                controller.empName.value,
                style: const TextStyle(fontSize: 18),
              ),
              accountEmail: Text(controller.email.value),
              currentAccountPictureSize: const Size.square(50),
            )),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/map.svg',
              width: 22,
              height: 22,
            ),
            title: const Text('Geo-Tracking'),
            onTap: () {
              Get.to(() => const GeoTrackingScreen());
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/delivery_tracker.svg',
              width: 22,
              height: 22,
            ),
            title: const Text('Delivery Tracker'),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/complaint.svg',
              width: 22,
              height: 22,
            ),
            title: const Text('Complaint Center'),
            onTap: () {
              Get.toNamed(Routes.complaintcenter);
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'asset/icons/faq_guide.svg',
              width: 22,
              height: 22,
            ),
            title: const Text('FAQ Guide'),
            onTap: () {
              Get.to(() => const FAQScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
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

  Widget _buildStatsSection(BuildContext context) {
    return Obx(() {
      final stats = controller.stats.value;
      return Row(
        children: [
          Expanded(
            child: StatsCardWidget(
              value: stats.pending.toString(),
              label: 'Pending',
              isSelected: controller.selectedCardIndex.value == 0,
              onTap: () => controller.selectCard(0, 'Pending'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCardWidget(
              value: stats.delivered.toString(),
              label: 'Delivered',
              // backgroundColor: AppColors.success.withOpacity(0.1),
              // borderColor: AppColors.success,
              isSelected: controller.selectedCardIndex.value == 1,
              onTap: () => controller.selectCard(1, 'Delivered'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCardWidget(
              value: stats.totalAgents.toString(),
              label: 'Total Agents',
              isSelected: controller.selectedCardIndex.value == 2,
              onTap: () => controller.selectCard(2, 'Select Option'),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActivityHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        FilterDropdownWidget(),
      ],
    );
  }

  Widget _buildAgentsList() {
    return Obx(() {
      final agents = controller.filteredAgents;

      if (agents.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No agents found',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: agents.length,
        itemBuilder: (context, index) {
          return AgentListItemWidget(agent: agents[index]);
        },
      );
    });
  }

  Widget _buildSendReminderButton(BuildContext context) {
    return Obx(() {
      // Show button only when 'Pending' filter is selected and there are pending agents
      final isPendingFilterSelected = controller.selectedFilter.value == 'Pending';
      final hasPendingAgents = controller.filteredAgents.isNotEmpty;

      if (!isPendingFilterSelected || !hasPendingAgents) return const SizedBox.shrink();

      return Container(
        width: ResponsiveHelper.getWidth(context) - 32,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: () => SendReminderDialog.show(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_active, color: AppColors.white),
              SizedBox(width: 8),
              Text(
                'Send Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<bool> _exitPopup(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: const Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you Sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Do you want to exit the application',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
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
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
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
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
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