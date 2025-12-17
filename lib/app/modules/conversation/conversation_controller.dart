
import 'package:get/get.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../data/providers/ApiService.dart';
import 'conversation_model.dart';
class SessionController extends GetxController {
  final ApiService _api;
  SessionController(this._api);

  var markedSessions   = <ConversationSession>[].obs;
  var unmarkedSessions = <ConversationSession>[].obs;
  var isLoading        = false.obs;
  var error            = ''.obs;

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

      } else {
        unmarkedSessions.assignAll(result);

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
      if (marked) markedSessions.assignAll(result);
      else       unmarkedSessions.assignAll(result);


    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
