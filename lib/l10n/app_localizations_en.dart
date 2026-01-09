// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Task Reminder';

  @override
  String get welcomeMessage => 'Welcome to Task Reminder';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithGooglePrompt => 'You can also sign in or create a new account with Google:';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get downloadTasks => 'Download Tasks';

  @override
  String get testFirestore => 'Test Firestore';

  @override
  String get addTask => 'Add Task';

  @override
  String get addNewTask => 'Add a New Task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get dueDateFormat => 'Due Date (YYYY-MM-DD HH:MM)';

  @override
  String get description => 'Description';

  @override
  String get repeatTask => 'Repeat Task';

  @override
  String get repeatEvery => 'Repeat Every (number)';

  @override
  String get repeatsEvery => 'Repeats every';

  @override
  String get yourTasks => 'Your Tasks';

  @override
  String get noTasksAvailable => 'No tasks available.';

  @override
  String get error => 'Error';

  @override
  String get due => 'Due';

  @override
  String get sortBy => 'Sort by';

  @override
  String get filter => 'Filter';

  @override
  String get sortDueDate => 'Due Date';

  @override
  String get sortStatus => 'Status';

  @override
  String get sortTitle => 'Title';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get repeatMinutes => 'Minutes';

  @override
  String get repeatHours => 'Hours';

  @override
  String get repeatDays => 'Days';

  @override
  String get taskAddedSuccessfully => 'Task added successfully';

  @override
  String get failedToAddTask => 'Failed to add task. Please try again.';

  @override
  String get taskUpdatedSuccessfully => 'Task updated successfully';

  @override
  String get failedToUpdateTask => 'Failed to update task. Please try again.';

  @override
  String get taskDeletedSuccessfully => 'Task deleted successfully';

  @override
  String get failedToDeleteTask => 'Failed to delete task. Please try again.';

  @override
  String get taskOverdue => 'Task Overdue';

  @override
  String get reminder => 'Reminder';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get tasksDownloaded => 'Tasks downloaded as tasks.json';

  @override
  String get downloadWebOnly => 'Download is only available on web';

  @override
  String get invalidDateFormat => 'Invalid date format! Use YYYY-MM-DD HH:MM';

  @override
  String get editTask => 'Edit Task';

  @override
  String get update => 'Update';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String confirmDeleteTask(Object taskTitle) {
    return 'Are you sure you want to delete \'$taskTitle\'?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get testDocumentWritten => 'Test document written to Firestore';

  @override
  String errorWritingTestDocument(Object error) {
    return 'Error writing test document: $error';
  }

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOut => 'Are you sure you want to sign out?';

  @override
  String get failedToSignOut => 'Failed to sign out. Please try again.';

  @override
  String get accountExistsError => 'An account with this email already exists. Please log in or link your account.';

  @override
  String get filterBy => 'Filter by';

  @override
  String get taskUpcoming => 'Task upcoming';

  @override
  String get failedToCheckTasks => 'Failed to check tasks';

  @override
  String get systemTheme => 'System';

  @override
  String get brightTheme => 'Bright';

  @override
  String get darkTheme => 'Dark';

  @override
  String get oceanTheme => 'Ocean';

  @override
  String get forestTheme => 'Forest';

  @override
  String get sunsetTheme => 'Sunset';

  @override
  String get loginButton => 'Login';

  @override
  String get sortByDueDate => 'Due Date';

  @override
  String get sortByStatus => 'Status';

  @override
  String get sortByTitle => 'Title';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get enterEmailToReset => 'Enter your email to reset password';

  @override
  String get resetPasswordEmailSent => 'Password reset email sent';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get failedToSendResetEmail => 'Failed to send reset email. Please check your email address.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmailFormat => 'Please enter a valid email address';

  @override
  String get emailAlreadyExists => 'This email is already registered in our system';

  @override
  String get emailAlreadyInUse => 'This email is already in use';

  @override
  String get weakPassword => 'Password is too weak. Please use a stronger password';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get registrationError => 'Registration failed. Please try again';

  @override
  String get userNotFound => 'No account found with this email. Please check your email or register a new account.';

  @override
  String get wrongPassword => 'Incorrect password. Please try again.';

  @override
  String get userDisabled => 'This account has been disabled. Please contact support.';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';
}
