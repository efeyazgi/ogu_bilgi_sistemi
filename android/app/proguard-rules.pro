# Flutter temel kuralları - çok kritik!
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter JNI
-keepclassmembers class * {
    native <methods>;
}

# Google Play Core (Flutter Play Store split components için)
-dontwarn com.google.android.play.**
-keep class com.google.android.play.** { *; }
-keep interface com.google.android.play.** { *; }

# HTTP ve network işlemleri - genişletilmiş
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# JSON serialization (Gson, Jackson vs.)
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class com.google.gson.stream.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.TypeAdapter

# HTTP client libraries
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-dontwarn okio.**
-keep class okio.** { *; }

# OGÜ Bilgi Sistemi özel sınıfları
-keep class com.ogu.bilgisistemi.** { *; }

# Generic obfuscation ayarları
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose