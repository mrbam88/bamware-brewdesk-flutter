import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload keystore, read from android/key.properties (gitignored, never committed).
// See android/key.properties.template and submission/docs/SUBMISSION-RUNBOOK.md for how
// Bilal generates and fills this in on his own machine (Human-only ticket #5).
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "io.bamware.brewdesk"
    // Target/compile SDK 36 (Android 16) meets the Google Play requirement that new
    // apps and app updates target API 36+ starting 2026-08-31; see
    // https://developer.android.com/google/play/requirements/target-sdk
    // (verified 2026-08-28). Flutter 3.47.1 stable defaults compileSdk/targetSdk to 36
    // already (flutter.compileSdkVersion / flutter.targetSdkVersion below) so no
    // override is needed here — bumping the Flutter SDK is how this stays current.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.bamware.brewdesk"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Version scheme (documented in submission/docs/SUBMISSION-RUNBOOK.md):
        // versionName (pubspec `version` before the `+`) is semantic — bump on every
        // Play submission. versionCode (pubspec `version` after the `+`) must
        // strictly increase on every artifact uploaded to Play, including internal
        // testing builds; it never resets and is never reused.
        // Both are read from pubspec.yaml via the Flutter Gradle plugin.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Maps SDK key: key.properties `mapsApiKey` wins, MAPS_API_KEY env
        // is the CI/agent fallback, empty string otherwise (map renders
        // blank but the app builds — keeps clean checkouts working).
        manifestPlaceholders["MAPS_API_KEY"] =
            (if (hasKeystoreProperties) keystoreProperties["mapsApiKey"] as String? else null)
                ?: System.getenv("MAPS_API_KEY") ?: ""
    }

    signingConfigs {
        create("release") {
            if (hasKeystoreProperties) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Signs with the real upload key once android/key.properties exists
            // (Human-only ticket #5: keystore generation and Console registration).
            // Falls back to the debug key so `flutter build appbundle --release`
            // keeps succeeding unsigned in this repo and in CI, per issue #15 scope.
            signingConfig =
                if (hasKeystoreProperties) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
