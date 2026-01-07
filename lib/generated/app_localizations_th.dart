// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'ตัวเตือนงาน';

  @override
  String get welcomeMessage => 'ยินดีต้อนรับสู่ตัวเตือนงาน';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get register => 'ลงทะเบียน';

  @override
  String get email => 'อีเมล';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get signInWithGoogle => 'ลงชื่อเข้าใช้ด้วย Google';

  @override
  String get signInWithGooglePrompt => 'คุณยังสามารถลงชื่อเข้าใช้หรือสร้างบัญชีใหม่ด้วย Google:';

  @override
  String get theme => 'ธีม';

  @override
  String get language => 'ภาษา';

  @override
  String get logout => 'ออกจากระบบ';

  @override
  String get testNotification => 'ทดสอบการแจ้งเตือน';

  @override
  String get downloadTasks => 'ดาวน์โหลดงาน';

  @override
  String get testFirestore => 'ทดสอบ Firestore';

  @override
  String get addTask => 'เพิ่มงาน';

  @override
  String get addNewTask => 'เพิ่มงานใหม่';

  @override
  String get taskTitle => 'ชื่องาน';

  @override
  String get dueDateFormat => 'วันที่ครบกำหนด (YYYY-MM-DD HH:MM)';

  @override
  String get description => 'คำอธิบาย';

  @override
  String get repeatTask => 'งานที่ต้องทำซ้ำ';

  @override
  String get repeatEvery => 'ทำซ้ำทุก (ตัวเลข)';

  @override
  String get repeatsEvery => 'ทำซ้ำทุก';

  @override
  String get yourTasks => 'งานของคุณ';

  @override
  String get noTasksAvailable => 'ไม่มีงานที่สามารถใช้งานได้';

  @override
  String get error => 'ข้อผิดพลาด';

  @override
  String get due => 'ครบกำหนด';

  @override
  String get sortBy => 'เรียงตาม';

  @override
  String get filter => 'กรอง';

  @override
  String get sortDueDate => 'วันที่ครบกำหนด';

  @override
  String get sortStatus => 'สถานะ';

  @override
  String get sortTitle => 'ชื่อ';

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get filterPending => 'รอดำเนินการ';

  @override
  String get filterOverdue => 'เลยกำหนด';

  @override
  String get filterCompleted => 'เสร็จสิ้น';

  @override
  String get repeatMinutes => 'นาที';

  @override
  String get repeatHours => 'ชั่วโมง';

  @override
  String get repeatDays => 'วัน';

  @override
  String get taskAddedSuccessfully => 'เพิ่มงานสำเร็จแล้ว';

  @override
  String get failedToAddTask => 'ไม่สามารถเพิ่มงานได้ กรุณาลองใหม่';

  @override
  String get taskUpdatedSuccessfully => 'อัปเดตงานสำเร็จแล้ว';

  @override
  String get failedToUpdateTask => 'ไม่สามารถอัปเดตงานได้ กรุณาลองใหม่';

  @override
  String get taskDeletedSuccessfully => 'ลบงานสำเร็จแล้ว';

  @override
  String get failedToDeleteTask => 'ไม่สามารถลบงานได้ กรุณาลองใหม่';

  @override
  String get taskOverdue => 'งานเลยกำหนด';

  @override
  String get reminder => 'การเตือน';

  @override
  String get dismiss => 'ปิด';

  @override
  String get tasksDownloaded => 'ดาวน์โหลดงานเป็น tasks.json แล้ว';

  @override
  String get downloadWebOnly => 'การดาวน์โหลดใช้ได้เฉพาะบนเว็บเท่านั้น';

  @override
  String get invalidDateFormat => 'รูปแบบวันที่ไม่ถูกต้อง! ใช้ YYYY-MM-DD HH:MM';

  @override
  String get editTask => 'แก้ไขงาน';

  @override
  String get update => 'อัปเดต';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get deleteTask => 'ลบงาน';

  @override
  String confirmDeleteTask(Object taskTitle) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \'$taskTitle\'?';
  }

  @override
  String get delete => 'ลบ';

  @override
  String get testDocumentWritten => 'เขียนเอกสารทดสอบลงใน Firestore แล้ว';

  @override
  String errorWritingTestDocument(Object error) {
    return 'ข้อผิดพลาดในการเขียนเอกสารทดสอบ: $error';
  }

  @override
  String get signOut => 'ออกจากระบบ';

  @override
  String get confirmSignOut => 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?';

  @override
  String get failedToSignOut => 'ไม่สามารถออกจากระบบได้ กรุณาลองใหม่';

  @override
  String get accountExistsError => 'บัญชีที่มีอีเมลนี้มีอยู่แล้ว กรุณาเข้าสู่ระบบหรือเชื่อมโยงบัญชีของคุณ';

  @override
  String get filterBy => 'กรองตาม';

  @override
  String get taskUpcoming => 'งานที่จะเกิดขึ้น';

  @override
  String get failedToCheckTasks => 'ตรวจสอบงานไม่สำเร็จ';

  @override
  String get systemTheme => 'ระบบ';

  @override
  String get brightTheme => 'สว่าง';

  @override
  String get darkTheme => 'มืด';

  @override
  String get oceanTheme => 'มหาสมุทร';

  @override
  String get forestTheme => 'ป่า';

  @override
  String get sunsetTheme => 'พระอาทิตย์ตก';

  @override
  String get loginButton => 'เข้าสู่ระบบ';

  @override
  String get sortByDueDate => 'วันที่ครบกำหนด';

  @override
  String get sortByStatus => 'สถานะ';

  @override
  String get sortByTitle => 'หัวข้อ';

  @override
  String get forgotPassword => 'ลืมรหัสผ่าน?';

  @override
  String get resetPassword => 'รีเซ็ตรหัสผ่าน';

  @override
  String get enterEmailToReset => 'ใส่อีเมลของคุณเพื่อรีเซ็ตรหัสผ่าน';

  @override
  String get resetPasswordEmailSent => 'ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว';

  @override
  String get sendResetLink => 'ส่งลิงก์รีเซ็ต';

  @override
  String get failedToSendResetEmail => 'ไม่สามารถส่งอีเมลรีเซ็ตได้ กรุณาตรวจสอบอีเมลของคุณ';

  @override
  String get emailRequired => 'กรุณาระบุอีเมล';
}
