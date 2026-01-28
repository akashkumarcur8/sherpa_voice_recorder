import 'package:shared_preferences/shared_preferences.dart';

/// In-memory cache for SharedPreferences
/// Eliminates repeated disk I/O by caching preferences in memory
class SharedPrefCache {
  static final SharedPrefCache _instance = SharedPrefCache._internal();
  factory SharedPrefCache() => _instance;
  SharedPrefCache._internal();
  
  final Map<String, String> _cache = {};
  bool _initialized = false;
  
  /// Initialize the cache by loading all common preferences
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'username',
      'email',
      'emp_name',
      'store_name',
      'emp_type',
      'company_id',
      'manager_id',
      'team_id',
      'user_id',
      'designation',
    ];
    
    for (final key in keys) {
      _cache[key] = prefs.getString(key) ?? '';
    }
    
    _initialized = true;
  }
  
  /// Get preference value from cache (synchronous)
  String get(String key) => _cache[key] ?? '';
  
  /// Set preference value and update cache
  Future<void> set(String key, String value) async {
    _cache[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  
  /// Clear the cache
  void clear() {
    _cache.clear();
    _initialized = false;
  }
  
  /// Check if cache is initialized
  bool get isInitialized => _initialized;
}
