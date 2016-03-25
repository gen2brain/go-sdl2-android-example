#!/usr/bin/env bash

if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting. It must point to your NDK directories."
  exit 1
fi

if [ -z "$ANDROID_SDK" ]; then
  echo "You must define ANDROID_SDK before starting. It must point to your SDK directories."
  exit 1
fi

echo "sdk.dir=${ANDROID_SDK}" > local.properties

if [ ! -d "jni/SDL2" ]; then
    hg clone http://hg.libsdl.org/SDL jni/SDL2
    hg clone http://hg.libsdl.org/SDL_image jni/SDL2_image
    hg clone http://hg.libsdl.org/SDL_mixer jni/SDL2_mixer
    hg clone http://hg.libsdl.org/SDL_ttf jni/SDL2_ttf
fi

${ANDROID_NDK}/ndk-build -j$(nproc) && ant clean debug
