import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:js' as js;
import 'package:universal_html/html.dart' as html;
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Import main.dart for ThemeOption
import 'login_screen.dart'; // Import LoginScreen

enum SortOption { dueDate, status, title }

enum FilterOption { all, pending, overdue, completed }

enum RepeatUnit { minutes, hours, days }

class Task {
  String id;
  String userId;
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
    required this.userId,
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
        'userId': userId,
        'title': title,
        'dueDate': dueDate,
        'description': description,
        'status': status,
        'completed': completed,
        'isRepeated': isRepeated,
        'repeatInterval': repeatInterval,
        'repeatUnit': repeatUnit.toString().split('.').last,
        'createdAt': Timestamp.now(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        dueDate: json['dueDate'],
        description: json['description'],
        status: json['status'],
        completed: json['completed'],
        isRepeated: json['isRepeated'] ?? false,
        repeatInterval: json['repeatInterval'] ?? 1,
        repeatUnit: json['repeatUnit'] != null
            ? RepeatUnit.values.firstWhere(
                (e) => e.toString().split('.').last == json['repeatUnit'],
                orElse: () => RepeatUnit.days,
              )
            : RepeatUnit.days,
      );
}

class TaskListScreen extends StatefulWidget {
  final ValueChanged<ThemeOption> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  const TaskListScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController repeatIntervalController = TextEditingController();
  bool isRepeated = false;
  RepeatUnit repeatUnit = RepeatUnit.days;
  SortOption sortOption = SortOption.dueDate;
  FilterOption filterOption = FilterOption.all;
  late Timer _timer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
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

  Future<void> _addTaskToFirestore(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
      print('Task added to Firestore: ${task.title}');
    } catch (e) {
      print('Error adding task to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
      rethrow;
    }
  }

