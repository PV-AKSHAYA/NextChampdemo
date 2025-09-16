buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
         // Usually configured by Flutter plugin; can omit if managed
        classpath("com.google.gms:google-services:4.4.3") // Google services plugin classpath
        // Add other classpaths if needed
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

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
