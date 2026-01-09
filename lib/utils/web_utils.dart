import 'dart:convert';
import 'dart:html' as html;
import '../models/task.dart';

void downloadTasks(List<Task> tasks) {
  final tasksJson = tasks.map((task) => task.toMap()).toList();
  final jsonString = jsonEncode(tasksJson);
  final bytes = utf8.encode(jsonString);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'tasks.json')
    ..click();
  html.Url.revokeObjectUrl(url);
}
