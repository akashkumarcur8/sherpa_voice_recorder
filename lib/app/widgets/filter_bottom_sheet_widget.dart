import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

class FilterBottomSheetWidget {
  static void show({
    required BuildContext context,
    required TextEditingController startDateController,
    required TextEditingController endDateController,
    required Function(DateTime start, DateTime end, String sortOption) onApply,
    VoidCallback? onReset,
    String? initialSort,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // local sheet state
        String selectedSort = initialSort ?? 'Newest to Oldest (Newest First)';
        int appliedFilters = 0;
        List<bool> shortcutSelected = [false, false, false];

        void updateFilterCount() {
          int count = 0;
          if (startDateController.text.isNotEmpty &&
              endDateController.text.isNotEmpty) {
            count++;
          }
          if (selectedSort != 'Newest to Oldest (Newest First)') {
            count++;
          }
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
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag‐handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Filter by:',
                        style: TextStyle(color: Colors.grey)),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Created On',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimaryLight),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            startDateController.clear();
                            endDateController.clear();
                            selectedSort = 'Newest to Oldest (Newest First)';
                            shortcutSelected.setAll(0, [false, false, false]);
                            updateFilterCount();
                            if (onReset != null) {
                              onReset();
                            }
                          });
                        },
                        child: const Text('Reset',
                            style: TextStyle(
                                color: Color(0xFF565ADD), fontSize: 15)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // From and To labels
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'From',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLabel,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'To',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLabel,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // date pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          controller: startDateController,
                          hint: 'DD-MM-YYYY',
                          onTap: () => pickDate(startDateController),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField(
                          controller: endDateController,
                          hint: 'DD-MM-YYYY',
                          onTap: () => pickDate(endDateController),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // date shortcuts
                  Row(
                    children: [
                      _dateShortcut('Today', shortcutSelected[0], () {
                        final today = DateTime.now();
                        final fmt = DateFormat('dd-MM-yyyy').format(today);
                        setModalState(() {
                          startDateController.text = fmt;
                          endDateController.text = fmt;
                          shortcutSelected.setAll(0, [true, false, false]);
                          updateFilterCount();
                        });
                      }),
                      _dateShortcut('This Week', shortcutSelected[1], () {
                        final now = DateTime.now();
                        final monday =
                            now.subtract(Duration(days: now.weekday - 1));
                        final sunday = monday.add(const Duration(days: 6));
                        final fmt = DateFormat('dd-MM-yyyy');
                        setModalState(() {
                          startDateController.text = fmt.format(monday);
                          endDateController.text = fmt.format(sunday);
                          shortcutSelected.setAll(0, [false, true, false]);
                          updateFilterCount();
                        });
                      }),
                      _dateShortcut('This Month', shortcutSelected[2], () {
                        final now = DateTime.now();
                        final first = DateTime(now.year, now.month, 1);
                        final last = DateTime(now.year, now.month + 1, 0);
                        final fmt = DateFormat('dd-MM-yyyy');
                        setModalState(() {
                          startDateController.text = fmt.format(first);
                          endDateController.text = fmt.format(last);
                          shortcutSelected.setAll(0, [false, false, true]);
                          updateFilterCount();
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Sort dropdown
                  const Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text('Sort by', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.inputBorder, width: .9),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          selectedColor: Colors.transparent,
                          selectedTileColor: Colors.transparent,
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: selectedSort,
                        alignment: Alignment.centerLeft,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.iconBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textLabel,
                            size: 20,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: AppColors.cardBackground,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Newest to Oldest (Newest First)',
                            child: Builder(
                              builder: (context) {
                                final isSelected = selectedSort ==
                                    'Newest to Oldest (Newest First)';
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: AppColors.iconBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )
                                      : null,
                                  child: const Text(
                                    'Newest to Oldest (Newest First)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Oldest to Newest',
                            child: Builder(
                              builder: (context) {
                                final isSelected =
                                    selectedSort == 'Oldest to Newest';
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          color: AppColors.iconBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )
                                      : null,
                                  child: const Text(
                                    'Oldest to Newest',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Newest to Oldest (Newest First)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Oldest to Newest',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ];
                        },
                        onChanged: (v) => setModalState(() {
                          selectedSort = v!;
                          updateFilterCount();
                        }),
                      ),
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
                              startDateController.clear();
                              endDateController.clear();
                              selectedSort = 'Newest to Oldest (Newest First)';
                              shortcutSelected.setAll(0, [false, false, false]);
                              updateFilterCount();
                              if (onReset != null) {
                                onReset();
                              }
                            });
                          },
                          child: const Text(
                            'Reset All',
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
                            if (startDateController.text.isNotEmpty &&
                                endDateController.text.isNotEmpty) {
                              final start = DateFormat('dd-MM-yyyy')
                                  .parseLoose(startDateController.text);
                              final end = DateFormat('dd-MM-yyyy')
                                  .parseLoose(endDateController.text);
                              onApply(start, end, selectedSort);
                              Navigator.pop(context);
                            }
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

  /// Calendar icon button
  static Widget _calendarIconButton({required VoidCallback onTap}) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset(
          'asset/icons/calender.svg',
          width: 18,
          height: 18,
        ),
      ),
      onPressed: onTap,
    );
  }

  /// Helper so both the field and the icon open the date picker
  static Widget _buildDateField({
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
        suffixIcon: _calendarIconButton(onTap: onTap),
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(width: 0.9, color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(width: 0.9, color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(width: 0.9, color: AppColors.inputBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(width: 0.9, color: AppColors.inputBorder),
        ),
      ),
    );
  }

  static Widget _dateShortcut(
      String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.deepPurple[50] : Colors.white,
            side: BorderSide(
                color: isSelected
                    ? const Color(0xFF565ADD)
                    : AppColors.inputBorder,
                width: 0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: onTap,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isSelected ? const Color(0xFF565ADD) : Colors.black),
          ),
        ),
      ),
    );
  }
}
