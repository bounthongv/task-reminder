import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:js' as js;
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(TaskReminderApp());
}

enum ThemeOption { bright, dark, system }

enum SortOption { dueDate, status, title }

enum FilterOption { all, pending, overdue, completed }

enum RepeatUnit { minutes, hours, days }

class TaskReminderApp extends StatefulWidget {
  const TaskReminderApp({super.key});

  @override
  _TaskReminderAppState createState() => _TaskReminderAppState();
}

class _TaskReminderAppState extends State<TaskReminderApp> {
  ThemeOption _themeOption = ThemeOption.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'system';
    setState(() {
      _themeOption = ThemeOption.values.firstWhere(
        (e) => e.toString().split('.').last == savedTheme,
        orElse: () => ThemeOption.system,
      );
    });
  }

  Future<void> _saveTheme(ThemeOption theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.toString().split('.').last);
  }

  ThemeData _getTheme(BuildContext context) {
    if (_themeOption == ThemeOption.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? _darkTheme : _brightTheme;
    }
    return _themeOption == ThemeOption.dark ? _darkTheme : _brightTheme;
  }

  final ThemeData _brightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
      bodyLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
      titleLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.black),
    ),
    cardColor: Colors.grey[100],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
      bodyLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
      titleLarge: TextStyle(fontFamily: 'NotoSansLao', color: Colors.white),
    ),
    cardColor: Colors.grey[800],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.blueGrey,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder',
      theme: _getTheme(context),
      home: TaskListScreen(
        onThemeChanged: (theme) {
          setState(() {
            _themeOption = theme;
          });
          _saveTheme(theme);
        },
      ),
    );
  }
}

class Task {
  String id;
  String title;
  String dueDate;
  String description;
  String status;
  bool completed;
  bool isRepeated;
  int repeatInterval;
  RepeatUnit repeatUnit;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.description,
    required this.status,
    required this.completed,
    this.isRepeated = false,
    this.repeatInterval = 1,
    this.repeatUnit = RepeatUnit.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'due_date': dueDate,
        'description': description,
        'status': status,
        'completed': completed,
        'is_repeated': isRepeated,
        'repeat_interval': repeatInterval,
        'repeat_unit': repeatUnit.toString().split('.').last,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        dueDate: json['due_date'],
        description: json['description'],
        status: json['status'],
        completed: json['completed'],
        isRepeated: json['is_repeated'] ?? false,
        repeatInterval: json['repeat_interval'] ?? 1,
        repeatUnit: json['repeat_unit'] != null
            ? RepeatUnit.values.firstWhere(
                (e) => e.toString().split('.').last == json['repeat_unit'],
                orElse: () => RepeatUnit.days,
              )
            : RepeatUnit.days,
      );
}

class TaskListScreen extends StatefulWidget {
  final ValueChanged<ThemeOption> onThemeChanged;

