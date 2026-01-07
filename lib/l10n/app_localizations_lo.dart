// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lao (`lo`).
class AppLocalizationsLo extends AppLocalizations {
  AppLocalizationsLo([String locale = 'lo']) : super(locale);

  @override
  String get appTitle => 'ເຕືອນຄວາມຈຳກ່ຽວກັບວຽກ';

  @override
  String get welcomeMessage => 'ຍິນດີຕ້ອນຮັບສູ່ເຕືອນຄວາມຈຳກ່ຽວກັບວຽກ';

  @override
  String get login => 'ເຂົ້າສູ່ລະບົບ';

  @override
  String get register => 'ລົງທະບຽນ';

  @override
  String get email => 'อีเมล';

  @override
  String get password => 'ລະຫັດຜ່ານ';

  @override
  String get signInWithGoogle => 'ເຂົ້າສູ່ລະບົບດ້ວຍ Google';

  @override
  String get signInWithGooglePrompt => 'ທ່ານຍັງສາມາດເຂົ້າສູ່ລະບົບ ຫຼື ສ້າງບັນຊີໃໝ່ດ້ວຍ Google:';

  @override
  String get theme => 'ຮູບແບບ';

  @override
  String get language => 'ພາສາ';

  @override
  String get logout => 'ອອກຈາກລະບົບ';

  @override
  String get testNotification => 'ທົດສອບການແຈ້ງເຕືອນ';

  @override
  String get downloadTasks => 'ດາວໂຫຼດວຽກ';

  @override
  String get testFirestore => 'ທົດສອບ Firestore';

  @override
  String get addTask => 'ເພີ່ມວຽກ';

  @override
  String get addNewTask => 'ເພີ່ມວຽກໃໝ່';

  @override
  String get taskTitle => 'ຊື່ວຽກ';

  @override
  String get dueDateFormat => 'ວັນທີ່ຄົບກຳນົດ (YYYY-MM-DD HH:MM)';

  @override
  String get description => 'ລາຍລະອຽດ';

  @override
  String get repeatTask => 'ວຽກທີ່ຕ້ອງເຮັດຊ້ຳ';

  @override
  String get repeatEvery => 'ຊ້ຳທຸກໆ (ຕົວເລກ)';

  @override
  String get repeatsEvery => 'ຊ້ຳທຸກໆ';

  @override
  String get yourTasks => 'ວຽກຂອງທ່ານ';

  @override
  String get noTasksAvailable => 'ບໍ່ມີວຽກທີ່ສາມາດໃຊ້ໄດ້.';

  @override
  String get error => 'ຂໍ້ຜິດພາດ';

  @override
  String get due => 'ຄົບກຳນົດ';

  @override
  String get sortBy => 'ຈັດລຽງຕາມ';

  @override
  String get filter => 'ກັ່ນຕອງ';

  @override
  String get sortDueDate => 'ວັນທີ່ຄົບກຳນົດ';

  @override
  String get sortStatus => 'ສະຖານະ';

  @override
  String get sortTitle => 'ຊື່';

  @override
  String get filterAll => 'ທັງໝົດ';

  @override
  String get filterPending => 'ລໍຖ້າ';

  @override
  String get filterOverdue => 'ເກີນຄົບກຳນົດ';

  @override
  String get filterCompleted => 'ສຳເລັດ';

  @override
  String get repeatMinutes => 'ນາທີ';

  @override
  String get repeatHours => 'ຊົ່ວໂມງ';

  @override
  String get repeatDays => 'ມື້';

  @override
  String get taskAddedSuccessfully => 'ເພີ່ມວຽກສຳເລັດແລ້ວ';

  @override
  String get failedToAddTask => 'ບໍ່ສາມາດເພີ່ມວຽກໄດ້. ກະລຸນາລອງໃໝ່.';

  @override
  String get taskUpdatedSuccessfully => 'ອັບເດດວຽກສຳເລັດແລ້ວ';

  @override
  String get failedToUpdateTask => 'ບໍ່ສາມາດອັບເດດວຽກໄດ້. ກະລຸນາລອງໃໝ່.';

  @override
  String get taskDeletedSuccessfully => 'ລຶບວຽກສຳເລັດແລ້ວ';

