// Force all subprojects to use the cached AGP version (avoids network downloads)
buildscript {
    configurations.all {
        resolutionStrategy {
            force("com.android.tools.build:gradle:8.13.1")
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Force build tools version and compileSdk for all subprojects (avoids missing platform errors)
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class)?.apply {
            buildToolsVersion = "36.1.0"
            compileSdkVersion(36)
        }
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
