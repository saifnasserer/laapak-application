import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from file
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.laapak.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.laapak.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Add multiDex support if needed
        multiDexEnabled = true
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        // Create a signing config for release builds
        // IMPORTANT: For production, create a keystore file and configure it properly
        // See: https://docs.flutter.dev/deployment/android#signing-the-app
        create("release") {
            // Load from key.properties file if it exists, otherwise fall back to environment variables or debug
            val keystoreFile = keystoreProperties["storeFile"] as String? 
                ?: System.getenv("KEYSTORE_FILE") 
                ?: "../keystore.jks"
            
            val keystorePassword = keystoreProperties["storePassword"] as String?
                ?: System.getenv("KEYSTORE_PASSWORD")
                ?: ""
            
            val keyAliasValue = keystoreProperties["keyAlias"] as String?
                ?: System.getenv("KEY_ALIAS")
                ?: ""
            
            val keyPasswordValue = keystoreProperties["keyPassword"] as String?
                ?: System.getenv("KEY_PASSWORD")
                ?: ""
            
            // Only set if keystore file exists and credentials are provided
            if (file(keystoreFile).exists() && keystorePassword.isNotEmpty() && keyAliasValue.isNotEmpty()) {
                storeFile = file(keystoreFile)
                storePassword = keystorePassword
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            } else {
                // Fallback to debug signing for development
                // WARNING: This should be replaced with a proper keystore for production
                storeFile = signingConfigs.getByName("debug").storeFile
                storePassword = signingConfigs.getByName("debug").storePassword
                keyAlias = signingConfigs.getByName("debug").keyAlias
                keyPassword = signingConfigs.getByName("debug").keyPassword
            }
        }
    }

    buildTypes {
        release {
            // Minification disabled to preserve notification permission functionality
            // ProGuard/R8 optimization breaks the permission request dialog even with keep rules
            // App size impact: ~5MB (59MB → 64MB) - acceptable trade-off for working permissions
            isMinifyEnabled = false
            isShrinkResources = false
            
            // ProGuard rules file (not actively used but kept for reference)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Use release signing config
            signingConfig = signingConfigs.getByName("release")
            
            // Remove logging in release builds
            buildConfigField("Boolean", "ENABLE_LOGGING", "false")
        }
        
        debug {
            // Keep logging enabled in debug builds
            isMinifyEnabled = false
            isShrinkResources = false
            buildConfigField("Boolean", "ENABLE_LOGGING", "true")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring support for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