  Future<void> _updateTaskInFirestore(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toJson());
      print('Task updated in Firestore: ${task.title}');
    } catch (e) {
      print('Error updating task in Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
      rethrow;
    }
  }

  Future<void> _deleteTaskFromFirestore(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Task deleted from Firestore: $taskId');
    } catch (e) {
      print('Error deleting task from Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting	task: $e')),
      );
      rethrow;
    }
  }

  Future<void> _startTaskChecker() async {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final now = DateTime.now();
      print('Task checker running at ${now.toString()}');
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      for (var doc in querySnapshot.docs) {
        final task = Task.fromJson({
          'id': doc.id,
          ...doc.data(),
        });

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

        print(
            'Task ${task.title} - Status: ${task.status}, Due: ${dueDate.toString()}, Now: ${now.toString()}');

        if (dueDate.isBefore(now)) {
          if (task.status != "Notified") {
            print('Task ${task.title} is overdue. Notifying...');
            task.status = "Notified";
            await _showNotification(task, "Task Overdue");
            await _updateTaskInFirestore(task);
          }

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
            while (dueDate!.isBefore(now)) {
              dueDate = dueDate.add(interval);
              print('Rescheduling ${task.title} to ${dueDate.toString()}');
            }
            task.dueDate = dueDate.toString().substring(0, 16);
            task.status = "Pending";
            await _updateTaskInFirestore(task);
          }
        } else if (dueDate.difference(now).inDays <= 1 &&
            task.status == "Pending") {
          print('Task ${task.title} is due soon (within 1 day). Notifying...');
          task.status = "Notified";
          await _showNotification(task, "Reminder");
          await _updateTaskInFirestore(task);
        } else {
          print(
              'Task ${task.title} is not due yet or already notified. Due: ${dueDate.toString()}');
        }
      }
    });
  }

  Future<void> _showNotification(Task task, String type) async {
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
                    'icon': 'assets/images/placeholder.png',
                  }),
                ]);
                print('Notification shown: $type - ${task.title}');
              } else {
                print('Notification permission denied, falling back to SnackBar');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$type: $message"),
                    duration: const Duration(seconds: 10),
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
              duration: const Duration(seconds: 10),
              action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
            ),
          );
        }
      } catch (e) {
        print('Error showing notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$type: $message"),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          ),
        );
      }
    } else {
      print('Not on web, using SnackBar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$type: $message"),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
    }
  }

  void _downloadTasks(List<Task> tasks) {
    if (kIsWeb) {
      final encoder = JsonEncoder.withIndent('  ');
      final tasksJson =
          encoder.convert(tasks.map((task) => task.toJson()).toList());
      final bytes = utf8.encode(tasksJson);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'tasks.json')
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tasks downloaded as tasks.json")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download is only available on web")),
      );
    }
  }

  List<Task> _filterAndSortTasks(List<Task> tasks) {
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

    return filteredTasks;
  }

  Future<void> _addTask() async {
    try {
      DateTime.parse(dueDateController.text);
      final newTask = Task(
        id: const Uuid().v4(),
        userId: _currentUserId,
        title: titleController.text,
        dueDate: dueDateController.text,
        description: descriptionController.text,
        status: "Pending",
        completed: false,
        isRepeated: isRepeated,
        repeatInterval: int.tryParse(repeatIntervalController.text) ?? 1,
        repeatUnit: repeatUnit,
      );
      await _addTaskToFirestore(newTask);
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
        const SnackBar(content: Text("Invalid date format! Use YYYY-MM-DD HH:MM")),
      );
    }
  }

  Future<void> _editTask(Task task) async {
    titleController.text = task.title;
    dueDateController.text = task.dueDate;
    descriptionController.text = task.description;
    repeatIntervalController.text = task.repeatInterval.toString();
    setState(() {
      isRepeated = task.isRepeated;
      repeatUnit = task.repeatUnit;
    });
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
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
                    decoration: const InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: "Due Date (YYYY-MM-DD HH:MM)",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Repeat Task"),
                    value: isRepeated,
                    onChanged: (value) {
                      setState(() {
                        isRepeated = value;
                      });
                    },
                  ),
                  if (isRepeated) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: repeatIntervalController,
                      decoration: const InputDecoration(
                        labelText: "Repeat Every (number)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
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
            onPressed: () async {
              try {
                DateTime.parse(dueDateController.text);
                task.title = titleController.text;
                task.dueDate = dueDateController.text;
                task.description = descriptionController.text;
                task.isRepeated = isRepeated;
                task.repeatInterval =
                    int.tryParse(repeatIntervalController.text) ?? 1;
                task.repeatUnit = repeatUnit;
                await _updateTaskInFirestore(task);
                if (mounted) {
                  Navigator.pop(context);
                  titleController.clear();
                  dueDateController.clear();
                  descriptionController.clear();
                  repeatIntervalController.clear();
                  setState(() {
                    isRepeated = false;
                    repeatUnit = RepeatUnit.days;
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid date format! Use YYYY-MM-DD HH:MM"),
                    ),
                  );
                }
              }
            },
            child: const Text("Update"),
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
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    await _deleteTaskFromFirestore(task.id);
  }

  Future<void> _toggleComplete(Task task) async {
    task.completed = !task.completed;
    task.status = task.completed ? "Completed" : "Pending";
    await _updateTaskInFirestore(task);
  }

  Future<void> _testFirestoreWrite() async {
    try {
      await _firestore.collection('test').doc('test_doc').set({
        'message': 'This is a test document',
        'timestamp': Timestamp.now(),
      });
      print('Successfully wrote test document to Firestore');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test document written to Firestore')),
      );
    } catch (e) {
      print('Error writing test document to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error writing test document: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Reminder"),
        actions: [
          DropdownButton<ThemeOption>(
            value: null,
            hint: const Text("Theme"),
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
          DropdownButton<Locale>(
            value: null,
            hint: const Text("Language"),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                widget.onLocaleChanged(newLocale);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text("English")),
              DropdownMenuItem(value: Locale('lo'), child: Text("Lao")),
              DropdownMenuItem(value: Locale('th'), child: Text("Thai")),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
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
                        userId: _currentUserId,
                        title: "Manual Test",
                        dueDate: DateTime.now().toString(),
                        description: "This is a manual test notification",
                        status: "Pending",
                        completed: false,
                      ),
                      "Test Notification",
                    );
                  },
                  child: const Text("Test Notification"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final querySnapshot = await _firestore
                        .collection('tasks')
                        .where('userId', isEqualTo: _currentUserId)
                        .get();
                    final tasks = querySnapshot.docs
                        .map((doc) => Task.fromJson({
                              'id': doc.id,
                              ...doc.data(),
                            }))
                        .toList();
                    _downloadTasks(tasks);
                  },
                  child: const Text("Download Tasks"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _testFirestoreWrite,
                  child: const Text("Test Firestore"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Add a New Task",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: "Due Date (YYYY-MM-DD HH:MM)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
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
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: const Text("Repeat Task"),
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
                decoration: const InputDecoration(
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
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text("Add Task"),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Sort by: "),
                    DropdownButton<SortOption>(
                      value: sortOption,
                      onChanged: (SortOption? newValue) {
                        setState(() {
                          sortOption = newValue!;
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
                    const Text("Filter: "),
                    DropdownButton<FilterOption>(
                      value: filterOption,
                      onChanged: (FilterOption? newValue) {
                        setState(() {
                          filterOption = newValue!;
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
            const SizedBox(height: 8),
            const Text(
              "Your Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('userId', isEqualTo: _currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('Error fetching tasks from Firestore: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No tasks available."));
                  }

                  final tasks = snapshot.data!.docs.map((doc) {
                    return Task.fromJson({
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    });
                  }).toList();

                  final displayedTasks = _filterAndSortTasks(tasks);

                  return ListView.builder(
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
                        margin: const EdgeInsets.symmetric(vertical: 4),
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
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTask(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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