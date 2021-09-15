set PATH=%PATH%;C:\Program Files\CMake\bin
rd /s /q build
if not exist build mkdir build
cmake -Bbuild -S.
