import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static Future<void> saveString(
      {required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String> getString({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }
}
