import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use(keyProperties::load)
}

val prodKeystoreFile = rootProject.file("app/prod_keystore.jks")
val hasProdSigning =
    prodKeystoreFile.exists() &&
        keyProperties.getProperty("prodStorePassword") != null &&
        keyProperties.getProperty("prodKeyPassword") != null &&
        keyProperties.getProperty("prodKeyAlias") != null

android {
    namespace = "com.makinglifeeasie.withyou"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasProdSigning) {
            create("prodRelease") {
                storeFile = prodKeystoreFile
                storePassword = keyProperties.getProperty("prodStorePassword")
                keyAlias = keyProperties.getProperty("prodKeyAlias")
                keyPassword = keyProperties.getProperty("prodKeyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.makinglifeeasie.withyou"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "With You"
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "With You Dev"
            signingConfig = signingConfigs.getByName("debug")
        }

        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "With You"
            if (hasProdSigning) {
                signingConfig = signingConfigs.getByName("prodRelease")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }

        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
