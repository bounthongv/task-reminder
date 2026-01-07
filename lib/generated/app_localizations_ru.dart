// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Напоминание о задачах';

  @override
  String get welcomeMessage => 'Добро пожаловать в Напоминание о задачах';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get signInWithGooglePrompt => 'Вы также можете войти или создать аккаунт через Google:';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get logout => 'Выйти';

  @override
  String get testNotification => 'Тестовое уведомление';

  @override
  String get downloadTasks => 'Скачать задачи';

  @override
  String get testFirestore => 'Тест Firestore';

  @override
  String get addTask => 'Добавить задачу';

  @override
  String get addNewTask => 'Добавить новую задачу';

  @override
  String get taskTitle => 'Название задачи';

  @override
  String get dueDateFormat => 'Срок выполнения (ГГГГ-ММ-ДД ЧЧ:ММ)';

  @override
  String get description => 'Описание';

  @override
  String get repeatTask => 'Повторять задачу';

  @override
  String get repeatEvery => 'Повторять каждые (число)';

  @override
  String get repeatsEvery => 'Повторяется каждые';

  @override
  String get yourTasks => 'Ваши задачи';

  @override
  String get noTasksAvailable => 'Нет доступных задач.';

  @override
  String get error => 'Ошибка';

  @override
  String get due => 'Срок';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get filter => 'Фильтр';

  @override
  String get sortDueDate => 'Дате выполнения';

  @override
  String get sortStatus => 'Статусу';

  @override
  String get sortTitle => 'Названию';

  @override
  String get filterAll => 'Все';

  @override
  String get filterPending => 'Ожидающие';

  @override
  String get filterOverdue => 'Просроченные';

  @override
  String get filterCompleted => 'Завершенные';

  @override
  String get repeatMinutes => 'Минуты';

  @override
  String get repeatHours => 'Часы';

  @override
  String get repeatDays => 'Дни';

  @override
  String get taskAddedSuccessfully => 'Задача успешно добавлена';

  @override
  String get failedToAddTask => 'Не удалось добавить задачу. Пожалуйста, попробуйте снова.';

  @override
  String get taskUpdatedSuccessfully => 'Задача успешно обновлена';

  @override
  String get failedToUpdateTask => 'Не удалось обновить задачу. Пожалуйста, попробуйте снова.';

  @override
  String get taskDeletedSuccessfully => 'Задача успешно удалена';

  @override
  String get failedToDeleteTask => 'Не удалось удалить задачу. Пожалуйста, попробуйте снова.';

  @override
  String get taskOverdue => 'Просроченная задача';

  @override
  String get reminder => 'Напоминание';

  @override
  String get dismiss => 'Отклонить';

  @override
  String get tasksDownloaded => 'Задачи скачаны как tasks.json';

  @override
  String get downloadWebOnly => 'Скачивание доступно только в веб-версии';

  @override
  String get invalidDateFormat => 'Неверный формат даты! Используйте ГГГГ-ММ-ДД ЧЧ:ММ';

  @override
  String get editTask => 'Редактировать задачу';

  @override
  String get update => 'Обновить';

  @override
  String get cancel => 'Отмена';

  @override
  String get deleteTask => 'Удалить задачу';

  @override
  String confirmDeleteTask(Object taskTitle) {
    return 'Вы уверены, что хотите удалить \'$taskTitle\'?';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get testDocumentWritten => 'Тестовый документ записан в Firestore';

  @override
  String errorWritingTestDocument(Object error) {
    return 'Ошибка при записи тестового документа: $error';
  }

  @override
  String get signOut => 'Выйти';

  @override
  String get confirmSignOut => 'Вы уверены, что хотите выйти?';

  @override
  String get failedToSignOut => 'Не удалось выйти. Пожалуйста, попробуйте снова.';

  @override
  String get accountExistsError => 'Аккаунт с этой электронной почтой уже существует. Пожалуйста, войдите или свяжите аккаунты.';

  @override
  String get filterBy => 'Фильтровать по';

  @override
  String get taskUpcoming => 'Предстоящая задача';

  @override
  String get failedToCheckTasks => 'Не удалось проверить задачи';

  @override
  String get systemTheme => 'Системная';

  @override
  String get brightTheme => 'Светлая';

  @override
  String get darkTheme => 'Тёмная';

  @override
  String get oceanTheme => 'Океан';

  @override
  String get forestTheme => 'Лес';

  @override
  String get sunsetTheme => 'Закат';

  @override
  String get loginButton => 'Войти';

  @override
  String get sortByDueDate => 'Срок выполнения';

  @override
  String get sortByStatus => 'Статус';

  @override
  String get sortByTitle => 'Название';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get resetPassword => 'Сброс пароля';

  @override
  String get enterEmailToReset => 'Введите ваш email для сброса пароля';

  @override
  String get resetPasswordEmailSent => 'Письмо для сброса пароля отправлено';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String get failedToSendResetEmail => 'Не удалось отправить письмо. Проверьте ваш email.';

  @override
  String get emailRequired => 'Email обязателен';
}
