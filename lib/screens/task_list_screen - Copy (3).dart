import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_reminder_flutter/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart'; // For date formatting

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

class _TaskListScreenState extends State<TaskListScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _repeatIntervalController = TextEditingController(); // Added for repeat interval
  String _repeatUnit = 'none';
  int _repeatInterval = 0;
  bool _isRepeated = false;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _repeatIntervalController.dispose();
    super.dispose();
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
        repeatUnit: _repeatUnit,
        repeatInterval: _repeatInterval,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskAddedSuccessfully),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToAddTask),
        ),
      );
    }
  }

  Future<void> _updateTask(Task task) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskUpdatedSuccessfully),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskDeletedSuccessfully),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToUpdateTask),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showAddTaskDialog({Task? task}) {
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
                    setState(() {
                      _isRepeated = value!;
                    });
                  },
                ),
                if (_isRepeated) ...[
                  DropdownButton<String>(
                    value: _repeatUnit,
                    onChanged: (value) {
                      setState(() {
                        _repeatUnit = value!;
                      });
                    },
                    items: ['minutes', 'hours', 'days']
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
                  final updatedTask = Task(
                    id: task.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDueDate ?? task.dueDate,
                    repeatUnit: _repeatUnit,
                    repeatInterval: _repeatInterval,
                    completed: task.completed,
                    isRepeated: _isRepeated,
                    status: task.status,
                    userId: task.userId,
                  );
                  _updateTask(updatedTask);
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          _buildThemeDropdown(),
          _buildLanguageDropdown(),
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
                      items: ['minutes', 'hours', 'days']
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
                  Text(
                    AppLocalizations.of(context)!.yourTasks,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return ListTile(
                              leading: Checkbox(
                                value: task.completed,
                                onChanged: (value) {
                                  _toggleTaskCompletion(task);
                                },
                              ),
                              title: Text(task.title),
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

  Widget _buildThemeDropdown() {
    return DropdownButton<ThemeOption>(
      value: widget.currentTheme,
      onChanged: (ThemeOption? newTheme) {
        if (newTheme != null) {
          widget.onThemeChanged(newTheme);
        }
      },
      items: ThemeOption.values.map((ThemeOption theme) {
        return DropdownMenuItem<ThemeOption>(
          value: theme,
          child: Text(
            theme.toString().split('.').last,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<Locale>(
      value: Provider.of<LocaleProvider>(context).locale,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          widget.onThemeChanged(widget.currentTheme); // Ensure theme is reapplied
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
}