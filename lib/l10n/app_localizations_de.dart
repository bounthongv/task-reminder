// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Aufgaben-Erinnerung';

  @override
  String get welcomeMessage => 'Willkommen bei Aufgaben-Erinnerung';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get registerWithGoogle => 'Mit Google registrieren';

  @override
  String get signInWithGooglePrompt => 'Sie können sich auch mit Google anmelden oder ein neues Konto erstellen:';

  @override
  String get theme => 'Thema';

  @override
  String get language => 'Sprache';

  @override
  String get logout => 'Abmelden';

  @override
  String get testNotification => 'Testbenachrichtigung';

  @override
  String get downloadTasks => 'Aufgaben herunterladen';

  @override
  String get testFirestore => 'Firestore testen';

  @override
  String get addTask => 'Aufgabe hinzufügen';

  @override
  String get addNewTask => 'Neue Aufgabe hinzufügen';

  @override
  String get taskTitle => 'Aufgabentitel';

  @override
  String get dueDateFormat => 'Fälligkeitsdatum (YYYY-MM-DD HH:MM)';

  @override
  String get description => 'Beschreibung';

  @override
  String get repeatTask => 'Aufgabe wiederholen';

  @override
  String get repeatEvery => 'Wiederholen alle (Zahl)';

  @override
  String get repeatsEvery => 'Wiederholt sich alle';

  @override
  String get yourTasks => 'Ihre Aufgaben';

  @override
  String get noTasksAvailable => 'Keine Aufgaben verfügbar.';

  @override
  String get error => 'Fehler';

  @override
  String get due => 'Fällig';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get filter => 'Filtern';

  @override
  String get sortDueDate => 'Fälligkeitsdatum';

  @override
  String get sortStatus => 'Status';

  @override
  String get sortTitle => 'Titel';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterPending => 'Ausstehend';

  @override
  String get filterOverdue => 'Überfällig';

  @override
  String get filterCompleted => 'Abgeschlossen';

  @override
  String get repeatMinutes => 'Minuten';

  @override
  String get repeatHours => 'Stunden';

  @override
  String get repeatDays => 'Tage';

  @override
  String get taskAddedSuccessfully => 'Aufgabe erfolgreich hinzugefügt';

  @override
  String get failedToAddTask => 'Fehler beim Hinzufügen der Aufgabe. Bitte versuchen Sie es erneut.';

  @override
  String get taskUpdatedSuccessfully => 'Aufgabe erfolgreich aktualisiert';

  @override
  String get failedToUpdateTask => 'Fehler beim Aktualisieren der Aufgabe. Bitte versuchen Sie es erneut.';

  @override
  String get taskDeletedSuccessfully => 'Aufgabe erfolgreich gelöscht';

  @override
  String get failedToDeleteTask => 'Fehler beim Löschen der Aufgabe. Bitte versuchen Sie es erneut.';

  @override
  String get taskOverdue => 'Aufgabe überfällig';

  @override
  String get reminder => 'Erinnerung';

  @override
  String get dismiss => 'Schließen';

  @override
  String get tasksDownloaded => 'Aufgaben als tasks.json heruntergeladen';

  @override
  String get downloadWebOnly => 'Download ist nur auf Web verfügbar';

  @override
  String get invalidDateFormat => 'Ungültiges Datumsformat! Verwenden Sie YYYY-MM-DD HH:MM';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get update => 'Aktualisieren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deleteTask => 'Aufgabe löschen';

  @override
  String confirmDeleteTask(Object taskTitle) {
    return 'Möchten Sie \'$taskTitle\' wirklich löschen?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get testDocumentWritten => 'Testdokument in Firestore geschrieben';

  @override
  String errorWritingTestDocument(Object error) {
    return 'Fehler beim Schreiben des Testdokuments: $error';
  }

  @override
  String get signOut => 'Abmelden';

  @override
  String get confirmSignOut => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get failedToSignOut => 'Abmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get accountExistsError => 'Ein Konto mit dieser E-Mail existiert bereits. Bitte melden Sie sich an oder verknüpfen Sie Ihr Konto.';

  @override
  String get filterBy => 'Filtern nach';

  @override
  String get taskUpcoming => 'Aufgabe bevorstehend';

  @override
  String get failedToCheckTasks => 'Aufgaben konnten nicht überprüft werden';

  @override
  String get systemTheme => 'System';

  @override
  String get brightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get oceanTheme => 'Ozean';

  @override
  String get forestTheme => 'Wald';

  @override
  String get sunsetTheme => 'Sonnenuntergang';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get sortByDueDate => 'Fälligkeitsdatum';

  @override
  String get sortByStatus => 'Status';

  @override
  String get sortByTitle => 'Titel';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get enterEmailToReset => 'Geben Sie Ihre E-Mail ein, um das Passwort zurückzusetzen';

  @override
  String get resetPasswordEmailSent => 'E-Mail zum Zurücksetzen des Passworts gesendet';

  @override
  String get sendResetLink => 'Link senden';

  @override
  String get failedToSendResetEmail => 'Fehler beim Senden der E-Mail. Bitte überprüfen Sie Ihre E-Mail-Adresse.';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get invalidEmailFormat => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get emailAlreadyExists => 'Diese E-Mail ist bereits in unserem System registriert';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail wird bereits verwendet';

  @override
  String get weakPassword => 'Das Passwort ist zu schwach. Bitte verwenden Sie ein stärkeres Passwort';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get registrationError => 'Registrierung fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get userNotFound => 'Kein Konto mit dieser E-Mail gefunden. Bitte überprüfen Sie Ihre E-Mail oder registrieren Sie ein neues Konto.';

  @override
  String get wrongPassword => 'Falsches Passwort. Bitte versuchen Sie es erneut.';

  @override
  String get userDisabled => 'Dieses Konto wurde deaktiviert. Bitte wenden Sie sich an den Support.';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto?';

  @override
  String get notificationSound => 'Benachrichtigungston';

  @override
  String get soundDefault => 'Standard';

  @override
  String get soundChime => 'Glockenspiel';

  @override
  String get soundBeep => 'Piepton';
}
