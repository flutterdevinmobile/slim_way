# Serverpod serialization needs these
-keep class com.slim_way.client.protocol.** { *; }
-keep class com.serverpod.auth.client.** { *; }
-keep class com.serverpod.client.** { *; }

# Keep models from being obfuscated
-keepclassmembers class * extends com.serverpod.serialization.SerializableEntity {
    <fields>;
    <methods>;
}

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
