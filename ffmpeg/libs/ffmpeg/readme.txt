https://trac.ffmpeg.org/ticket/6620
https://medium.com/@ilja.kosynkin/android-cmake-and-ffmpeg-part-two-building-ffmpeg-cd7f31f6c053
https://itnext.io/build-ffmpeg-webassembly-version-ffmpeg-js-part-2-compile-with-emscripten-4c581e8c9a16

https://ottverse.com/ffmpeg-builds/

ffmpeg:
git clone --depth 1 --branch n4.4 https://git.ffmpeg.org/ffmpeg.git ffmpeg

export PATH="/C/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.24.28314/bin/Hostx64/x64":$PATH
./configure --target-os=win64 --arch=x86_64 --toolchain=msvc --prefix=/d/projects/ffmpeg-install/

./configure --target-os=win64 --arch=x86_64 --toolchain=clang --ar=llvm-ar --ranlib=llvm-ranlib --disable-x86asm --prefix=/d/projects/ffmpeg-install/

./configure --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32-


../make/make.exe

               --enable-asm 
               --enable-yasm
./configure --toolchain=msvc --enable-swscale --disable-x86asm --target-os=win64 --arch=x86_64 --disable-shared --enable-static --disable-doc --disable-programs --enable-w32threads 


./configure --cc="C:\Program Files\LLVM\bin\clang.exe" --ar="C:\Program Files\LLVM\bin\llvm-ar.exe" --strip="C:\Program Files\LLVM\bin\llvm-strip.exe" --ranlib="C:\Program Files\LLVM\bin\llvm-ranlib.exe" --nm="C:\Program Files\LLVM\bin\llvm-nm.exe" --as="C:\Program Files\NASM\nasm.exe" --target-os=win64 --arch=x86_64 --disable-shared --enable-static --disable-doc --disable-programs --enable-w32threads

./configure --cc=clang.exe --cxx=clang++.exe --ar=llvm-ar.exe --strip=llvm-strip.exe --ranlib=llvm-ranlib.exe --nm=llvm-nm.exe --as=nasm.exe --target-os=win64 --arch=x86_64 --disable-shared --enable-static --disable-doc --disable-programs --enable-w32threads --prefix=/d/projects/ffmpeg-install/
