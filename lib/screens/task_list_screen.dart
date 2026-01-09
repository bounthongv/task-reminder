import 'package:task_reminder_flutter/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io'; // For Platform check
import 'dart:convert';
import 'package:task_reminder_flutter/utils/download_helper.dart'; // Conditional import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add for Google Sign-In logout
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:audioplayers/audioplayers.dart'; // For audio player functionality

// Enums for sorting and filtering
enum SortOption { dueDate, status, title }
enum FilterOption { all, pending, overdue, completed }

class TaskListScreen extends StatefulWidget {
  final ValueChanged<ThemeOption> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeOption currentTheme;

  const TaskListScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.currentTheme,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with WindowListener {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _repeatIntervalController = TextEditingController();
  String _repeatUnit = 'none';
  int _repeatInterval = 0;
  bool _isRepeated = false;
  DateTime? _selectedDueDate;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  

  // Sorting and filtering state
  SortOption _sortOption = SortOption.dueDate;
  FilterOption _filterOption = FilterOption.all;

  // Timer for periodic notifications
  Timer? _notificationTimer;

  // Audio player for notification sound
  final AudioPlayer _audioPlayer = AudioPlayer(); // Add this line
  String _selectedSound = 'default';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.addListener(this);
      _initWindowCloseHandler();
    }
    // Start periodic task checking for notifications
    _startNotificationTimer();
    _loadSelectedSound();
  }

  Future<void> _initWindowCloseHandler() async {
    await windowManager.setPreventClose(true);
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      await windowManager.hide();
    }
  }
  
  Future<void> _loadSelectedSound() async {
    final sound = await NotificationService().getSelectedSound();
    setState(() {
      _selectedSound = sound;
    });
  }

  Future<void> _updateSelectedSound(String sound) async {
    await NotificationService().setSelectedSound(sound);
    setState(() {
      _selectedSound = sound;
    });
    // Optional: Preview sound here
  }

  @override
  void dispose() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.removeListener(this);
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _repeatIntervalController.dispose();
    _notificationTimer?.cancel(); // Cancel the timer when disposing
    _audioPlayer.dispose();
    super.dispose();
  }

  // Start a timer to periodically check for overdue/upcoming tasks
  void _startNotificationTimer() {
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForNotifications();
    });
  }

  // Check for overdue or upcoming tasks and show notifications
  void _checkForNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    // Define a small window (e.g., ±30 seconds) to check if the task is due "right now"
    final startWindow = now.subtract(const Duration(seconds: 30));
    final endWindow = now.add(const Duration(seconds: 30));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('completed', isEqualTo: false)
          .get();

      final tasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.id, doc.data()))
          .toList();

      for (var task in tasks) {
        // Check if the task's due date falls within the current time window
        if (task.dueDate.isAfter(startWindow) && task.dueDate.isBefore(endWindow)) {
          // Play the notification sound
          String soundToPlay = _selectedSound == 'default' ? 'notification' : _selectedSound;
          await _audioPlayer.play(AssetSource('sounds/$soundToPlay.mp3')); 
          // Show a SnackBar to inform the user
          _scaffoldKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('Task Due: ${task.title}'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToCheckTasks),
        ),
      );
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
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
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dueDateController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_selectedDueDate!);
        });
      }
    }
  }

  Future<void> _addTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDueDate == null) return;

    try {
      final task = Task(
        id: '', // Will be set by Firestore
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDueDate!,
        repeatUnit: _isRepeated ? _repeatUnit : 'none',
        repeatInterval: _isRepeated ? _repeatInterval : 0,
        completed: false,
        isRepeated: _isRepeated,
        status: 'Pending',
        userId: user.uid,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .add(task.toMap());

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      _repeatIntervalController.clear();
      setState(() {
        _repeatUnit = 'none';
        _repeatInterval = 0;
        _isRepeated = false;
        _selectedDueDate = null;
      });

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskAddedSuccessfully),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToAddTask),
        ),
      );
    }
  }

  Future<void> _updateTask(Task task) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDueDate ?? task.dueDate,
        repeatUnit: _isRepeated ? _repeatUnit : 'none',
        repeatInterval: _isRepeated ? _repeatInterval : 0,
        completed: task.completed,
        isRepeated: _isRepeated,
        status: task.status,
        userId: task.userId,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update(updatedTask.toMap());

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskUpdatedSuccessfully),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToUpdateTask),
        ),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .delete();

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskDeletedSuccessfully),
        ),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToDeleteTask),
        ),
      );
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update({
        'completed': !task.completed,
        'status': task.completed ? 'Pending' : 'Completed',
      });
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToUpdateTask),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      // Sign out from Google if the user signed in with Google
      await GoogleSignIn().signOut();
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.logout)),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error)),
      );
    }
  }

  void _showAddTaskDialog({Task? task}) {
    print('Opening Add/Edit Task Dialog');
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _dueDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate);
      _repeatUnit = task.repeatUnit;
      _repeatInterval = task.repeatInterval;
      _repeatIntervalController.text = task.repeatInterval.toString();
      _isRepeated = task.isRepeated;
      _selectedDueDate = task.dueDate;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      _repeatIntervalController.clear();
      _repeatUnit = 'none';
      _repeatInterval = 0;
      _isRepeated = false;
      _selectedDueDate = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(task == null
                  ? AppLocalizations.of(context)!.addNewTask
                  : AppLocalizations.of(context)!.editTask),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.taskTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.description,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dueDateController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.dueDateFormat,
                        border: const OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDueDate(context),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(AppLocalizations.of(context)!.repeatTask),
                      value: _isRepeated,
                      onChanged: (value) {
                        setDialogState(() {
                          _isRepeated = value!;
                          if (_isRepeated && _repeatUnit == 'none') {
                            _repeatUnit = 'days';
                          } else if (!_isRepeated) {
                            _repeatUnit = 'none';
                          }
                        });
                      },
                    ),
                    if (_isRepeated) ...[
                      DropdownButton<String>(
                        value: _repeatUnit,
                        onChanged: (value) {
                          setDialogState(() {
                            _repeatUnit = value!;
                          });
                        },
                        items: ['none', 'minutes', 'hours', 'days']
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _repeatIntervalController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.repeatEvery,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _repeatInterval = int.tryParse(value) ?? 0;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (task == null) {
                      _addTask();
                    } else {
                      _updateTask(task);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(task == null
                      ? AppLocalizations.of(context)!.addTask
                      : AppLocalizations.of(context)!.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Sort tasks based on the selected sort option
  List<Task> _sortTasks(List<Task> tasks) {
    switch (_sortOption) {
      case SortOption.dueDate:
        return tasks..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      case SortOption.status:
        return tasks..sort((a, b) => a.status.compareTo(b.status));
      case SortOption.title:
        return tasks..sort((a, b) => a.title.compareTo(b.title));
    }
  }

  // Filter tasks based on the selected filter option
  List<Task> _filterTasks(List<Task> tasks) {
    final now = DateTime.now();
    switch (_filterOption) {
      case FilterOption.all:
        return tasks;
      case FilterOption.pending:
        return tasks.where((task) => !task.completed).toList();
      case FilterOption.overdue:
        return tasks
            .where((task) => !task.completed && task.dueDate.isBefore(now))
            .toList();
      case FilterOption.completed:
        return tasks.where((task) => task.completed).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          _buildThemeDropdown(),
          _buildLanguageDropdown(),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('tasks')
                  .where('userId', isEqualTo: user!.uid)
                  .get();
              final tasks = snapshot.docs
                  .map((doc) => Task.fromMap(doc.id, doc.data()))
                  .toList();
              downloadTasks(tasks); // Updated to use helper
            },
            tooltip: AppLocalizations.of(context)!.downloadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: AppLocalizations.of(context)!.logout,
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text(AppLocalizations.of(context)!.error))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.addNewTask,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.taskTitle,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.dueDateFormat,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDueDate(context),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.description,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)!.repeatTask),
                    value: _isRepeated,
                    onChanged: (value) {
                      setState(() {
                        _isRepeated = value!;
                        if (_isRepeated && _repeatUnit == 'none') {
                          _repeatUnit = 'days';
                        } else if (!_isRepeated) {
                          _repeatUnit = 'none';
                        }
                      });
                    },
                  ),
                  if (_isRepeated) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _repeatIntervalController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.repeatEvery,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _repeatInterval = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _repeatUnit,
                      onChanged: (value) {
                        setState(() {
                          _repeatUnit = value!;
                        });
                      },
                      items: ['none', 'minutes', 'hours', 'days']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addTask,
                      child: Text(AppLocalizations.of(context)!.addTask),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.yourTasks,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _buildSortDropdown(),
                          const SizedBox(width: 8),
                          _buildFilterDropdown(),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              final snapshot = await FirebaseFirestore.instance
                                  .collection('tasks')
                                  .where('userId', isEqualTo: user.uid)
                                  .get();
                              final tasks = snapshot.docs
                                  .map((doc) => Task.fromMap(doc.id, doc.data()))
                                  .toList();
                              downloadTasks(tasks); // Updated to use helper
                            },
                            tooltip: AppLocalizations.of(context)!.downloadTasks,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tasks')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(AppLocalizations.of(context)!.error));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text(AppLocalizations.of(context)!.noTasksAvailable));
                        }

                        final tasks = snapshot.data!.docs
                            .map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                            .toList();

                        // Apply sorting and filtering
                        final sortedTasks = _sortTasks(tasks);
                        final filteredTasks = _filterTasks(sortedTasks);

                        return ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return ListTile(
                              leading: Checkbox(
                                value: task.completed,
                                onChanged: (value) {
                                  _toggleTaskCompletion(task);
                                },
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color: task.dueDate.isBefore(DateTime.now()) && !task.completed
                                      ? Colors.red
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                  '${AppLocalizations.of(context)!.due}: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showAddTaskDialog(task: task),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteTask(task.id),
                                  ),
                                ],
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.notificationSound),
            leading: const Icon(Icons.notifications_active),
          ),
          ...NotificationService.soundOptions.entries.map((entry) {
             return RadioListTile<String>(
              title: Text(entry.key),
              value: entry.value,
              groupValue: _selectedSound,
              onChanged: (String? value) {
                if (value != null) {
                  _updateSelectedSound(value);
                  Navigator.pop(context); // Close drawer
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThemeDropdown() {
    return DropdownButton<ThemeOption>(
      value: widget.currentTheme,
      onChanged: (ThemeOption? newTheme) {
        if (newTheme != null) {
          widget.onThemeChanged(newTheme);
        }
      },
      items: ThemeOption.values.map((ThemeOption theme) {
        String label;
        switch (theme) {
          case ThemeOption.system:
            label = AppLocalizations.of(context)!.systemTheme;
            break;
          case ThemeOption.bright:
            label = AppLocalizations.of(context)!.brightTheme;
            break;
          case ThemeOption.dark:
            label = AppLocalizations.of(context)!.darkTheme;
            break;
          case ThemeOption.ocean:
            label = AppLocalizations.of(context)!.oceanTheme;
            break;
          case ThemeOption.forest:
            label = AppLocalizations.of(context)!.forestTheme;
            break;
          case ThemeOption.sunset:
            label = AppLocalizations.of(context)!.sunsetTheme;
            break;
        }
        return DropdownMenuItem<ThemeOption>(
          value: theme,
          child: Text(label),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<Locale>(
      value: Provider.of<LocaleProvider>(context).locale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          widget.onThemeChanged(widget.currentTheme);
          widget.onLocaleChanged(newLocale);
        }
      },
      items: const [
        Locale('en'),
        Locale('de'),
        Locale('lo'),
        Locale('ru'),
        Locale('th'),
      ].map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(locale.languageCode),
        );
      }).toList(),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<SortOption>(
      value: _sortOption,
      onChanged: (SortOption? newSortOption) {
        if (newSortOption != null) {
          setState(() {
            _sortOption = newSortOption;
          });
        }
      },
      items: SortOption.values.map((SortOption sortOption) {
        return DropdownMenuItem<SortOption>(
          value: sortOption,
          child: Text(
            sortOption.toString().split('.').last,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<FilterOption>(
      value: _filterOption,
      onChanged: (FilterOption? newFilterOption) {
        if (newFilterOption != null) {
          setState(() {
            _filterOption = newFilterOption;
          });
        }
      },
      items: FilterOption.values.map((FilterOption filterOption) {
        return DropdownMenuItem<FilterOption>(
          value: filterOption,
          child: Text(
            filterOption.toString().split('.').last,
          ),
        );
      }).toList(),
    );
  }
}
