Downloaded from OTTVerse.com <https://ottverse.com/ffmpeg-builds> 


Configuration Settings 
====================== 
--disable-autodetect 
--enable-amf 
--enable-bzlib 
--enable-cuda 
--enable-cuvid 
--enable-d3d11va 
--enable-dxva2 
--enable-iconv 
--enable-lzma 
--enable-nvenc
--enable-zlib
--enable-sdl2
--enable-ffnvcodec
--enable-nvdec
--enable-cuda-llvm
--enable-libmp3lame
--enable-libopus
--enable-libvorbis
--enable-libvpx
--enable-libx264
--enable-libx265
--enable-libdav1d
--enable-libaom
--disable-debug
--enable-fontconfig
--enable-libass
--enable-libbluray
--enable-libfreetype
--enable-libmfx
--enable-libmysofa
--enable-libopencore-amrnb
--enable-libopencore-amrwb
--enable-libopenjpeg
--enable-libsnappy
--enable-libsoxr
--enable-libspeex
--enable-libtheora
--enable-libtwolame
--enable-libvidstab
--enable-libvo-amrwbenc
--enable-libwavpack
--enable-libwebp
--enable-libxml2
--enable-libzimg
--enable-libshine
--enable-gpl
--enable-avisynth
--enable-libxvid
--enable-libopenmpt
--enable-version3
--enable-libsrt
--enable-libgsm
--enable-libvmaf
--enable-libsvtav1
--enable-librtmp
--enable-mbedtls
--extra-cflags=-DLIBTWOLAME_STATIC
--extra-libs=-lstdc++
--extra-cflags=-DLIBXML_STATIC
--extra-libs=-liconv
--disable-w32threads



Revisions Used
==============
AMF c7f58ee D3D12 resource synchronization fence information moved to public header
aom c9ebc2a2b Tighten the loop filter range for the last super block
AviSynthPlus e18e487c Update readmes
cargo-c 1e027a3 Default to nightly
dav1d bd7f051 Remove a variable that is set but not used
ffmpeg 1ab74bc193 avcodec/adpcm_ima_apm: cosmetics
ffnvcodec 7adf160 Bump for (in-dev) 11.0.10.2
flac 27c61570 github actions: Drop HTML validation
fontconfig d06103e Bump version to 2.13.93
freetype2 6a2b3e400 * Version 2.10.4 released. ==========================
fribidi 5464c28 Bumped version to 1.0.10
harfbuzz 42bf8e3d4 [util] Disable chafa's truecolor mode
libaacs 7cee1c2 Remove double logging
libass 1140b6b Fix embedded and memory fonts
libavif da442e3 Document why we need to zero-initialize svt_config
libbdplus bd8c0dd configure.ac: use mingw as the case instead of mingw32
libbluray 311f0928 Bump version (1.3.0)
libmfx 25bde3f API 1.34
libmysofa d70a2a7 Fix for #158
librtmp f1b83c1 Fix race condition in the librtmp install target.
libsoxr 945b592 update NEWS, versions
libwebp 98bbe35b Fix multi-threading with palettes.
libxml2 5465a8e5 Update INSTALL.libxml2
openmpt e226c25a6 [Mod] libopenmpt: Prepare for release.
opus 7b05f44f celt_lpc: avoid overflows when computing lpcs in fixed point
rav1e b91f83ff Reconfigure speed level 2 to be level 3 with bottom-up partitioning
srt d898f1c [core] Improved RTT estimation (#1957)
SVT-AV1 44486d23 Static Analysis fixes (#1684)
vidstab 00e0841 Add GCC macros for byte order
vmaf a043900d Fix bug in piecewise_linear_mapping when only single segment is provided (#859)
vpx 9f57bc4d6 Add limits to Vizier input parameters.
x264 c347e7a0 CI: Add macos-arm64 target (cross-compile)
x265_git bf91444e0 Add: End Of Bitstream and End Of Sequence NAL units
zimg 90bf82c common: fix alignment for ARM




General Notice
===============
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.