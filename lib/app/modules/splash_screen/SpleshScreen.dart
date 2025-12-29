import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../routes/app_routes.dart';
import '../home/onboarding/onboarding_screen.dart';

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});
  @override
  State<SpleshScreen> createState() => SpleshScreenState();
}
class SpleshScreenState extends State<SpleshScreen> {
  static const String KEYLOGIN = "login";

  void initState() {
    super.initState();
    requestPermissions();
    getLoginValidationData();
    setState(() {});
  }


  // Future<void> Screengoto() async {
  //   Timer(const Duration(seconds: 5), () {
  //     Get.to(CheifTrainerRegistration());
  //   },);
  // }


  Future<void> requestPermissions() async {
    // Request both microphone and location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.location
    ].request();

    // Check the status of each permission
    if (statuses[Permission.microphone]?.isGranted ?? false) {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
      if (statuses[Permission.microphone]?.isPermanentlyDenied ?? false) {
        print("Microphone permission is permanently denied. Please enable it in settings.");
        openAppSettings(); // Opens app settings for the user to enable permissions
      }
    }

    if (statuses[Permission.location]?.isGranted ?? false) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
      if (statuses[Permission.location]?.isPermanentlyDenied ?? false) {
        print("Location permission is permanently denied. Please enable it in settings.");
        openAppSettings();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                width: double.infinity,
                child: Image.asset("asset/images/newsplash.png", fit: BoxFit.cover,),
                // fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 130,),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, left:0.0),
                    child: Container(
                      height: 40,
                      width: 40,
                      child: const CircularProgressIndicator(
                        strokeWidth: 5,
                        // child: LinearProgressIndicator(
                        backgroundColor: Colors.blue,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        // minHeight: 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(left: 98.0),
                //   child: Container(
                //       alignment: Alignment.center,
                //       width: 160,
                //       height: 160,
                //       child: Image.asset(
                //         'assets/images/splash.png',
                //         color: kMagenta,
                //         height: 200,
                //         width: 200,
                //       )),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getLoginValidationData() async {
    var designation = await SharedPrefHelper.getpref("designation");
    bool isLoggedIn = await SharedPrefHelper.getIsLoginValue();
    await Future.delayed(const Duration(seconds: 3));
    if (isLoggedIn) {
      if(designation.toLowerCase() == 'manager'){
        Get.toNamed(Routes.deliveryTracker);
      }
      else{
        Get.toNamed(Routes.home);
      }
    } else {
      Get.to(OnboardingScreen());
    }


  }
}
