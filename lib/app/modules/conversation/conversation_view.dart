
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../data/providers/ApiService.dart';
import '../home/controllers/mark_conversation_controller.dart';
import '../home/controllers/statistics_data_controller.dart';
import '../realtime_conversation/realtime_convesation_page.dart';
import 'conversation_controller.dart';


class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  List<bool> isSelected = [true, false];

  final _startCtrl = TextEditingController();
  final _endCtrl   = TextEditingController();
  final SessionController _ctrl = Get.put(SessionController(ApiService()));
  final statisticsDataController = Get.put(StatisticsDataController());


  var userId="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }


  _fetchstatisticsData() async {
    final DateTime selectedDate = DateTime.now();
    var user_Id = await SharedPrefHelper.getpref("user_id");

    statisticsDataController.fetchUserAudioStats(
        userId: int.parse(user_Id), selectedDate: selectedDate);
  }


  void _loadUserData() async{
     var user_Id = await SharedPrefHelper.getpref("user_id");
     setState(() {
       userId=user_Id;
     });
    //
    // await _ctrl.fetchSessions(date: DateTime.now(), userId:int.parse(user_Id));
    //  await _ctrl.fetchUnMarkedCoversation(date: DateTime.now(), userId:int.parse(user_Id));

    final today = DateTime.now();
    _ctrl.fetchSessions(userId:int.parse(user_Id), date: today,  marked: true);
    _ctrl.fetchSessions(userId:int.parse(user_Id), date: today,  marked: false);

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
                const SizedBox(height: 30),
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
                        onPressed: () => _filterBottomSheet(context),
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
                    // final sessions = isSelected[0] ? _ctrl.markedSessions : _ctrl.unmarkedSessions;
                     final sessions =  _ctrl.markedSessions;


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
                        final endStr   = item.endTime   != null
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
                                      _buildRichText(
                                        "Product Name: ",item.productNames.join(', ')
                                      ),
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
          padding: const EdgeInsets.only(bottom: 25,left: 12),
          child: FloatingActionButton(
      
            onPressed: ()
            async {
            final controller = Get.put(ConversationController());
            controller.reset();
      
            var result = await  Get.dialog(
              // barrierDismissible: false,
              Builder(
                builder: (dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                                          children: const [
                                            TextSpan(
                                              text: ' *',
                                              style: TextStyle(color: Colors.red, fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                      suffixIcon: controller.productInputController.text.trim().isNotEmpty
                                          ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: Color(0xFFD6D9FF),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Color(0xFF565ADD),
                                            weight: 18,
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
                                      label: Text(product, style: TextStyle(color: Colors.white)),
                                      backgroundColor: const Color(0xFF565ADD),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        side: const BorderSide(color: Colors.transparent),
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                      onDeleted: () => controller.removeProduct(product),
                                      labelPadding: const EdgeInsets.only(left: 8, right: 2),
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                                          children: const [
                                            TextSpan(
                                              text: ' *',
                                              style: TextStyle(color: Colors.red, fontSize: 18),
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
                              if (!controller.formKey.currentState!.validate()) {
                             showCustomToast(context);
                                return;
                              }
                              var message = await controller.submitForm();
      
      
                              // Now check if message is not null, and show a snackbar
                              if (message != null && message == "Conversation session saved successfully") {
                                await _fetchstatisticsData();

                                Get.snackbar(
                                  "", // Title
                                  "", // Message
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Color(0xFFFFFFFF),
                                  duration: Duration(seconds: 3),
                                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
                                  borderRadius: 12,
                                  borderColor: Color(0xFF6B7071),
                                  borderWidth: 1,
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  icon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF00E244),
                                      size: 30,
                                    ),
                                  ),
                                  shouldIconPulse: false,
                                  titleText: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Congratulations🎉",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0XFF005409),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 0), // Adjust spacing as needed
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
                                  messageText: SizedBox(), // Prevents default spacing
                                );


                                final today = DateTime.now();
                                _ctrl.fetchSessions(userId:int.parse(userId), date: today,  marked: true);
      
      
      
      
      
      
                              }
      
      
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: controller.isFormValid.value
                                    ? const Color(0xFF565ADD)
                                    : const 	Color(0xFFE0E0E0) ,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              child:  Text(
                                "Submit",
                                style: TextStyle(color:controller.isFormValid.value
                                    ? Colors.white
                                    : Color(0xFF1A1A1A)  , fontSize: 15),
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
            // Explicitly close any remaining dialogs before showing new one
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }
      
            if (result != true) {
      
              Get.snackbar(
                "", // title
                "", // message
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Color(0xFFFFFFFF),
                duration: Duration(seconds: 2),
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 30),
                borderRadius: 12,
                borderColor: Color(0xFF6B7071),
                borderWidth: 2,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.message,
                    color: Color(0xFFFF2222),
                    size: 30,
                  ),
                ),
                shouldIconPulse: false,
                titleText: Padding(
                  padding: const EdgeInsets.only(left: 2),
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
                      SizedBox(height: 0), // Control spacing here
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
                messageText: SizedBox(), // Prevent default spacing by setting it empty
              );
      
      
      
            }
      
          },
      
            backgroundColor: Color(0xFF565ADD),
            shape: CircleBorder(),// Makes it circular
      
            child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(Icons.add,color: Colors.white, // Increase size to make it appear bolder
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],),
                )),
          ),
        ),
      
      
      
      ),
    );
  }

  void showCustomToast(BuildContext context) {
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFACC39),
                  size: 20,
                ),
                const SizedBox(width: 8),
                // Use Flexible to avoid overflow
                Flexible(
                  child: Text(
                    "Please Fill the Necessary Details",
                    style: const TextStyle(
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
            text: value ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _filterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // local sheet state
        String selectedSort = 'Newest to Oldest (Newest First)';
        int appliedFilters = 0;
        List<bool> shortcutSelected = [false, false, false];

        void updateFilterCount() {
          int count = 0;
          if (_startCtrl.text.isNotEmpty && _endCtrl.text.isNotEmpty) count++;
          if (selectedSort != 'Newest to Oldest (Newest First)') count++;
          appliedFilters = count;
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate(TextEditingController ctrl) async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setModalState(() {
                  ctrl.text = DateFormat('dd-MM-yyyy').format(picked);
                  shortcutSelected.setAll(0, [false, false, false]);
                  updateFilterCount();
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag‐handle
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Filter by:', style: TextStyle(color: Colors.grey)),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Created On',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _startCtrl.clear();
                            _endCtrl.clear();
                            selectedSort = 'Newest to Oldest (Newest First)';
                            shortcutSelected.setAll(0, [false, false, false]);
                            updateFilterCount();
                          });
                        },
                        child: const Text('Reset', style: TextStyle(color: Colors.deepPurple)),
                      ),
                    ],
                  ),

                  // date pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          controller: _startCtrl,
                          hint: 'DD-MM-YYYY',
                          onTap: () => pickDate(_startCtrl),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField(
                          controller: _endCtrl,
                          hint: 'DD-MM-YYYY',
                          onTap: () => pickDate(_endCtrl),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // your original shortcuts UI
                  Row(
                    children: [
                      _dateShortcut('Today', shortcutSelected[0], () {
                        final today = DateTime.now();
                        final fmt = DateFormat('dd-MM-yyyy').format(today);
                        setModalState(() {
                          _startCtrl.text = fmt;
                          _endCtrl.text   = fmt;
                          shortcutSelected.setAll(0, [true, false, false]);
                          updateFilterCount();
                        });
                      }),
                      _dateShortcut('This Week', shortcutSelected[1], () {
                        final now    = DateTime.now();
                        final monday = now.subtract(Duration(days: now.weekday - 1));
                        final sunday = monday.add(const Duration(days: 6));
                        final fmt    = DateFormat('dd-MM-yyyy');
                        setModalState(() {
                          _startCtrl.text = fmt.format(monday);
                          _endCtrl.text   = fmt.format(sunday);
                          shortcutSelected.setAll(0, [false, true, false]);
                          updateFilterCount();
                        });
                      }),
                      _dateShortcut('This Month', shortcutSelected[2], () {
                        final now   = DateTime.now();
                        final first = DateTime(now.year, now.month, 1);
                        final last  = DateTime(now.year, now.month + 1, 0);
                        final fmt   = DateFormat('dd-MM-yyyy');
                        setModalState(() {
                          _startCtrl.text = fmt.format(first);
                          _endCtrl.text   = fmt.format(last);
                          shortcutSelected.setAll(0, [false, false, true]);
                          updateFilterCount();
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Sort dropdown
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Sort by', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFECEDF0), width: .9),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: selectedSort,
                      items: const [
                        DropdownMenuItem(
                          value: 'Newest to Oldest (Newest First)',
                          child: Text('Newest to Oldest (Newest First)'),
                        ),
                        DropdownMenuItem(
                          value: 'Oldest to Newest',
                          child: Text('Oldest to Newest'),
                        ),
                      ],
                      onChanged: (v) => setModalState(() {
                        selectedSort = v!;
                        updateFilterCount();
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E5FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _startCtrl.clear();
                              _endCtrl.clear();
                              selectedSort = 'Newest to Oldest (Newest First)';
                              shortcutSelected.setAll(0, [false, false, false]);
                              updateFilterCount();
                            });
                          },
                          child: const Text('Reset All',
                            style: TextStyle(color: Color(0xFF565ADD)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF565ADD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final markedType = isSelected[0];
                            final start = DateFormat('dd-MM-yyyy').parseLoose(_startCtrl.text);
                            final end   = DateFormat('dd-MM-yyyy').parseLoose(_endCtrl.text);
                            _ctrl.applyFilter(
                              start: start,
                              end: end,
                              marked: markedType,
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            appliedFilters > 0
                                ? 'Apply Filters ($appliedFilters)'
                                : 'Apply Filters',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Helper so both the field and the icon open the date picker
  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Color(0xFF565ADD)),
          onPressed: onTap,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 0.9, color: Color(0xFFECEDF0)),
        ),
      ),
    );
  }

// Your unchanged _dateShortcut:
  Widget _dateShortcut(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.deepPurple[50] : Colors.white,
            side: BorderSide(color: isSelected ? const Color(0xFF565ADD) : Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(color: isSelected ? const Color(0xFF565ADD) : Colors.black),
          ),
        ),
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
