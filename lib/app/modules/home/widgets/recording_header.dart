import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/mice_blinking_controller.dart';

class RecordingHeader extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final String empName;
  final VoidCallback onMenuPressed;
  final VoidCallback onConversationPressed;
  final int conversationCount;

  MiceBlinkingController? get miceBlinkingController {
    if (Get.isRegistered<MiceBlinkingController>()) {
      return Get.find<MiceBlinkingController>();
    }
    return null;
  }

  const RecordingHeader({
    super.key,
    required this.isRecording,
    required this.seconds,
    required this.empName,
    required this.onMenuPressed,
    required this.onConversationPressed,
    required this.conversationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF565ADD),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: onMenuPressed,
              ),
              Obx(() {
                final controller = miceBlinkingController;
                if (controller != null && controller.isRecording.value) {
                  return ScaleTransition(
                    scale: controller.animationController,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0XFFF8FFF7), // icon color
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF00E244).withValues(alpha: 0.6),
                            spreadRadius: 4,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Color(0xFF00E244),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Icon(Icons.mic_off,
                      color: Colors.white, size: 28);
                }
              }),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isRecording ? 'Recording ongoing' : 'Recording Stopped',
            style: const TextStyle(color: Colors.white70),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(seconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: onConversationPressed,
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF00A58E)),
                label: const Text(
                  "Mark a Conversation",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: InkWell(
                  onTap: () => Get.toNamed(Routes.conversationView),
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 12, right: 2, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'Conversation Count',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0080FF),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            conversationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}

class StatisticsGrid extends StatelessWidget {
  final String recordingHours;
  final String qualityAudioHours;
  final int disconnects;

  const StatisticsGrid({
    super.key,
    required this.recordingHours,
    required this.qualityAudioHours,
    required this.disconnects,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "name": "Recording Duration",
        "value": recordingHours,
        "color": Colors.pink[100],
      },
      {
        "name": "Quality Audio Duration",
        "value": qualityAudioHours,
        "color": Colors.blue[100],
      },
      {
        "name": "Number of Disconnects",
        "value": disconnects.toString(),
        "color": Colors.teal[100],
      },
    ];

    return GridView.builder(
      itemCount: 3,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: Get.width > 600 ? 1.2 : 1,
      ),
      itemBuilder: (context, index) {
        var item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.03,
              vertical: Get.width * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['value'].toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: Get.width * 0.05,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    item['name'].toString(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
