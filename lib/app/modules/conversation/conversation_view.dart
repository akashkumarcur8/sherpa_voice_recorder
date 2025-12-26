import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../data/providers/ApiService.dart';
import '../home/controllers/statistics_data_controller.dart';
import '../realtime_conversation/realtime_convesation_page.dart';
import 'controller/conversation_controller.dart';
import '../../widgets/filter_bottom_sheet_widget.dart';
import 'widgets/mark_conversation_dialog.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  List<bool> isSelected = [true, false];

  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final SessionController _ctrl = Get.put(SessionController(ApiService()));
  final statisticsDataController = Get.put(StatisticsDataController());

  var userId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

  _fetchstatisticsData() async {
    final DateTime selectedDate = DateTime.now();
    var userId = await SharedPrefHelper.getpref("user_id");

    statisticsDataController.fetchUserAudioStats(
        userId: int.parse(userId), selectedDate: selectedDate);
  }

  void _loadUserData() async {
    var fetchedUserId = await SharedPrefHelper.getpref("user_id");
    setState(() {
      userId = fetchedUserId;
    });
    //
    // await _ctrl.fetchSessions(date: DateTime.now(), userId:int.parse(fetchedUserId));
    //  await _ctrl.fetchUnMarkedCoversation(date: DateTime.now(), userId:int.parse(fetchedUserId));

    final today = DateTime.now();
    _ctrl.fetchSessions(
        userId: int.parse(fetchedUserId), date: today, marked: true);
    _ctrl.fetchSessions(
        userId: int.parse(fetchedUserId), date: today, marked: false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // your toggle buttons
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(50),
                    constraints: BoxConstraints(
                      minWidth: (width - 40) / 2,
                      minHeight: 48,
                    ),
                    fillColor: const Color(0xFF565ADD),
                    selectedColor: Colors.white,
                    color: Colors.black,
                    borderColor: Colors.transparent,
                    selectedBorderColor: Colors.transparent,
                    isSelected: isSelected,
                    onPressed: (i) async {
                      final result = await Get.to(() => SessionListScreen());
                      if (result == true) {
                        // Make sure Marked Conversation is selected again
                        setState(() {
                          isSelected = [true, false];
                        });
                        _ctrl.fetchSessions(
                          userId: int.parse(userId),
                          date: DateTime.now(),
                          marked: true,
                        );
                      }
                    },

                    // onPressed: (i)  {
                    //     setState(() {
                    //       isSelected = [i==0, i==1];
                    //     });
                    //     _ctrl.fetchSessions(
                    //       userId: int.parse(userId),
                    //       date: DateTime.now(),
                    //       marked: i==0,
                    //     );
                    //   },

                    children: const [
                      Text('Marked Conversation'),
                      Text('Unmarked Conversation'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Search bar
                TextField(
                  onChanged: (value) {
                    _ctrl.updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Conversations',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFEFEFEF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                // header row
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                        onPressed: () {
                          FilterBottomSheetWidget.show(
                            context: context,
                            startDateController: _startCtrl,
                            endDateController: _endCtrl,
                            onApply: (start, end, sortOption) {
                              final markedType = isSelected[0];
                              _ctrl.applyFilter(
                                start: start,
                                end: end,
                                marked: markedType,
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.filter_list_sharp),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // 👇 Expanded + Obx
                Expanded(
                  child: Obx(() {
                    // pick the right list based on toggle
                    if (_ctrl.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sessions = isSelected[0]
                        ? _ctrl.filteredMarkedSessions
                        : _ctrl.filteredUnmarkedSessions;

                    // if empty, show placeholder
                    if (sessions.isEmpty) {
                      return Center(
                        child: Text(
                          isSelected[0]
                              ? 'You have not marked any conversations'
                              : 'The conversation has not been identified yet',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    // otherwise show your list
                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final item = sessions[index];
                        final fmt = DateFormat('hh:mm a');
                        final startStr = item.startTime != null
                            ? fmt.format(item.startTime!)
                            : 'NA';
                        final endStr = item.endTime != null
                            ? fmt.format(item.endTime!)
                            : 'NA';
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRichText("Product Name: ",
                                      item.productNames.join(', ')),
                                  const SizedBox(height: 6),
                                  _buildRichText(
                                    "Client ID: ",
                                    item.clientId.toString(),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildRichText(
                                    "Start & End Time: ",
                                    "$startStr  –  $endStr",
                                  ),
                                ],
                              ),
                              // const Icon(Icons.edit_note,color: Color(0xFF00C32A),),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 25, left: 12),
          child: FloatingActionButton(
            onPressed: () async {
              // Explicitly close any remaining dialogs before showing new one
              if (Get.isDialogOpen ?? false) {
                Get.back();
              }

              await MarkConversationDialog.show(
                context: context,
                showToast: showCustomToast,
                onFetchStatistics: _fetchstatisticsData,
                onSuccess: () {
                  Get.snackbar(
                    "",
                    "",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFFFFF),
                    duration: const Duration(seconds: 3),
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 30),
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
                        SizedBox(height: 0),
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

                  final today = DateTime.now();
                  _ctrl.fetchSessions(
                      userId: int.parse(userId), date: today, marked: true);
                },
                onError: () {
                  Get.snackbar(
                    "",
                    "",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFFFFF),
                    duration: const Duration(seconds: 2),
                    margin:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                    borderRadius: 12,
                    borderColor: const Color(0xFF6B7071),
                    borderWidth: 2,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    icon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.message,
                        color: Color(0xFFFF2222),
                        size: 30,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0),
                          Text(
                            "You missed adding the conversation",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFBD0000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    messageText: const SizedBox(),
                  );
                },
              );
            },

            backgroundColor: const Color(0xFF565ADD),
            shape: const CircleBorder(), // Makes it circular

            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.add,
                color: Colors.white, // Increase size to make it appear bolder
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showCustomToast() {
    final context = Get.context;
    if (context == null || !mounted) return;
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
              color: const Color(0xFFFFD5D5), // Light red background
              border: Border.all(color: const Color(0xFF941717)), // Red border
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
                // Use Flexible to avoid overflow
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

    // Remove the toast after 3 seconds
    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        children: [
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

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }
}
