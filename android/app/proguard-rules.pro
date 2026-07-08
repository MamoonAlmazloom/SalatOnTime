# WorkManager (background alert refresh): Room instantiates WorkDatabase_Impl
# reflectively, so R8 must keep its no-arg constructor — the app crashes at
# process start otherwise (NoSuchMethodException: WorkDatabase_Impl.<init>).
-keep class androidx.work.impl.WorkDatabase_Impl { <init>(); }

# flutter_local_notifications persists scheduled alerts via Gson reflection;
# without these rules release builds fail to (re)schedule silently.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
