import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String repeatUnit; // e.g., "days", "hours", "minutes"
  final int repeatInterval; // Number of units for repeat interval
  final bool completed;
  final bool isRepeated;
  final String status; // e.g., "Pending", "Completed"
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.repeatUnit,
    required this.repeatInterval,
    required this.completed,
    required this.isRepeated,
    required this.status,
    required this.userId,
  });

  // Convert Task to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate), // Always store as Timestamp
      'repeatUnit': repeatUnit,
      'repeatInterval': repeatInterval,
      'completed': completed,
      'isRepeated': isRepeated,
      'status': status,
      'userId': userId,
    };
  }

  // Create Task from Firestore map
  factory Task.fromMap(String id, Map<String, dynamic> map) {
    DateTime dueDate;
    if (map['dueDate'] is Timestamp) {
      dueDate = (map['dueDate'] as Timestamp).toDate();
    } else if (map['dueDate'] is String) {
      dueDate = DateTime.parse(map['dueDate']);
    } else {
      dueDate = DateTime.now(); // Fallback in case of invalid data
    }

    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: dueDate,
      repeatUnit: map['repeatUnit'] ?? 'none',
      repeatInterval: map['repeatInterval'] ?? 0,
      completed: map['completed'] ?? false,
      isRepeated: map['isRepeated'] ?? false,
      status: map['status'] ?? 'Pending',
      userId: map['userId'] ?? '',
    );
  }
}