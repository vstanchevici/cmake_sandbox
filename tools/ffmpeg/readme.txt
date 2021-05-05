https://ottverse.com/ffmpeg-builds/

ffmpeg:
git clone --depth 1 --branch n4.4 https://git.ffmpeg.org/ffmpeg.git ffmpeg

export PATH="/C/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.24.28314/bin/Hostx64/x64":$PATH
./configure --target-os=win64 --arch=x86_64 --toolchain=msvc --prefix=/d/projects/ffmpeg-install/

./configure --target-os=win64 --arch=x86_64 --toolchain=clang-usan --ar=llvm-ar --ranlib=llvm-ranlib  --enable-cross-compile --disable-x86asm --prefix=/d/projects/ffmpeg-install/

./configure --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32-


../make/make.exe
