import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/connection_config.dart';

class PrefsService {
  static const _keyConfig  = 'connection_config';

  Future<void> saveConfig(ConnectionConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyConfig, jsonEncode(config.toJson()));
  }

  Future<ConnectionConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyConfig);
    if (raw == null) return ConnectionConfig.defaults;
    try {
      return ConnectionConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return ConnectionConfig.defaults;
    }
  }
}
