// import 'package:flutter/material.dart';
// import 'analytics_model.dart';
//
// class FilterBottomSheet extends StatefulWidget {
//   final String currentDateRange;
//   final Function(String) onDateRangeChanged;
//   // final List<FilterSuggestion> suggestions;
//
//   const FilterBottomSheet({
//     Key? key,
//     required this.currentDateRange,
//     required this.onDateRangeChanged,
//     required this.suggestions,
//   }) : super(key: key);
//
//   @override
//   _FilterBottomSheetState createState() => _FilterBottomSheetState();
// }
//
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   String selectedRange = '';
//   DateTimeRange? customDateRange;
//
//   final List<String> predefinedRanges = [
//     'Last 7 Days',
//     'Last 14 Days',
//     'Last 30 Days',
//     'Last 3 Months',
//     'Last 6 Months',
//     'This Year',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     selectedRange = widget.currentDateRange;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Container(
//             margin: EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Color(0xFFD7D7D7),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           // Header
//           Padding(
//             padding: EdgeInsets.all(20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Filter Analytics',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, color: Color(0xFF9D9D9D)),
//                 ),
//               ],
//             ),
//           ),
//
//           // Date Range Section
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Date Range',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//
//                 // Predefined ranges
//                 ...predefinedRanges.map((range) => _buildRangeOption(range)),
//
//                 // Custom date range
//                 _buildCustomDateRange(),
//               ],
//             ),
//           ),
//
//           // Suggestions Section
//           if (widget.suggestions.isNotEmpty) ...[
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Smart Suggestions',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1A1A1A),
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   ...widget.suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
//                 ],
//               ),
//             ),
//           ],
//
//           // Apply button
//           Padding(
//             padding: EdgeInsets.all(20),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   widget.onDateRangeChanged(selectedRange);
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF565ADD),
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Apply Filter',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(height: MediaQuery.of(context).padding.bottom),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRangeOption(String range) {
//     final isSelected = selectedRange == range;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedRange = range;
//           customDateRange = null;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 8),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? Color(0xFF565ADD).withOpacity(0.1) : Color(0xFFF8F9FC),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Color(0xFF565ADD) : Color(0xFFEBEBEB),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.calendar_today,
//               color: isSelected ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
//               size: 20,
//             ),
//             SizedBox(width: 12),
//             Text(
//               range,
//               style: TextStyle(
//                 color: isSelected ? Color(0xFF565ADD) : Color(0xFF1A1A1A),
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//             Spacer(),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle,
//                 color: Color(0xFF565ADD),
//                 size: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomDateRange() {
//     final isSelected = customDateRange != null;
//     return GestureDetector(
//       onTap: () async {
//         final DateTimeRange? picked = await showDateRangePicker(
//           context: context,
//           firstDate: DateTime.now().subtract(Duration(days: 365)),
//           lastDate: DateTime.now(),
//           initialDateRange: customDateRange,
//         );
//         if (picked != null) {
//           setState(() {
//             customDateRange = picked;
//             selectedRange = 'Custom Range';
//           });
//         }
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 8),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? Color(0xFF565ADD).withOpacity(0.1) : Color(0xFFF8F9FC),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Color(0xFF565ADD) : Color(0xFFEBEBEB),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.date_range,
//               color: isSelected ? Color(0xFF565ADD) : Color(0xFF9D9D9D),
//               size: 20,
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Custom Date Range',
//                     style: TextStyle(
//                       color: isSelected ? Color(0xFF565ADD) : Color(0xFF1A1A1A),
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                   if (customDateRange != null)
//                     Text(
//                       '${_formatDate(customDateRange!.start)} - ${_formatDate(customDateRange!.end)}',
//                       style: TextStyle(
//                         color: Color(0xFF9D9D9D),
//                         fontSize: 12,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle,
//                 color: Color(0xFF565ADD),
//                 size: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuggestionCard(FilterSuggestion suggestion) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: suggestion.color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: suggestion.color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: suggestion.color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               suggestion.icon,
//               color: suggestion.color,
//               size: 20,
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   suggestion.title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1A1A1A),
//                   ),
//                 ),
//                 Text(
//                   suggestion.description,
//                   style: TextStyle(
//                     color: Color(0xFF9D9D9D),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
