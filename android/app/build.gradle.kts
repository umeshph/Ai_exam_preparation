plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
}

android {
    namespace = "com.example.ai_exam_prep"
    compileSdk = 35 // Updated SDK version for modern Android apps
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai_exam_prep"
        minSdk = 21 // Minimum SDK version for Flutter and Firebase compatibility
        targetSdk = 33 // Target SDK version
        versionCode = 1 // Your app version code
        versionName = "1.0" // Your app version name
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Debug signing configuration
        }
    }
}

dependencies {
    // Firebase dependencies
    implementation(platform("com.google.firebase:firebase-bom:32.2.0")) // Firebase BOM for version management
    implementation("com.google.firebase:firebase-firestore") // Firestore dependency
    implementation("com.google.firebase:firebase-storage") // Storage dependency
    implementation("androidx.browser:browser:1.4.0") // Required for URL launching functionality
}

flutter {
    source = "../.." // Flutter module source
}

apply(plugin = "com.google.gms.google-services") // Ensures Firebase services are applied
