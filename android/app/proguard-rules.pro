# BrewDesk release shrinker rules.
#
# Flutter's own engine/embedding classes are kept by the rules bundled in
# `proguard-android-optimize.txt` (applied first in build.gradle.kts), so this
# file only needs project- and plugin-specific keeps.
#
# geolocator, shared_preferences, and url_launcher ship their own consumer
# ProGuard rules inside their AARs and do not need entries here. If a plugin
# is added later that reflects into native code (e.g. anything using
# JSON-annotation reflection or a WebView JS bridge), add its keep rule here
# and note why.
