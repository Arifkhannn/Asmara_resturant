# Keep SLF4J classes
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Keep Binder
-keep class org.slf4j.impl.StaticLoggerBinder { *; }
-keep class org.slf4j.impl.** { *; }
