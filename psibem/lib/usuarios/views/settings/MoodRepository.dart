import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MoodRepository {
  static const String _moodsKey = 'user_moods';
  static const String _autoestimaKey = 'user_autoestima';

  Future<void> saveMoods(Map<DateTime, String> moods) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = _encodeMoodMap(moods);
    await prefs.setString(_moodsKey, encodedData);
  }

  Future<Map<DateTime, String>> loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_moodsKey);
    return encodedData != null ? _decodeMoodMap(encodedData) : {};
  }

  Future<void> saveAutoestima(Map<DateTime, String> autoestima) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = _encodeMoodMap(autoestima);
    await prefs.setString(_autoestimaKey, encodedData);
  }

  Future<Map<DateTime, String>> loadAutoestima() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_autoestimaKey);
    return encodedData != null ? _decodeMoodMap(encodedData) : {};
  }

  String _encodeMoodMap(Map<DateTime, String> map) {
    return json.encode(
      map.map((key, value) => MapEntry(key.toIso8601String(), value)),
    );
  }

  Map<DateTime, String> _decodeMoodMap(String encodedData) {
    final Map<String, dynamic> decoded = json.decode(encodedData);
    return decoded.map((key, value) => MapEntry(DateTime.parse(key), value));
  }

  loadEmocoesPersonalizadas() {}
}