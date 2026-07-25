plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.soutuk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // llm_llamacpp's native backend loader (ggml_backend_load_all_from_path)
    // needs native libs extracted to the filesystem, not read from inside
    // the APK zip — the modern AGP equivalent of the deprecated
    // android:extractNativeLibs manifest attribute.
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.soutuk"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // llm_llamacpp's native Android library declares minSdkVersion 28 —
        // Flutter's own default (24) is too low and fails the manifest merge.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

dependencies {
    // llama_cpp_dart spike (translatorA leg only) — prebuilt CPU AAR from
    // netdur/llama_cpp_dart's v0.9.0-dev.9 release, checksum-verified.
    // Not a Flutter plugin, so this wiring is manual: see
    // https://github.com/netdur/llama_cpp_dart#readme
    implementation(files("libs/llama-cpp-dart.aar"))
}
