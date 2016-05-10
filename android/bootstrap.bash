#!/usr/bin/env bash

if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting. It must point to your NDK directories."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: bootstrap.sh <install prefix>"
  exit 1
fi

OS="linux"
ARCH="amd64"
GO_BOOTSTRAP="1.6.2"

BUILD_DIR=`mktemp -d`

INSTALL_PREFIX="$1"
export PATH=${INSTALL_PREFIX}/android-toolchain-arm/bin:${INSTALL_PREFIX}/android-toolchain-arm64/bin:${INSTALL_PREFIX}/android-toolchain-x86/bin:${INSTALL_PREFIX}/android-toolchain-x86_64/bin:${PATH}

mkdir -p ${BUILD_DIR}/bootstrap

echo "Install android toolchains"
${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh --platform=android-9 --install-dir=${INSTALL_PREFIX}/android-toolchain-arm --toolchain=arm-linux-androideabi-4.9
${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh --platform=android-21 --install-dir=${INSTALL_PREFIX}/android-toolchain-arm64 --toolchain=aarch64-linux-android-4.9
${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh --platform=android-9 --install-dir=${INSTALL_PREFIX}/android-toolchain-x86 --toolchain=x86-4.9
${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh --platform=android-21 --install-dir=${INSTALL_PREFIX}/android-toolchain-x86_64 --toolchain=x86_64-4.9

echo "Download Go binaries"
cd ${BUILD_DIR}/bootstrap && curl -s -L http://golang.org/dl/go${GO_BOOTSTRAP}.${OS}-${ARCH}.tar.gz | tar xz
echo "Download Go source"
cd ${BUILD_DIR} && git clone https://github.com/golang/go.git && cd ${BUILD_DIR}/go/src

echo "Compile Go for host"
GOROOT_BOOTSTRAP=${BUILD_DIR}/bootstrap/go CC=gcc CC_FOR_TARGET=gcc CGO_ENABLED=1 ./make.bash --no-clean || exit 1
echo "Compile Go for arm-linux-androideabi"
GOROOT_BOOTSTRAP=${BUILD_DIR}/bootstrap/go CC=arm-linux-androideabi-gcc CC_FOR_TARGET=arm-linux-androideabi-gcc GOOS=android GOARCH=arm CGO_ENABLED=1 ./make.bash --no-clean || exit 1
echo "Compile Go for aarch64-linux-android"
GOROOT_BOOTSTRAP=${BUILD_DIR}/bootstrap/go CC=aarch64-linux-android-gcc CC_FOR_TARGET=aarch64-linux-android-gcc GOOS=android GOARCH=arm64 CGO_ENABLED=1 ./make.bash --no-clean || exit 1
echo "Compile Go for i686-linux-android"
GOROOT_BOOTSTRAP=${BUILD_DIR}/bootstrap/go CC=i686-linux-android-gcc CC_FOR_TARGET=i686-linux-android-gcc GOOS=android GOARCH=386 CGO_ENABLED=1 ./make.bash --no-clean || exit 1
echo "Compile Go for x86_64-linux-android"
GOROOT_BOOTSTRAP=${BUILD_DIR}/bootstrap/go CC=x86_64-linux-android-gcc CC_FOR_TARGET=x86_64-linux-android-gcc GOOS=android GOARCH=amd64 CGO_ENABLED=1 ./make.bash --no-clean || exit 1

cp -r -f ${BUILD_DIR}/go ${INSTALL_PREFIX}

echo "Compile SDL2"

mkdir -p ${BUILD_DIR}/jni

# Clone SDL repo
LIBS="SDL SDL_image SDL_mixer SDL_ttf"
for lib in ${LIBS}; do
    hg clone http://hg.libsdl.org/${lib} ${BUILD_DIR}/jni/${lib}
done

# Create make files
echo "include \$(call all-subdir-makefiles)" > ${BUILD_DIR}/jni/Android.mk
echo "APP_ABI := armeabi-v7a arm64-v8a x86 x86_64" > ${BUILD_DIR}/jni/Application.mk
echo "APP_PLATFORM := android-10" >> ${BUILD_DIR}/jni/Application.mk

# Disable some modules
sed -i '/^SUPPORT_MOD_MODPLUG ?= true/c\SUPPORT_MOD_MODPLUG ?= false' ${BUILD_DIR}/jni/SDL_mixer/Android.mk
sed -i '/^SUPPORT_MOD_MIKMOD ?= true/c\SUPPORT_MOD_MIKMOD ?= false' ${BUILD_DIR}/jni/SDL_mixer/Android.mk
sed -i '/^SUPPORT_MP3_SMPEG ?= true/c\SUPPORT_MP3_SMPEG ?= false' ${BUILD_DIR}/jni/SDL_mixer/Android.mk
sed -i '/^SUPPORT_TIMIDITY ?= true/c\SUPPORT_TIMIDITY ?= false' ${BUILD_DIR}/jni/SDL_mixer/Android.mk
sed -i '/^SUPPORT_JPG ?= true/c\SUPPORT_JPG ?= false' ${BUILD_DIR}/jni/SDL_image/Android.mk

# Build
cd ${BUILD_DIR}/jni && ${ANDROID_NDK}/ndk-build || exit 1

# Install libs and headers
mkdir -p ${INSTALL_PREFIX}/android-toolchain-{arm,arm64,x86,x86_64}/include/SDL2

cp -f ${BUILD_DIR}/libs/armeabi-v7a/* ${INSTALL_PREFIX}/android-toolchain-arm/lib/
cp -f ${BUILD_DIR}/jni/SDL/include/* ${INSTALL_PREFIX}/android-toolchain-arm/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_image/SDL_image.h ${INSTALL_PREFIX}/android-toolchain-arm/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_mixer/SDL_mixer.h ${INSTALL_PREFIX}/android-toolchain-arm/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_ttf/SDL_ttf.h ${INSTALL_PREFIX}/android-toolchain-arm/include/SDL2/

cp -f ${BUILD_DIR}/libs/arm64-v8a/* ${INSTALL_PREFIX}/android-toolchain-arm64/lib/
cp -f ${BUILD_DIR}/jni/SDL/include/* ${INSTALL_PREFIX}/android-toolchain-arm64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_image/SDL_image.h ${INSTALL_PREFIX}/android-toolchain-arm64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_mixer/SDL_mixer.h ${INSTALL_PREFIX}/android-toolchain-arm64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_ttf/SDL_ttf.h ${INSTALL_PREFIX}/android-toolchain-arm64/include/SDL2/

cp -f ${BUILD_DIR}/libs/x86/* ${INSTALL_PREFIX}/android-toolchain-x86/lib/
cp -f ${BUILD_DIR}/jni/SDL/include/* ${INSTALL_PREFIX}/android-toolchain-x86/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_image/SDL_image.h ${INSTALL_PREFIX}/android-toolchain-x86/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_mixer/SDL_mixer.h ${INSTALL_PREFIX}/android-toolchain-x86/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_ttf/SDL_ttf.h ${INSTALL_PREFIX}/android-toolchain-x86/include/SDL2/

cp -f ${BUILD_DIR}/libs/x86_64/* ${INSTALL_PREFIX}/android-toolchain-x86_64/lib/
cp -f ${BUILD_DIR}/jni/SDL/include/* ${INSTALL_PREFIX}/android-toolchain-x86_64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_image/SDL_image.h ${INSTALL_PREFIX}/android-toolchain-x86_64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_mixer/SDL_mixer.h ${INSTALL_PREFIX}/android-toolchain-x86_64/include/SDL2/
cp -f ${BUILD_DIR}/jni/SDL_ttf/SDL_ttf.h ${INSTALL_PREFIX}/android-toolchain-x86_64/include/SDL2/

# Install SDL2 pkg-config file
mkdir -p ${INSTALL_PREFIX}/android-toolchain-{arm,arm64,x86,x86_64}/lib/pkgconfig

cat << EOF > ${INSTALL_PREFIX}/android-toolchain-arm/lib/pkgconfig/sdl2.pc
prefix=${INSTALL_PREFIX}/android-toolchain-arm
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: sdl2
Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.
Version: 2.0.4
Requires:
Conflicts:
Libs: -L\${libdir}  -lSDL2
Libs.private: -lSDL2  -Wl,--no-undefined -lm -ldl -lrt
Cflags: -I\${includedir}/SDL2 -D_REENTRANT
EOF

cat << EOF > ${INSTALL_PREFIX}/android-toolchain-arm64/lib/pkgconfig/sdl2.pc
prefix=${INSTALL_PREFIX}/android-toolchain-arm64
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: sdl2
Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.
Version: 2.0.4
Requires:
Conflicts:
Libs: -L\${libdir}  -lSDL2 -lz
Libs.private: -lSDL2  -Wl,--no-undefined -lm -ldl -lrt
Cflags: -I\${includedir}/SDL2 -D_REENTRANT
EOF

cat << EOF > ${INSTALL_PREFIX}/android-toolchain-x86/lib/pkgconfig/sdl2.pc
prefix=${INSTALL_PREFIX}/android-toolchain-x86
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: sdl2
Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.
Version: 2.0.4
Requires:
Conflicts:
Libs: -L\${libdir}  -lSDL2
Libs.private: -lSDL2  -Wl,--no-undefined -lm -ldl -lrt
Cflags: -I\${includedir}/SDL2 -D_REENTRANT
EOF

cat << EOF > ${INSTALL_PREFIX}/android-toolchain-x86_64/lib/pkgconfig/sdl2.pc
prefix=${INSTALL_PREFIX}/android-toolchain-x86_64
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: sdl2
Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.
Version: 2.0.4
Requires:
Conflicts:
Libs: -L\${libdir}  -lSDL2
Libs.private: -lSDL2  -Wl,--no-undefined -lm -ldl -lrt
Cflags: -I\${includedir}/SDL2 -D_REENTRANT
EOF

echo "Remove build directory"
rm -rf ${BUILD_DIR}
