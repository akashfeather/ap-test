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

    // Add namespace to library projects
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            namespace = "com.example.${project.name}"
        }
    }

    // Force namespace for on_audio_query_android
    if (project.name.contains("on_audio_query")) {
        plugins.withId("com.android.library") {
            configure<com.android.build.gradle.LibraryExtension> {
                namespace = "com.lucasjosino.on_audio_query"
            }
        }
    }

    afterEvaluate {
        // Override Java and Kotlin targets for all plugins after they're fully evaluated
        plugins.withId("com.android.library") {
            configure<com.android.build.gradle.LibraryExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_1_8
                    targetCompatibility = JavaVersion.VERSION_1_8
                }
            }
        }
    }

    // Override Kotlin JVM target for all subprojects
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
