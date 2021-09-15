@echo off
:: https://stackoverflow.com/questions/4036754/why-does-only-the-first-line-of-this-windows-batch-file-execute-but-all-three-li

set PATH=%PATH%;D:\projects\cmake_android\tools\jdk-15.0.2\bin\;D:\projects\cmake_android\tools\gradle-6.8.3\bin\
rd /s /q build
if not exist build mkdir build
cd build
call gradle init --type basic --dsl groovy --project-name mumba --warning-mode all
type ..\app-in\build.gradle.part >> build.gradle
copy ..\app-in\local.properties local.properties
echo include ':app' >> settings.gradle
rd /s /q app
if not exist app mkdir app
copy ..\app-in\app\build.gradle app\build.gradle
call gradle build
cd ..
