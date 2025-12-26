import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:mice_activeg/app/modules/realtime_conversation/realtime_conversation_controller.dart';
import 'package:mice_activeg/app/modules/realtime_conversation/realtime_conversation_model.dart';
import '../../widgets/filter_bottom_sheet_widget.dart';

class SessionListScreen extends GetView<RealtimeConvesationController> {
  SessionListScreen({super.key});

  // controllers for date inputs
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(RealtimeConvesationController());

    // for responsive sizing
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isOffline.value) {
        return const Scaffold(
          body: Center(
              child: Text("You are offline", style: TextStyle(fontSize: 18))),
        );
      }
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF565ADD),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Conversation Centre',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.02),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Conversations',
                        style: TextStyle(
                          color: Color(0xFF565ADD),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          FilterBottomSheetWidget.show(
                            context: context,
                            startDateController: _startCtrl,
                            endDateController: _endCtrl,
                            onApply: (start, end, sortOption) {
                              controller.applyFilter(
                                start: start,
                                end: end,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: controller.sessions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                            child: Text(
                              "No calls happened . Please apply a filter to view previous calls",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: w * 0.04,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.sessions.length,
                          itemBuilder: (ctx, i) {
                            final session = controller.sessions[i];
                            final r = session.report;
                            final totalNudges = r.categories
                                .expand((c) => c.subcategories)
                                .where((s) =>
                                    s.nudges.trim().isNotEmpty &&
                                    s.nudges != "NA")
                                .length;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: const Color(0xFFE5E5E5), width: 1),
                              ),
                              child: InkWell(
                                onTap: () => Get.to(() =>
                                    SessionDetailScreen(session: session)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ─── Top info section ──────────────────────────────
                                    Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildRichText(
                                                    "Product Name: ",
                                                    r.productName),
                                              ),
                                              IconButton(
                                                icon: SvgPicture.asset(
                                                  'asset/icons/edit_note.svg',
                                                  width: 15,
                                                  height: 15,
                                                  semanticsLabel: 'Edit note',
                                                ),
                                                onPressed: () {
                                                  final nameController =
                                                      TextEditingController(
                                                          text: r.productName);
                                                  controller.isUpdating.value =
                                                      false;
                                                  showDialog<void>(
                                                    context: ctx,
                                                    barrierDismissible: false,
                                                    builder: (dialogCtx) {
                                                      final start = TimeOfDay
                                                              .fromDateTime(r
                                                                  .startTime
                                                                  .add(const Duration(
                                                                      hours: 5,
                                                                      minutes:
                                                                          30)))
                                                          .format(ctx);
                                                      final end = TimeOfDay
                                                              .fromDateTime(r
                                                                  .endTime
                                                                  .add(const Duration(
                                                                      hours: 5,
                                                                      minutes:
                                                                          30)))
                                                          .format(ctx);
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Edit Product Name'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextField(
                                                              controller:
                                                                  nameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      labelText:
                                                                          'Product Name'),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            TextFormField(
                                                              readOnly: true,
                                                              initialValue:
                                                                  start,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Start Time',
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            TextFormField(
                                                              readOnly: true,
                                                              initialValue: end,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'End Time',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          Obx(() => TextButton(
                                                                onPressed: controller
                                                                        .isUpdating
                                                                        .value
                                                                    ? null
                                                                    : () => Navigator.of(
                                                                            dialogCtx)
                                                                        .pop(),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              )),
                                                          Obx(() =>
                                                              ElevatedButton(
                                                                onPressed: controller
                                                                        .isUpdating
                                                                        .value
                                                                    ? null
                                                                    : () async {
                                                                        final newList = nameController
                                                                            .text
                                                                            .split(
                                                                                ',')
                                                                            .map((s) =>
                                                                                s.trim())
                                                                            .where((s) => s.isNotEmpty)
                                                                            .toList();
                                                                        if (newList
                                                                            .isEmpty) {
                                                                          ScaffoldMessenger.of(ctx)
                                                                              .showSnackBar(
                                                                            const SnackBar(content: Text('Please enter at least one product')),
                                                                          );
                                                                          return;
                                                                        }
                                                                        try {
                                                                          await controller
                                                                              .updateProductsIdentified(
                                                                            callId:
                                                                                r.callId,
                                                                            productNames:
                                                                                newList,
                                                                          );
                                                                          Navigator.of(dialogCtx)
                                                                              .pop();
                                                                        } catch (e) {
                                                                          ScaffoldMessenger.of(ctx)
                                                                              .showSnackBar(
                                                                            SnackBar(content: Text('Update failed: $e')),
                                                                          );
                                                                        }
                                                                      },
                                                                child: controller
                                                                        .isUpdating
                                                                        .value
                                                                    ? const SizedBox(
                                                                        width:
                                                                            16,
                                                                        height:
                                                                            16,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                      )
                                                                    : const Text(
                                                                        'Save'),
                                                              )),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          _buildRichText(
                                            "Start & End Time: ",
                                            "${TimeOfDay.fromDateTime(r.startTime.add(const Duration(hours: 5, minutes: 30))).format(ctx)} – "
                                                "${TimeOfDay.fromDateTime(r.endTime.add(const Duration(hours: 5, minutes: 30))).format(ctx)}",
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ─── Bottom “Total Nudges” bar ────────────────────
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: w * 0.04,
                                          vertical: w * 0.025),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F0FF),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'asset/icons/small_bulb.svg',
                                            semanticsLabel: 'Lightbulb outline',
                                          ),
                                          SizedBox(width: w * 0.03),
                                          Text(
                                            "Total Nudges – $totalNudges",
                                            style: TextStyle(
                                                fontSize: w * 0.03,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class SessionDetailScreen extends StatelessWidget {
  final Session session;
  const SessionDetailScreen({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final items = <Map<String, String>>[];
    for (final cat in session.report.categories) {
      for (final sub in cat.subcategories) {
        if (sub.nudges.trim().isNotEmpty) {
          items.add({
            'category': cat.name,
            'subcategory': sub.name,
            'nudges': sub.nudges.trim(),
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ADD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Nudges',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                "No nudges found for this conversation.",
                style: TextStyle(
                  fontSize: w * 0.05,
                  color: Colors.grey[600],
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(w * 0.04),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: w * 0.04),
              itemBuilder: (ctx, i) {
                final it = items[i];

                final hasNudge =
                    it['nudges']!.isNotEmpty && it['nudges'] != "NA";
                final borderColor = hasNudge ? Colors.green : Colors.red;

                // indent from left edge of container to align under text:
                final textIndent =
                    w * 0.09; // equals icon (0.06w) + spacing (0.03w)

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffF8FFF9),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Category title
                        Row(
                          children: [
                            SvgPicture.asset(
                              'asset/icons/small_bulb.svg',
                              width: w * 0.06,
                              height: w * 0.06,
                              color: const Color(0xFF1db33b),
                              semanticsLabel: 'Lightbulb outline',
                            ),
                            SizedBox(width: w * 0.03),
                            Expanded(
                              child: Text(
                                it['category']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: w * 0.035,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: w * 0.02),

                        // Subcategory, aligned under the category text
                        Padding(
                          padding: EdgeInsets.only(left: textIndent),
                          child: Text(
                            it['subcategory']!,
                            style: TextStyle(
                              fontSize: w * 0.03,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                        SizedBox(height: w * 0.03),

                        // Bullet + nudge (or fallback), also aligned under the text
                        Padding(
                          padding: EdgeInsets.only(left: textIndent),
                          child: hasNudge
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "• ",
                                      style: TextStyle(
                                        // fontSize: w * 0.045,
                                        height: 1.2,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        it['nudges']!,
                                        style: TextStyle(
                                          fontSize: w * 0.03,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "No nudge available",
                                  style: TextStyle(
                                    fontSize: w * 0.042,
                                    // fontStyle: FontStyle.italic,
                                    color: Colors.grey[500],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
