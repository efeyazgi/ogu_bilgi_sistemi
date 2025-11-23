allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File(rootDir, "../build")
subprojects {
    project.buildDir = File(rootDir, "../build/${project.name}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
