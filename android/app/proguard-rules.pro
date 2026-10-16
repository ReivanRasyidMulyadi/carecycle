# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.internal.mlkit_vision_label_common.** { *; }

# Supabase / GoTrue / Realtime (OkHttp, Retrofit, Kotlin serialization)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Hive
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep Kotlin metadata for reflection
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Keep Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# General Android
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
