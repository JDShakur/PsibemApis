import 'package:flutter/material.dart';

class MoodModel with ChangeNotifier {
  final Map<DateTime, String> _moods = {};

  Map<DateTime, String> get moods => _moods;

  void addMood(DateTime date, String mood) {
    _moods[date] = mood;
    notifyListeners();
  }

  String? getMood(DateTime date) {
    return _moods[date];
  }
}