  @override
  String get failedToDeleteTask => 'ບໍ່ສາມາດລຶບວຽກໄດ້. ກະລຸນາລອງໃໝ່.';

  @override
  String get taskOverdue => 'ວຽກເກີນຄົບກຳນົດ';

  @override
  String get reminder => 'ເຕືອນຄວາມຈຳ';

  @override
  String get dismiss => 'ປິດ';

  @override
  String get tasksDownloaded => 'ດາວໂຫຼດວຽກເປັນ tasks.json ແລ້ວ';

  @override
  String get downloadWebOnly => 'ການດາວໂຫຼດສາມາດໃຊ້ໄດ້ສະເພາະໃນເວັບເທົ່ານັ້ນ';

  @override
  String get invalidDateFormat => 'ຮູບແບບວັນທີ່ບໍ່ຖືກຕ້ອງ! ໃຊ້ YYYY-MM-DD HH:MM';

  @override
  String get editTask => 'ແກ້ໄຂວຽກ';

  @override
  String get update => 'ອັບເດດ';

  @override
  String get cancel => 'ຍົກເລີກ';

  @override
  String get deleteTask => 'ລຶບວຽກ';

  @override
  String confirmDeleteTask(Object taskTitle) {
    return 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບ \'$taskTitle\'?';
  }

  @override
  String get delete => 'ລຶບ';

  @override
  String get testDocumentWritten => 'ຂຽນເອກະສານທົດສອບໃສ່ Firestore ແລ້ວ';

  @override
  String errorWritingTestDocument(Object error) {
    return 'ຂໍ້ຜິດພາດໃນການຂຽນເອກະສານທົດສອບ: $error';
  }

  @override
  String get signOut => 'ອອກຈາກລະບົບ';

  @override
  String get confirmSignOut => 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?';

  @override
  String get failedToSignOut => 'ບໍ່ສາມາດອອກຈາກລະບົບໄດ້. ກະລຸນາລອງໃໝ່.';

  @override
  String get accountExistsError => 'ບັນຊີທີ່ໃຊ້ອີເມວນີ້ມີຢູ່ແລ້ວ. ກະລຸນາເຂົ້າສູ່ລະບົບ ຫຼື ເຊື່ອມໂຍງບັນຊີຂອງທ່ານ.';

  @override
  String get filterBy => 'ກັ່ນຕອງຕາມ';

  @override
  String get taskUpcoming => 'ວຽກທີ່ຈະມາເຖິງ';

  @override
  String get failedToCheckTasks => 'ການກວດສອບວຽກລົ້ມເຫຼວ';

  @override
  String get systemTheme => 'ລະບົບ';

  @override
  String get brightTheme => 'ສົດໃສ';

  @override
  String get darkTheme => 'ມືດ';

  @override
  String get oceanTheme => 'ມະຫາສະໝຸດ';

  @override
  String get forestTheme => 'ປ່າໄມ້';

  @override
  String get sunsetTheme => 'ຕາເວັນຕົກ';

  @override
  String get loginButton => 'ເຂົ້າສູ່ລະບົບ';

  @override
  String get sortByDueDate => 'ວັນທີໝົດກຳນົດ';

  @override
  String get sortByStatus => 'ສະຖານະ';

  @override
  String get sortByTitle => 'ຫົວຂໍ້';

  @override
  String get forgotPassword => 'ລືມລະຫັດຜ່ານ?';

  @override
  String get resetPassword => 'ຕັ້ງຄ່າລະຫັດຜ່ານໃໝ່';

  @override
  String get enterEmailToReset => 'ໃສ່ອີເມວຂອງທ່ານເພື່ອຕັ້ງຄ່າລະຫັດຜ່ານໃໝ່';

  @override
  String get resetPasswordEmailSent => 'ສົ່ງອີເມວຕັ້ງຄ່າລະຫັດຜ່ານແລ້ວ';

  @override
  String get sendResetLink => 'ສົ່ງລິ້ງຕັ້ງຄ່າໃໝ່';

  @override
  String get failedToSendResetEmail => 'ບໍ່ສາມາດສົ່ງອີເມວຕັ້ງຄ່າໃໝ່ໄດ້. ກະລຸນາກວດສອບອີເມວຂອງທ່ານ.';

  @override
  String get emailRequired => 'ຕ້ອງການອີເມວ';
}
