
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../core/services/storage/shared_pref_data_save_service.dart';
import '../../../routes/app_routes.dart';
import '../../home/home_screen.dart';
import '../model/login_model.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  final isLoading = false.obs;
  final obscurePassword = true.obs;


  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    passwordController = TextEditingController();

  }
  //
  // @override
  // void onClose() {
  //   usernameController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login(BuildContext context) async {
    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (context.mounted) {
        context.showWarningSnackBar(
            'You are offline. Please reconnect to the internet and try again');
      }
      return;
    }

    // Validate inputs
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      if (context.mounted) {
        context.showWarningSnackBar('Please enter your username');
      }
      return;
    }

    if (password.isEmpty) {
      if (context.mounted) {
        context.showWarningSnackBar('Please enter your password');
      }
      return;
    }

    isLoading.value = true;

    try {
    
      // Perform login
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );
      final loginResponse = await _authService.login(loginRequest);
      if (loginResponse.status == '1') {
        var userDetails = loginResponse.details;

        // Save login state
        await SharedPrefHelper.setIsloginValue(true);

        // Configure OneSignal
        OneSignal.login(userDetails.userId);
        OneSignal.User.addEmail(userDetails.email);

        // Fetch manager info
        if(userDetails.designation.toLowerCase()=='manager'){
          final managerUserIdInfo= await _authService.getMangerUserId(userDetails.email);

          userDetails = userDetails.copyWith(
            managerUserId: managerUserIdInfo.managerUserId,
            companyId: managerUserIdInfo.companyId,
          );
        }
        else{
          final managerInfo = await _authService.getManagerInfo(userDetails.email);

          userDetails = userDetails.copyWith(
            managerId: managerInfo.managerId,
            teamId: managerInfo.teamId,
            companyId: managerInfo.companyId,
          );
        }

        // Update user details with manager info


        // Save user data
        await SharedPrefDataSAve.data(
          username: userDetails.username,
          email: userDetails.email,
          empname: userDetails.empName,
          storename: userDetails.storeName,
          emp_type: userDetails.empType,
          user_id: userDetails.userId,
          managerId: userDetails.managerId,
          teamId: userDetails.teamId,
          companyId: userDetails.companyId,
          designation: userDetails.designation,
          managerUserId: userDetails.managerUserId,
        );


        // Clear input fields
        usernameController.clear();
        passwordController.clear();

        // Navigate based on designation
        if (context.mounted) {
          if (userDetails.designation.toLowerCase() == 'manager') {
            Get.toNamed(Routes.deliveryTracker);
          } else {
            Get.to(() => HomeScreen());
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showWarningSnackBar(
            "Incorrect username or password. Please try again.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> showExitDialog(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
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
              ),
            ],
          ),
        ),
      ),
    )) ??
        false;
  }
}