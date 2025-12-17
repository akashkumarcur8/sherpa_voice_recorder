import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static Future<bool> getIsLoginValue() {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      return prefs.getBool('isLoggedIn') ?? false;
    });
  }

  static Future<bool> setIsloginValue(bool value) {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      return prefs.setBool('isLoggedIn', value);
    });
  }


  static Future<void> setpref(String key, String value) async {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString(key, value);
    });
  }

  static Future<String> getpref(String key, [String? s]) {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      return prefs.getString(key) ?? "";
    });
  }

  static Future<void> removeValue(String key) {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) {
      return prefs.remove(key);
    });
  }

}