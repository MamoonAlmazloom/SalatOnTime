// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق الصلاة';

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
}
