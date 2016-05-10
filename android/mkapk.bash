#!/usr/bin/env bash

if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting. It should point to your NDK directories."
  exit 1
fi

if [ -z "$ANDROID_SDK" ]; then
  echo "You must define ANDROID_SDK before starting. It should point to your SDK directories."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: mkapk.bash [release|debug]"
  exit 1
fi

echo "sdk.dir=${ANDROID_SDK}" > local.properties

if [ ! -d "jni/SDL2" ]; then
    hg clone http://hg.libsdl.org/SDL jni/SDL2
    hg clone http://hg.libsdl.org/SDL_image jni/SDL2_image
    hg clone http://hg.libsdl.org/SDL_mixer jni/SDL2_mixer
    hg clone http://hg.libsdl.org/SDL_ttf jni/SDL2_ttf
fi

./mklib.bash arm || exit 1
./mklib.bash arm64 || exit 1
./mklib.bash x86 || exit 1
./mklib.bash x86_64 || exit 1

if [ $1 == "release" ]; then
    ${ANDROID_NDK}/ndk-build V=1 -j$(nproc) && ant clean release
elif [ $1 == "debug" ]; then
    ${ANDROID_NDK}/ndk-build V=1 -j$(nproc) && ant clean debug
fi
