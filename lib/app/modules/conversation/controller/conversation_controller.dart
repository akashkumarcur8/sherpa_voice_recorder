import 'package:get/get.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../data/providers/ApiService.dart';
import 'package:mice_activeg/app/modules/conversation/model/conversation_model.dart';

class SessionController extends GetxController {
  final ApiService _api;
  SessionController(this._api);

  var markedSessions = <ConversationSession>[].obs;
  var unmarkedSessions = <ConversationSession>[].obs;
  var filteredMarkedSessions = <ConversationSession>[].obs;
  var filteredUnmarkedSessions = <ConversationSession>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var searchQuery = ''.obs;

  Future<void> fetchSessions({
    required int userId,
    required DateTime date,
    required bool marked,
  }) async {
    try {
      isLoading(true);
      final result = await _api.getConversationSessions(
        userId: userId,
        date: date,
        marked: marked,
      );

      if (marked) {
        markedSessions.assignAll(result);
        _applySearch();
      } else {
        unmarkedSessions.assignAll(result);
        _applySearch();
      }
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> applyFilter({
    required DateTime start,
    required DateTime end,
    required bool marked,
  }) async {
    try {
      isLoading(true);
      var userId = await SharedPrefHelper.getpref("user_id");

      error('');
      final result = await _api.filterConversationSessions(
        userId: int.parse(userId),
        start: start,
        end: end,
        marked: marked,
      );
      if (marked) {
        markedSessions.assignAll(result);
        _applySearch();
      } else {
        unmarkedSessions.assignAll(result);
        _applySearch();
      }
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  void _applySearch() {
    final query = searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      filteredMarkedSessions.assignAll(markedSessions);
      filteredUnmarkedSessions.assignAll(unmarkedSessions);
    } else {
      filteredMarkedSessions.assignAll(
        markedSessions.where((session) {
          final clientId = session.clientId.toLowerCase();
          final productNames = session.productNames.join(' ').toLowerCase();
          return clientId.contains(query) || productNames.contains(query);
        }).toList(),
      );

      filteredUnmarkedSessions.assignAll(
        unmarkedSessions.where((session) {
          final clientId = session.clientId.toLowerCase();
          final productNames = session.productNames.join(' ').toLowerCase();
          return clientId.contains(query) || productNames.contains(query);
        }).toList(),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    filteredMarkedSessions.assignAll(markedSessions);
    filteredUnmarkedSessions.assignAll(unmarkedSessions);
  }
}
