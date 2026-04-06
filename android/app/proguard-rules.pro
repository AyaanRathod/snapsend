# Flutter Wrapper for Google ML Kit Text Recognition
# Suppress warnings about missing language-specific script classes.
# We only use the default Latin script, so R8 safely can ignore the Chinese/Japanese/Korean/Devanagari builders.

-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
