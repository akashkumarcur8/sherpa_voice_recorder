import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Welcome to Sherpa",
      "subtitle": "Enhance your sales conversations with seamless recording and insights.",
      "button": "Next"
    },
    {
      "title": "Capture Every Sales Interaction",
      "subtitle": "Sherpa helps you record and organize your F2F sales meetings, ensuring you never miss an important detail.",
      "button": "Next"
    },
    {
      "title": "Your Data, Your Privacy",
      "subtitle": "We ensure all your privacy setting are securely stored and comply with industry standards.",
      "button": "Understood"
    },
    {
      "title": "How Sherpa  Helps You",
      "subtitle": [
        "Record F2F sales conversations",
        "Access and review recordings",
        "Improve sales efficiency with insights"
      ],
      "button": "Got It!"
    },
    {
      "title": "You’re All Set!",
      "subtitle": "Start recording and take your sales performance to the next level.",
      "button": "Start Using Sherpa"
    }
  ];

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: (index) => controller.currentPage.value = index,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  title: onboardingData[index]["title"]!,
                  subtitle: onboardingData[index]["subtitle"],
                  buttonText: onboardingData[index]["button"]!,
                  onNext: controller.nextPage,
                );
              },
            ),
          ),
          Obx(() => DotsIndicator(
            dotsCount: onboardingData.length,
            position: controller.currentPage.value.toInt(),
            decorator: DotsDecorator(
              activeColor: const Color(0xFF565ADD),
              color: const Color(0xFFAFB0B0),
              size: const Size(8.0, 8.0),
              activeSize: const Size(20.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final dynamic subtitle; // Dynamic to handle both String and List
  final String buttonText;
  final VoidCallback onNext;

  const OnboardingPage({super.key, 
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           const Spacer(),
          // Image.asset(
          //   'asset/images/logo.png', // Placeholder for an image
          //   height: 220,
          //   width: 800,
          //   fit: BoxFit.contain,
          // ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:Color(0xFF565ADD) ,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          subtitle is String
              ? Text(
            subtitle,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFFAFB0B0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (subtitle as List<String>).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF565ADD),size: 16,),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFAFB0B0)
                          ,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF565ADD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  elevation: 4,
                  shadowColor: Colors.purpleAccent.shade100,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
