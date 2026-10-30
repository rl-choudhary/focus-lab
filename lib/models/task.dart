import 'package:flutter/material.dart';

class AppTask {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay? time;
  bool isCompleted;

  AppTask({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'timeHour': time?.hour,
      'timeMinute': time?.minute,
    };
  }

  factory AppTask.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedTime;
    if (json['timeHour'] != null && json['timeMinute'] != null) {
      parsedTime = TimeOfDay(hour: json['timeHour'], minute: json['timeMinute']);
    }
    return AppTask(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: parsedTime,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  void toggle() {
    isCompleted = !isCompleted;
  }
}