  const TaskListScreen({super.key, required this.onThemeChanged});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  List<Task> displayedTasks = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController repeatIntervalController =
      TextEditingController();
  bool isRepeated = false;
  RepeatUnit repeatUnit = RepeatUnit.days;
  SortOption sortOption = SortOption.dueDate;
  FilterOption filterOption = FilterOption.all;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _startTaskChecker();
  }

  @override
  void dispose() {
    _timer.cancel();
    titleController.dispose();
    dueDateController.dispose();
    descriptionController.dispose();
    repeatIntervalController.dispose();
    super.dispose();
  }

  Future<String> _getTasksFilePath() async {
    if (kIsWeb) {
      return 'tasks.json';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/tasks.json';
  }

  Future<void> _loadTasks() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final String? savedTasks = prefs.getString('tasks');
        if (savedTasks == null) {
          final String initialData =
              await rootBundle.loadString('assets/tasks.json');
          print('Loaded from assets: $initialData');
          final List<dynamic> jsonData = jsonDecode(initialData);
          setState(() {
            tasks = jsonData.map((json) => Task.fromJson(json)).toList();
            _updateDisplayedTasks();
            print('Tasks loaded: ${tasks.length} tasks');
          });
          await prefs.setString('tasks', jsonEncode(tasks));
        } else {
          print('Loaded from SharedPreferences: $savedTasks');
          final List<dynamic> jsonData = jsonDecode(savedTasks);
          setState(() {
            tasks = jsonData.map((json) => Task.fromJson(json)).toList();
            _updateDisplayedTasks();
            print('Tasks loaded: ${tasks.length} tasks');
          });
        }
      } else {
        final filePath = await _getTasksFilePath();
        print('File path: $filePath');
        final file = File(filePath);
        if (!await file.exists()) {
          print('File does not exist, loading from assets...');
          final String initialData =
              await rootBundle.loadString('assets/tasks.json');
          print('Loaded from assets: $initialData');
          await file.writeAsString(initialData);
          print('File written to documents directory');
        }
        final contents = await file.readAsString();
        print('File contents: $contents');
        final List<dynamic> jsonData = jsonDecode(contents);
        print('Parsed JSON: $jsonData');
        setState(() {
          tasks = jsonData.map((json) => Task.fromJson(json)).toList();
          _updateDisplayedTasks();
          print('Tasks loaded: ${tasks.length} tasks');
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        tasks = [
          Task(
            id: "1",
            title: "Test Task 1",
            dueDate: "2025-03-20 12:00",
            description: "This is a test task",
            status: "Pending",
            completed: false,
          ),
          Task(
            id: "2",
            title: "Test Task 2",
            dueDate: "2025-03-22 14:00",
            description: "Another test task",
            status: "Pending",
            completed: false,
          ),
        ];
        _updateDisplayedTasks();
        print('Fallback: Loaded hardcoded tasks');
      });
    }
  }

  Future<void> _saveTasks() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('tasks', jsonEncode(tasks));
        print('Tasks saved to SharedPreferences: ${jsonEncode(tasks)}');
      } else {
        final filePath = await _getTasksFilePath();
        final file = File(filePath);
        await file.writeAsString(jsonEncode(tasks));
        print('Tasks saved to file: ${jsonEncode(tasks)}');
      }
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  void _startTaskChecker() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      final now = DateTime.now();
      print('Task checker running at ${now.toString()}');
      for (var task in tasks) {
        if (task.completed) {
          print('Skipping completed task: ${task.title}');
          continue;
        }

        DateTime? dueDate;
        try {
          String dateInput = task.dueDate;
          if (!dateInput.contains(' ')) {
            dateInput += ' 00:00';
          }
          dueDate = DateTime.parse(dateInput);
          print('Parsed due date for ${task.title}: ${dueDate.toString()}');
        } catch (e) {
          print('Invalid date for task ${task.title}: ${task.dueDate}');
          continue;
        }

        // Since dueDate is set in the try block, it will be non-null here
        print(
            'Task ${task.title} - Status: ${task.status}, Due: ${dueDate.toString()}, Now: ${now.toString()}');

        // Handle overdue tasks
        if (dueDate.isBefore(now)) {
          if (task.status != "Notified") {
            print('Task ${task.title} is overdue. Notifying...');
            setState(() {
              task.status = "Notified";
            });
            _showNotification(task, "Task Overdue");
          }

          // Reschedule repeating tasks
          if (task.isRepeated) {
            Duration interval;
            switch (task.repeatUnit) {
              case RepeatUnit.minutes:
                interval = Duration(minutes: task.repeatInterval);
                break;
              case RepeatUnit.hours:
                interval = Duration(hours: task.repeatInterval);
                break;
              case RepeatUnit.days:
                interval = Duration(days: task.repeatInterval);
                break;
            }
            // Keep rescheduling until the due date is in the future
            while (dueDate!.isBefore(now)) {
              dueDate = dueDate.add(interval);
              print('Rescheduling ${task.title} to ${dueDate.toString()}');
            }
            setState(() {
              task.dueDate = dueDate.toString().substring(0, 16);
              task.status = "Pending";
            });
            print('Rescheduled repeated task ${task.title} to ${task.dueDate}');
          }
          _saveTasks();
          _updateDisplayedTasks();
        } else if (dueDate.difference(now).inDays <= 1 &&
            task.status == "Pending") {
          print('Task ${task.title} is due soon (within 1 day). Notifying...');
          setState(() {
            task.status = "Notified";
          });
          _showNotification(task, "Reminder");
          _saveTasks();
          _updateDisplayedTasks();
        } else {
          print(
              'Task ${task.title} is not due yet or already notified. Due: ${dueDate.toString()}');
        }
      }
    });
  }

  void _showNotification(Task task, String type) {
    final message = type == "Task Overdue"
        ? "Task '${task.title}' is overdue! Description: ${task.description} Due: ${task.dueDate}"
        : "Task '${task.title}' is due soon! Description: ${task.description} Due: ${task.dueDate}";

    if (kIsWeb) {
      try {
        if (js.context['Notification'] != null) {
          print('Notification API is available');
          js.context['Notification'].callMethod('requestPermission', [
            js.allowInterop((permission) {
              print('Notification permission result: $permission');
              if (permission == 'granted') {
                var notification = js.JsObject(js.context['Notification'], [
                  type,
                  js.JsObject.jsify({
                    'body': message,
                    'icon': 'https://via.placeholder.com/150',
                  }),
                ]);
                print('Notification shown: $type - ${task.title}');
              } else {
                print(
                    'Notification permission denied, falling back to SnackBar');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$type: $message"),
                    duration: Duration(seconds: 10),
                    action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
                  ),
                );
              }
            }),
          ]);
        } else {
          print('Notification API not available, falling back to SnackBar');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$type: $message"),
              duration: Duration(seconds: 10),
              action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
            ),
          );
        }
      } catch (e) {
        print('Error showing notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$type: $message"),
            duration: Duration(seconds: 10),
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          ),
        );
      }
    } else {
      print('Not on web, using SnackBar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$type: $message"),
          duration: Duration(seconds: 10),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
    }
  }

  void _downloadTasks() {
    if (kIsWeb) {
      // Use JsonEncoder with indent for pretty printing
      final encoder = JsonEncoder.withIndent('  '); // 2 spaces for indentation
      final tasksJson =
          encoder.convert(tasks.map((task) => task.toJson()).toList());
      // Encode the JSON string as bytes
      final bytes = utf8.encode(tasksJson);
      // Create a Blob with the JSON data
      final blob = html.Blob([bytes], 'application/json');
      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      // Create a temporary anchor element to trigger the download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'tasks.json')
        ..click();
      // Clean up the URL
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tasks downloaded as tasks.json")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download is only available on web")),
      );
    }
  }

  void _updateDisplayedTasks() {
    List<Task> filteredTasks = tasks;
    final now = DateTime.now();
    switch (filterOption) {
      case FilterOption.pending:
        filteredTasks =
            tasks.where((task) => task.status == "Pending").toList();
        break;
      case FilterOption.overdue:
        filteredTasks = tasks.where((task) {
          try {
            final dueDate = DateTime.parse(task.dueDate);
            return task.status == "Notified" && dueDate.isBefore(now);
          } catch (e) {
            return false;
          }
        }).toList();
        break;
      case FilterOption.completed:
        filteredTasks = tasks.where((task) => task.completed).toList();
        break;
      case FilterOption.all:
      default:
        filteredTasks = tasks;
        break;
    }

    switch (sortOption) {
      case SortOption.dueDate:
        filteredTasks.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.dueDate);
            final dateB = DateTime.parse(b.dueDate);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });
        break;
      case SortOption.status:
        filteredTasks.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SortOption.title:
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    setState(() {
      displayedTasks = filteredTasks;
    });
  }

  void _addTask() {
    try {
      DateTime.parse(dueDateController.text);
      final newTask = Task(
        id: Uuid().v4(),
        title: titleController.text,
        dueDate: dueDateController.text,
        description: descriptionController.text,
        status: "Pending",
        completed: false,
        isRepeated: isRepeated,
        repeatInterval: int.tryParse(repeatIntervalController.text) ?? 1,
        repeatUnit: repeatUnit,
      );
      setState(() {
        tasks.add(newTask);
        _updateDisplayedTasks();
      });
      _saveTasks();
      titleController.clear();
      dueDateController.clear();
      descriptionController.clear();
      repeatIntervalController.clear();
      setState(() {
        isRepeated = false;
        repeatUnit = RepeatUnit.days;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid date format! Use YYYY-MM-DD HH:MM")),
      );
    }
  }

  void _editTask(Task task) {
    titleController.text = task.title;
    dueDateController.text = task.dueDate;
    descriptionController.text = task.description;
    repeatIntervalController.text = task.repeatInterval.toString();
    setState(() {
      isRepeated = task.isRepeated;
      repeatUnit = task.repeatUnit;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: "Due Date (YYYY-MM-DD HH:MM)",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final DateTime finalDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              dueDateController.text =
                                  finalDateTime.toString().substring(0, 16);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text("Repeat Task"),
                    value: isRepeated,
                    onChanged: (value) {
                      setState(() {
                        isRepeated = value;
                      });
                    },
                  ),
                  if (isRepeated) ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: repeatIntervalController,
                      decoration: InputDecoration(
                        labelText: "Repeat Every (number)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    DropdownButton<RepeatUnit>(
                      value: repeatUnit,
                      isExpanded: true,
                      onChanged: (RepeatUnit? newValue) {
                        setState(() {
                          repeatUnit = newValue!;
                        });
                      },
                      items: RepeatUnit.values.map((RepeatUnit unit) {
                        return DropdownMenuItem<RepeatUnit>(
                          value: unit,
                          child: Text(unit.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                DateTime.parse(dueDateController.text);
                setState(() {
                  task.title = titleController.text;
                  task.dueDate = dueDateController.text;
                  task.description = descriptionController.text;
                  task.isRepeated = isRepeated;
                  task.repeatInterval =
                      int.tryParse(repeatIntervalController.text) ?? 1;
                  task.repeatUnit = repeatUnit;
                  _updateDisplayedTasks();
                });
                _saveTasks();
                Navigator.pop(context);
                titleController.clear();
                dueDateController.clear();
                descriptionController.clear();
                repeatIntervalController.clear();
                setState(() {
                  isRepeated = false;
                  repeatUnit = RepeatUnit.days;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Invalid date format! Use YYYY-MM-DD HH:MM"),
                  ),
                );
              }
            },
            child: Text("Update"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              dueDateController.clear();
              descriptionController.clear();
              repeatIntervalController.clear();
              setState(() {
                isRepeated = false;
                repeatUnit = RepeatUnit.days;
              });
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
      _updateDisplayedTasks();
    });
    _saveTasks();
  }

  void _toggleComplete(Task task) {
    setState(() {
      task.completed = !task.completed;
      task.status = task.completed ? "Completed" : "Pending";
      _updateDisplayedTasks();
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Reminder"),
        actions: [
          DropdownButton<ThemeOption>(
            value: null,
            hint: Text("Theme"),
            onChanged: (ThemeOption? newValue) {
              if (newValue != null) {
                widget.onThemeChanged(newValue);
              }
            },
            items: ThemeOption.values.map((ThemeOption option) {
              return DropdownMenuItem<ThemeOption>(
                value: option,
                child: Text(option.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showNotification(
                      Task(
                        id: "test",
                        title: "Manual Test",
                        dueDate: DateTime.now().toString(),
                        description: "This is a manual test notification",
                        status: "Pending",
                        completed: false,
                      ),
                      "Test Notification",
                    );
                  },
                  child: Text("Test Notification"),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _downloadTasks,
                  child: Text("Download Tasks"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Add a New Task",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: "Due Date (YYYY-MM-DD HH:MM)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        final DateTime finalDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        dueDateController.text =
                            finalDateTime.toString().substring(0, 16);
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: Text("Repeat Task"),
              value: isRepeated,
              onChanged: (value) {
                setState(() {
                  isRepeated = value;
                });
              },
            ),
            if (isRepeated) ...[
              TextField(
                controller: repeatIntervalController,
                decoration: InputDecoration(
                  labelText: "Repeat Every (number)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<RepeatUnit>(
                value: repeatUnit,
                onChanged: (RepeatUnit? newValue) {
                  setState(() {
                    repeatUnit = newValue!;
                  });
                },
                items: RepeatUnit.values.map((RepeatUnit unit) {
                  return DropdownMenuItem<RepeatUnit>(
                    value: unit,
                    child: Text(unit.toString().split('.').last),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _addTask,
                child: Text("Add Task"),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Sort by: "),
                    DropdownButton<SortOption>(
                      value: sortOption,
                      onChanged: (SortOption? newValue) {
                        setState(() {
                          sortOption = newValue!;
                          _updateDisplayedTasks();
                        });
                      },
                      items: SortOption.values.map((SortOption option) {
                        return DropdownMenuItem<SortOption>(
                          value: option,
                          child: Text(option.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Filter: "),
                    DropdownButton<FilterOption>(
                      value: filterOption,
                      onChanged: (FilterOption? newValue) {
                        setState(() {
                          filterOption = newValue!;
                          _updateDisplayedTasks();
                        });
                      },
                      items: FilterOption.values.map((FilterOption option) {
                        return DropdownMenuItem<FilterOption>(
                          value: option,
                          child: Text(option.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Your Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: displayedTasks.isEmpty
                  ? Center(child: Text("No tasks available."))
                  : ListView.builder(
                      itemCount: displayedTasks.length,
                      itemBuilder: (context, index) {
                        final task = displayedTasks[index];
                        Color statusColor;
                        if (task.completed) {
                          statusColor = Colors.green;
                        } else if (task.status == "Notified" &&
                            DateTime.parse(task.dueDate)
                                .isBefore(DateTime.now())) {
                          statusColor = Colors.red;
                        } else {
                          statusColor = Colors.grey;
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              "${task.title} (${task.status})",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Due: ${task.dueDate}"),
                                Text("Description: ${task.description}"),
                                if (task.isRepeated)
                                  Text(
                                    "Repeats every ${task.repeatInterval} ${task.repeatUnit.toString().split('.').last}",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editTask(task),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTask(task),
                                ),
                                Checkbox(
                                  value: task.completed,
                                  onChanged: (value) => _toggleComplete(task),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
