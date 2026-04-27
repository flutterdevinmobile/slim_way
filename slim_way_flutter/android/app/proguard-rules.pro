# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Serverpod serialization
-keep class com.serverpod.** { *; }
-keep class dev.serverpod.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Hive
-keep class com.hivedb.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Health Connect
-keep class androidx.health.connect.** { *; }

# Keep Dart entry points
-keep class **.GeneratedPluginRegistrant { *; }
