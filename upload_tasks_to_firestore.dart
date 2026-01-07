import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDf6sPLXW2sWtkkt4XaHPjFPXpkzft03tY",
      authDomain: "taskreminder-480e9.firebaseapp.com",
      projectId: "taskreminder-480e9",
      storageBucket: "taskreminder-480e9.firebasestorage.app",
      messagingSenderId: "148369250702",
      appId: "1:148369250702:web:1b4e43f62a2540f2beacdf",
    ),
  );

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Read tasks.json
  final file = File('/assets/tasks.json'); // Update the path to your tasks.json file
  if (!await file.exists()) {
    print('tasks.json file not found at the specified path!');
    return;
  }

  final String jsonString = await file.readAsString();
  final List<dynamic> tasksJson = jsonDecode(jsonString);

  // User ID to associate the tasks with (replace with the actual user ID later)
  const String userId = "temp_user_id";

  // Upload each task to Firestore
  for (var taskJson in tasksJson) {
    try {
      // Map the JSON to the Firestore structure
      final taskData = {
        'id': taskJson['id'],
        'userId': userId,
        'title': taskJson['title'],
        'dueDate': taskJson['due_date'], // Rename due_date to dueDate
        'description': taskJson['description'],
        'status': taskJson['status'],
        'completed': taskJson['completed'],
        'isRepeated': taskJson['is_repeated'] ?? false,
        'repeatInterval': taskJson['repeat_interval'] ?? 1,
        'repeatUnit': taskJson['repeat_unit'] ?? 'days',
        'createdAt': Timestamp.now(),
      };

      // Add the task to Firestore
      await firestore.collection('tasks').doc(taskJson['id']).set(taskData);
      print('Uploaded task: ${taskJson['title']}');
    } catch (e) {
      print('Error uploading task ${taskJson['title']}: $e');
    }
  }

  print('Finished uploading tasks to Firestore');
}