# ── Gson (used internally by flutter_local_notifications and others) ────────
# Keep generic Signature so TypeToken<ArrayList<NotificationDetails>>() can
# resolve its type parameter at runtime. R8 strips Signature by default during
# dex conversion, which breaks Gson reflection.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses, EnclosingMethod
-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ── flutter_local_notifications ─────────────────────────────────────────────
# Keeps NotificationDetails and friends so Gson can deserialize them.
-keep class com.dexterous.** { *; }

# ── Floor / SQLite / Kotlin coroutines ──────────────────────────────────────
-keep class * implements androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.paging.**
-keep class androidx.sqlite.** { *; }
-keepclassmembers class kotlinx.coroutines.** { *; }

# ── Health Connect ──────────────────────────────────────────────────────────
-keep class androidx.health.** { *; }
-dontwarn androidx.health.connect.**

# ── speech_to_text ──────────────────────────────────────────────────────────
-keep class com.csdcorp.speech_to_text.** { *; }

# ── mobile_scanner / ML Kit barcode ─────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

# ── home_widget ─────────────────────────────────────────────────────────────
-keep class es.antonborri.home_widget.** { *; }

# ── Flutter engine + standard plugins ───────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Google Play Core (deferred components / dynamic feature delivery) ───────
# Flutter references these classes for split-install support, but we don't use
# deferred components and the Play Core lib isn't on the classpath. Tell R8 to
# ignore the missing references rather than fail the build.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep all classes referenced in the AndroidManifest (widget receivers etc.)
-keep class com.example.diplomka.** { *; }
