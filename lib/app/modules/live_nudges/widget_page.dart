import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/core/utils/liveNudges_color.dart';
import 'live_nudegs_controller.dart';

/// ——————— The collapsible header ———————
class _OngoingCallHeader extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final bool isRecording;

  const _OngoingCallHeader({
    required this.isOpen,
    required this.onToggle,
    required this.isRecording
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text(
            'Ongoing Call',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),

          // Live pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isRecording? const Color(0xFFE2FFE9):const Color(0xFFFFEFEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isRecording? const Color(0xFF0EC16E) :const Color(0xFFFF4444),width: .2),
              boxShadow: [
                BoxShadow(
                  color: isRecording? Colors.green.withOpacity(0.2):Colors.red.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRecording ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isRecording? const Color(0xFF00E244).withOpacity(0.2):Colors.red.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  if(isRecording) ...[
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

               ] else ...[
                    const Text(
                      'Offline',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],


                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Toggle arrow
          InkWell(
            onTap: onToggle,
            child: Icon(
              isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ——————— The main widget ———————
class LiveNudgeSection extends StatefulWidget {
  final bool isRecording;
   const LiveNudgeSection({super.key,required this.isRecording} );

  @override
  _LiveNudgeSectionState createState() => _LiveNudgeSectionState();
}

class _LiveNudgeSectionState extends State<LiveNudgeSection> {
  late final NudgeController ctl;
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    // Use Get.find() to get the existing instance created by HomeController
    ctl = Get.find<NudgeController>();
  }

  @override
  void didUpdateWidget(covariant LiveNudgeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recording just stopped:
    if (oldWidget.isRecording && !widget.isRecording) {
      ctl.nudges.clear();       // ← clear the list
      ctl.resetController();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),


        _OngoingCallHeader(
          isOpen: isOpen,
          onToggle: () => setState(() => isOpen = !isOpen),
          isRecording: widget.isRecording,

        ),

        const SizedBox(height: 12),

        if(widget.isRecording) ...[
          // ② Carousel + dots only when open
          if (isOpen)
            Obx(() {

              if (ctl.nudges.isEmpty) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: Text('Waiting for nudges…')),
                );
              }

              return SizedBox(
                height: 120,
                child: PageView.builder(
                  controller: ctl.pageCtrl,
                  itemCount: ctl.nudges.length,
                  itemBuilder: (ctx, i) {
                    final n = ctl.nudges[i];
                    final border = n.positive ? Colors.green : Colors.red;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Stack(
                        children: [
                          // ① Faded icon
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: -40,
                            child: Opacity(
                              opacity: 0.1,
                              child: SvgPicture.asset(
                                'asset/icons/lightbulb.svg',
                                // If you want to tint your SVG the same way you did with `color: border`,
                                // use colorFilter:
                                colorFilter: ColorFilter.mode(border, BlendMode.srcIn),
                                width: 200,
                                height: 200,
                                // semanticsLabel is optional but good for accessibility:
                                semanticsLabel: 'Lightbulb icon',
                              ),
                            ),
                          ),

                          // ② Card with text + spinner + dots
                          Container(
                            decoration: BoxDecoration(
                              color: border.withOpacity(0.05),
                              border: Border.all(color: border, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // top row: message + spinner
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.text,
                                        maxLines: 3,
                                        // overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: border.darken(0.2),
                                        ),
                                      ),
                                    ),

                                    // const SizedBox(width: 8),
                                    // SizedBox(
                                    //   width: 24,
                                    //   height: 24,
                                    //   child: CircularProgressIndicator(
                                    //     strokeWidth: 3,
                                    //     valueColor:
                                    //     AlwaysStoppedAnimation(border),
                                    //   ),
                                    // ),



                                  ],
                                ),

                                const Spacer(),

                                // bottom row: dots indicator
                                Obx(() {
                                  final count = ctl.nudges.length;
                                  final cur = ctl.currentPage.value;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                    List.generate(count, (dotIndex) {
                                      final isActive = dotIndex == cur;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        width: isActive ? 20 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.black87
                                              : Colors.grey,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                      );
                                    }),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),

        ] else ...[
          if(isOpen)
       const SizedBox(
      height: 60,
      child: Center(child: Text('No ongoing call')),
    ),

        ]

      ],
    );
  }
}




