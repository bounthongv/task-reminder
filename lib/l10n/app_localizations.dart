import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('lo'),
    Locale('ru'),
    Locale('th')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Reminder'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Task Reminder'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithGooglePrompt.
  ///
  /// In en, this message translates to:
  /// **'You can also sign in or create a new account with Google:'**
  String get signInWithGooglePrompt;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @downloadTasks.
  ///
  /// In en, this message translates to:
  /// **'Download Tasks'**
  String get downloadTasks;

  /// No description provided for @testFirestore.
  ///
  /// In en, this message translates to:
  /// **'Test Firestore'**
  String get testFirestore;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @addNewTask.
  ///
  /// In en, this message translates to:
  /// **'Add a New Task'**
  String get addNewTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @dueDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Due Date (YYYY-MM-DD HH:MM)'**
  String get dueDateFormat;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @repeatTask.
  ///
  /// In en, this message translates to:
  /// **'Repeat Task'**
  String get repeatTask;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat Every (number)'**
  String get repeatEvery;

  /// No description provided for @repeatsEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeats every'**
  String get repeatsEvery;

  /// No description provided for @yourTasks.
  ///
  /// In en, this message translates to:
  /// **'Your Tasks'**
  String get yourTasks;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available.'**
  String get noTasksAvailable;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get sortDueDate;

  /// No description provided for @sortStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sortStatus;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @repeatMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get repeatMinutes;

  /// No description provided for @repeatHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get repeatHours;

  /// No description provided for @repeatDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get repeatDays;

  /// No description provided for @taskAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task added successfully'**
  String get taskAddedSuccessfully;

  /// No description provided for @failedToAddTask.
  ///
  /// In en, this message translates to:
  /// **'Failed to add task. Please try again.'**
  String get failedToAddTask;

  /// No description provided for @taskUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdatedSuccessfully;

  /// No description provided for @failedToUpdateTask.
  ///
  /// In en, this message translates to:
  /// **'Failed to update task. Please try again.'**
  String get failedToUpdateTask;

  /// No description provided for @taskDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeletedSuccessfully;

  /// No description provided for @failedToDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete task. Please try again.'**
  String get failedToDeleteTask;

  /// No description provided for @taskOverdue.
  ///
  /// In en, this message translates to:
  /// **'Task Overdue'**
  String get taskOverdue;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @tasksDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Tasks downloaded as tasks.json'**
  String get tasksDownloaded;

  /// No description provided for @downloadWebOnly.
  ///
  /// In en, this message translates to:
  /// **'Download is only available on web'**
  String get downloadWebOnly;

  /// No description provided for @invalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format! Use YYYY-MM-DD HH:MM'**
  String get invalidDateFormat;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @confirmDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{taskTitle}\'?'**
  String confirmDeleteTask(Object taskTitle);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @testDocumentWritten.
  ///
  /// In en, this message translates to:
  /// **'Test document written to Firestore'**
  String get testDocumentWritten;

  /// No description provided for @errorWritingTestDocument.
  ///
  /// In en, this message translates to:
  /// **'Error writing test document: {error}'**
  String errorWritingTestDocument(Object error);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @failedToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out. Please try again.'**
  String get failedToSignOut;

  /// No description provided for @accountExistsError.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please log in or link your account.'**
  String get accountExistsError;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @taskUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Task upcoming'**
  String get taskUpcoming;

  /// No description provided for @failedToCheckTasks.
  ///
  /// In en, this message translates to:
  /// **'Failed to check tasks'**
  String get failedToCheckTasks;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @brightTheme.
  ///
  /// In en, this message translates to:
  /// **'Bright'**
  String get brightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @oceanTheme.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get oceanTheme;

  /// No description provided for @forestTheme.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forestTheme;

  /// No description provided for @sunsetTheme.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunsetTheme;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @sortByDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get sortByDueDate;

  /// No description provided for @sortByStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sortByStatus;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortByTitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @enterEmailToReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset password'**
  String get enterEmailToReset;

  /// No description provided for @resetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get resetPasswordEmailSent;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @failedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email. Please check your email address.'**
  String get failedToSendResetEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'lo', 'ru', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'lo': return AppLocalizationsLo();
    case 'ru': return AppLocalizationsRu();
    case 'th': return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
