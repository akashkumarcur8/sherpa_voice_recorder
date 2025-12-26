import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../faq_data.dart';

class FAQController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  List<Map<String, String>> get filteredFAQs {
    if (searchQuery.value.isEmpty) {
      return faqData;
    }
    final query = searchQuery.value.toLowerCase();
    return faqData
        .where((faq) =>
            faq["question"]!.toLowerCase().contains(query) ||
            faq["answer"]!.toLowerCase().contains(query))
        .toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
