import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (tracker O-13): the owner's upload key, from the environment
// (CI: ST_UPLOAD_KEYSTORE, ST_UPLOAD_STORE_PASSWORD, ST_UPLOAD_KEY_ALIAS,
// ST_UPLOAD_KEY_PASSWORD) or from android/key.properties on a machine the owner
// trusts (storeFile, storePassword, keyAlias, keyPassword). Neither is ever
// committed. Without them, release builds stay debug-signed: fine for testing,
// refused by the Play Store.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
fun signing(env: String, key: String): String? = System.getenv(env)?.takeIf { it.isNotEmpty() } ?: keyProperties.getProperty(key)
val releaseKeystore = signing("ST_UPLOAD_KEYSTORE", "storeFile")
// The application ID is permanent once published; a placeholder until the owner
// decides (ST_APPLICATION_ID or -PappId=... to build with the chosen one).
val appId = System.getenv("ST_APPLICATION_ID")?.takeIf { it.isNotEmpty() } ?: (project.findProperty("appId") as String?) ?: "com.example.digiboard_app"

android {
    namespace = "com.example.digiboard_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = appId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = file(releaseKeystore)
                storePassword = signing("ST_UPLOAD_STORE_PASSWORD", "storePassword")
                keyAlias = signing("ST_UPLOAD_KEY_ALIAS", "keyAlias")
                keyPassword = signing("ST_UPLOAD_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (releaseKeystore != null) "release" else "debug")
        }
    }
}

flutter {
    source = "../.."
}
