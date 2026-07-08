// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الصلاة على وقتها';

  @override
  String get welcomeTitle => 'اوصل مسجدك على الوقت';

  @override
  String get welcomeBody =>
      'يخبرك التطبيق باللحظة المناسبة للخروج من البيت لتصل مسجدك على وقت الأذان أو الإقامة بالضبط.\n\nولحساب مواقيت الصلاة بدقة لمنطقتك، يحتاج التطبيق إلى موقعك.';

  @override
  String get allowLocation => 'السماح بالوصول للموقع';

  @override
  String get locationGranted => 'تم تحديد موقعك';

  @override
  String get locationDeniedNote =>
      'الموقع غير متاح — يمكنك المتابعة. ستبدأ الخريطة من الرياض؛ حرّكها إلى منطقتك.';

  @override
  String get stepNext => 'التالي';

  @override
  String get stepBack => 'رجوع';

  @override
  String get stepFinish => 'إنهاء';

  @override
  String get mosqueStepTitle => 'اختر مسجدك';

  @override
  String get mosqueStepHint => 'حرّك الخريطة حتى يقع الدبوس على مسجدك';

  @override
  String get mosqueNameLabel => 'اسم المسجد';

  @override
  String get mosqueNameDefault => 'مسجدي';

  @override
  String get travelStepTitle => 'الوصول للمسجد';

  @override
  String get travelMinutesLabel => 'الوقت من البيت إلى المسجد (بالدقائق)';

  @override
  String get calculateForMe => 'احسبها لي';

  @override
  String get walking => 'مشيًا';

  @override
  String get driving => 'بالسيارة';

  @override
  String get travelCalcFailed => 'تعذر حساب المسار — أدخل الدقائق يدويًا.';

  @override
  String get travelCalcNeedsLocation =>
      'اسمح بالوصول للموقع في الخطوة الأولى لاستخدام الحساب التلقائي.';

  @override
  String wuduToggle(int minutes) {
    return 'أتوضأ قبل الخروج (+$minutes د)';
  }

  @override
  String get bathroomToggle => 'أحتاج دورة المياه قبل الصلاة';

  @override
  String get bathroomMinutesLabel => 'دقائق دورة المياه';

  @override
  String get offsetsStepTitle => 'الإقامة في مسجدك';

  @override
  String get offsetsStepHint =>
      'كم دقيقة بعد الأذان تقام الصلاة؟ واختر أيضًا هل تريد الوصول عند الأذان أم عند الإقامة.';

  @override
  String get arriveBy => 'الوصول عند';

  @override
  String get targetAdhan => 'الأذان';

  @override
  String get targetIqama => 'الإقامة';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerJumuah => 'الجمعة';

  @override
  String get sectionJumuah => 'صلاة الجمعة';

  @override
  String get jumuahToggle => 'أحضر صلاة الجمعة';

  @override
  String get jumuahArriveEarlyLabel => 'الوصول قبل الأذان (بالدقائق)';

  @override
  String get jumuahHint =>
      'يوم الجمعة تُحسب صلاة الظهر جمعةً: يُحسب وقت الخروج لتصل المسجد قبل الأذان بهذه الدقائق.';

  @override
  String get prayerSettingsHint => 'فاصل الإقامة وهدف الوصول لكل صلاة';

  @override
  String get minutesShort => 'د';

  @override
  String get homeSetupComplete => 'اكتمل الإعداد!';

  @override
  String get homeComingSoon =>
      'الشاشة الرئيسية بالعدّادات المباشرة قادمة قريبًا.';

  @override
  String homeMosqueLine(String name) {
    return 'المسجد: $name';
  }

  @override
  String homeTravelLine(int minutes) {
    return 'وقت الوصول: $minutes د';
  }

  @override
  String get adhanIn => 'الأذان بعد';

  @override
  String get iqamaIn => 'الإقامة بعد';

  @override
  String get leaveIn => 'الخروج من البيت بعد';

  @override
  String get leaveNow => 'اطلع الحين!';

  @override
  String get adhanPassed => 'أُذّن';

  @override
  String get todaysPrayers => 'صلوات اليوم';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String notifTitle(String prayer) {
    return 'حان وقت الخروج لصلاة $prayer 🕌';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get sectionMosque => 'المسجد والموقع';

  @override
  String get changeMosque => 'تغيير المسجد';

  @override
  String get updateHomeLocation => 'تحديث موقع المنزل';

  @override
  String get homeLocationUpdated => 'تم تحديث موقع المنزل';

  @override
  String get homeLocationFailed => 'تعذر تحديد موقعك';

  @override
  String get sectionTiming => 'التوقيت';

  @override
  String get safetyMarginLabel => 'هامش أمان (دقائق)';

  @override
  String get sectionPerPrayer => 'إعدادات كل صلاة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get calcMethodNote => 'طريقة حساب مواقيت الصلاة';

  @override
  String get alertStyleTitle => 'نوع التنبيه';

  @override
  String get alertStandard => 'إشعار عادي';

  @override
  String get alertStandardDesc => 'إشعار عادي بالصوت الافتراضي.';

  @override
  String get alertAlarm => 'منبّه (صوت عالي)';

  @override
  String get alertAlarmDesc =>
      'يرن بصوت المنبّه — يسمع حتى في الوضع الصامت في أغلب الأجهزة — ويظهر على شاشة القفل.';

  @override
  String notifBody(String mosque, String prayer) {
    return 'اطلع الحين عشان توصل $mosque لصلاة $prayer على الوقت.';
  }
}
