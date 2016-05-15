#!/usr/bin/env bash

if [ $# -lt 1 ]; then
  echo "Usage: mklib.bash [arm|arm7|arm64|x86|x86_64]"
  exit 1
fi

if [ -z "$USE_LLVM" ]; then
    MYCC=gcc
    MYCXX=g++
else
    MYCC=clang
    MYCXX=clang++
fi

while test -n "$1"; do
    case "$1" in
        arm)

        if [ -z "$ANDROID_TOOLCHAIN_ARM" ]; then
          echo "You must define ANDROID_TOOLCHAIN_ARM before starting. It should point to directory where you have installed arm toolchain."
          exit 1
        fi

        export PATH=$ANDROID_TOOLCHAIN_ARM/bin:${PATH}

        export CC=arm-linux-androideabi-${MYCC}
        export CXX=arm-linux-androideabi-${MYCXX}
        export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN_ARM/lib/pkgconfig
        export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN_ARM/lib/pkgconfig

        CGO_CFLAGS="-I$ANDROID_TOOLCHAIN_ARM/include/SDL2" \
        CGO_LDFLAGS="-L$ANDROID_TOOLCHAIN_ARM/lib -L$ANDROID_TOOLCHAIN_ARM/sysroot/usr/lib" \
        GOOS=android GOARCH=arm GOARM=6 CGO_ENABLED=1 \
        ${GOROOT}/bin/go build -v -x -buildmode=c-shared -ldflags="-s -w" -o=jni/src/armeabi/libexample.so github.com/gen2brain/go-sdl2-android-example/example

        shift
        ;;

        arm7)

        if [ -z "$ANDROID_TOOLCHAIN_ARM7" ]; then
          echo "You must define ANDROID_TOOLCHAIN_ARM7 before starting. It should point to directory where you have installed arm7 toolchain."
          exit 1
        fi

        export PATH=$ANDROID_TOOLCHAIN_ARM7/bin:${PATH}

        export CC=arm-linux-androideabi-${MYCC}
        export CXX=arm-linux-androideabi-${MYCXX}
        export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN_ARM7/lib/pkgconfig
        export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN_ARM7/lib/pkgconfig

        CGO_CFLAGS="-I$ANDROID_TOOLCHAIN_ARM7/include/SDL2" \
        CGO_LDFLAGS="-L$ANDROID_TOOLCHAIN_ARM7/lib -L$ANDROID_TOOLCHAIN_ARM7/sysroot/usr/lib" \
        GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 \
        ${GOROOT}/bin/go build -v -x -buildmode=c-shared -ldflags="-s -w" -o=jni/src/armeabi-v7a/libexample.so github.com/gen2brain/go-sdl2-android-example/example

        shift
        ;;

        arm64)

        if [ -z "$ANDROID_TOOLCHAIN_ARM64" ]; then
          echo "You must define ANDROID_TOOLCHAIN_ARM64 before starting. It should point to directory where you have installed arm64 toolchain."
          exit 1
        fi

        export PATH=$ANDROID_TOOLCHAIN_ARM64/bin:${PATH}

        export CC=aarch64-linux-android-${MYCC}
        export CXX=aarch64-linux-android-${MYCXX}
        export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN_ARM64/lib/pkgconfig
        export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN_ARM64/lib/pkgconfig

        CGO_CFLAGS="-I$ANDROID_TOOLCHAIN_ARM64/include/SDL2" \
        CGO_LDFLAGS="-L$ANDROID_TOOLCHAIN_ARM64/lib -L$ANDROID_TOOLCHAIN_ARM64/sysroot/usr/lib" \
        GOOS=android GOARCH=arm64 CGO_ENABLED=1 \
        ${GOROOT}/bin/go build -v -x -buildmode=c-shared -ldflags="-s -w" -o=jni/src/arm64-v8a/libexample.so github.com/gen2brain/go-sdl2-android-example/example

        shift
        ;;

        x86)

        if [ -z "$ANDROID_TOOLCHAIN_X86" ]; then
          echo "You must define ANDROID_TOOLCHAIN_X86 before starting. It should point to directory where you have installed x86 toolchain."
          exit 1
        fi

        export PATH=$ANDROID_TOOLCHAIN_X86/bin:${PATH}

        export CC=i686-linux-android-${MYCC}
        export CXX=i686-linux-android-${MYCXX}
        export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN_X86/lib/pkgconfig
        export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN_X86/lib/pkgconfig

        CGO_CFLAGS="-I$ANDROID_TOOLCHAIN_X86/include/SDL2" \
        CGO_LDFLAGS="-L$ANDROID_TOOLCHAIN_X86/lib -L$ANDROID_TOOLCHAIN_X86/sysroot/usr/lib" \
        GOOS=android GOARCH=386 CGO_ENABLED=1 \
        ${GOROOT}/bin/go build -v -x -buildmode=c-shared -ldflags="-s -w" -o=jni/src/x86/libexample.so github.com/gen2brain/go-sdl2-android-example/example

        shift
        ;;

        x86_64)

        if [ -z "$ANDROID_TOOLCHAIN_X86_64" ]; then
          echo "You must define ANDROID_TOOLCHAIN_X86_64 before starting. It should point to directory where you have installed x86_64 toolchain."
          exit 1
        fi

        export PATH=$ANDROID_TOOLCHAIN_X86_64/bin:${PATH}

        export CC=x86_64-linux-android-${MYCC}
        export CXX=x86_64-linux-android-${MYCXX}
        export PKG_CONFIG_PATH=$ANDROID_TOOLCHAIN_X86_64/lib/pkgconfig
        export PKG_CONFIG_LIBDIR=$ANDROID_TOOLCHAIN_X86_64/lib/pkgconfig

        CGO_CFLAGS="-I$ANDROID_TOOLCHAIN_X86_64/include/SDL2" \
        CGO_LDFLAGS="-L$ANDROID_TOOLCHAIN_X86_64/lib -L$ANDROID_TOOLCHAIN_X86_64/sysroot/usr/lib" \
        GOOS=android GOARCH=amd64 CGO_ENABLED=1 \
        ${GOROOT}/bin/go build -v -x -buildmode=c-shared -ldflags="-s -w" -o=jni/src/x86_64/libexample.so github.com/gen2brain/go-sdl2-android-example/example

        shift
        ;;

    esac
done
