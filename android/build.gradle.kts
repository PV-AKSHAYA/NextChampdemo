plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false  // recommended Kotlin version for AGP 8.9.1
    id("com.google.gms.google-services") version "4.4.3" apply false
}


buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // If still needed, specify the classpath with full notation (optional if using plugins)
        classpath("com.google.gms:google-services:4.4.3")
      classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directories etc. (optional depending on project requirements)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
