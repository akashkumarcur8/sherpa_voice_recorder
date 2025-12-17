import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/raise_ticket_controller.dart';
import 'widgets/agent_id_input.dart';
import 'widgets/query_dropdown.dart';
import 'widgets/description_input.dart';
import 'widgets/submit_button.dart';

class RaiseTicketScreen extends GetView<RaiseTicketController> {
  const RaiseTicketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        AppStrings.raiseTicket,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBody(BuildContext context) {

    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveHelper.getMaxWidth(context),
      ),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsiveScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveHelper.verticalSpace(8),
                  const AgentIdInput(),
                  ResponsiveHelper.verticalSpace(20),
                  const QueryDropdown(),
                  ResponsiveHelper.verticalSpace(20),
                  const DescriptionInput(),
                  ResponsiveHelper.verticalSpace(20),
                ],
              ),
            ),
          ),

          // Fixed bottom Submit button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const SubmitButton(),
          ),
        ],
      ),
    );


  }
}